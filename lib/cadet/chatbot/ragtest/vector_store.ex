defmodule Cadet.Chatbot.Rag.VectorStore do
  @moduledoc """
  An in-memory vector store backed by ETS for storing and retrieving
  document embeddings using cosine similarity search.

  Analogous to LangChain's Chroma vector database. Stores document chunks
  alongside their embedding vectors and supports nearest-neighbor retrieval.

  ## Usage

      # Initialize the store (creates the ETS table)
      VectorStore.init()

      # Add documents with their embeddings
      VectorStore.add_documents(chunks_with_embeddings)

      # Query for similar documents
      {:ok, results} = VectorStore.similarity_search(query_embedding, top_k: 3)
  """

  use GenServer
  require Logger

  @table_name :rag_vector_store
  @default_top_k 4

  # ── Client API ──────────────────────────────────────────────────────

  def start_link(opts \\ []) do
    name = Keyword.get(opts, :name, __MODULE__)
    GenServer.start_link(__MODULE__, opts, name: name)
  end

  @doc """
  Adds a list of document chunks with their embeddings to the store.

  Each entry should be a map with `:content`, `:metadata`, and `:embedding` keys.
  """
  @spec add_documents([map()]) :: :ok
  def add_documents(docs_with_embeddings) do
    GenServer.call(__MODULE__, {:add_documents, docs_with_embeddings}, :infinity)
  end

  @doc """
  Performs a cosine similarity search against stored documents.

  Returns the top-k most similar documents as a list of
  `%{content: String.t(), metadata: map(), score: float()}`.

  ## Options
    * `:top_k` - Number of results to return (default: #{@default_top_k})
  """
  @spec similarity_search([float()], keyword()) ::
          {:ok, [%{content: String.t(), metadata: map(), score: float()}]}
  def similarity_search(query_embedding, opts \\ []) do
    top_k = Keyword.get(opts, :top_k, @default_top_k)
    GenServer.call(__MODULE__, {:similarity_search, query_embedding, top_k}, :infinity)
  end

  @doc """
  Returns the total number of documents in the store.
  """
  @spec count() :: non_neg_integer()
  def count do
    GenServer.call(__MODULE__, :count)
  end

  @doc """
  Clears all documents from the store.
  """
  @spec clear() :: :ok
  def clear do
    GenServer.call(__MODULE__, :clear)
  end

  @doc """
  Persists the vector store to a file on disk for later reload.
  """
  @spec save_to_file(String.t()) :: :ok | {:error, String.t()}
  def save_to_file(file_path) do
    GenServer.call(__MODULE__, {:save_to_file, file_path}, :infinity)
  end

  @doc """
  Loads the vector store from a previously saved file.
  """
  @spec load_from_file(String.t()) :: :ok | {:error, String.t()}
  def load_from_file(file_path) do
    GenServer.call(__MODULE__, {:load_from_file, file_path}, :infinity)
  end

  # ── Server Callbacks ───────────────────────────────────────────────

  @default_persist_path "lib/cadet/chatbot/ragtest/vector_db/vector_store.bin"

  @impl true
  def init(_opts) do
    table = :ets.new(@table_name, [:set, :protected, :named_table])
    # Counter for auto-incrementing IDs
    :ets.insert(table, {:next_id, 0})
    Logger.info("RAG VectorStore initialized")

    # Auto-load persisted vector store if it exists
    auto_load_persisted(table)

    {:ok, %{table: table}}
  end

  defp auto_load_persisted(_table) do
    persist_path = Path.expand(@default_persist_path)

    if File.exists?(persist_path) do
      case File.read(persist_path) do
        {:ok, binary} ->
          data = :erlang.binary_to_term(binary)

          Enum.each(data, fn doc ->
            [{:next_id, current_id}] = :ets.lookup(@table_name, :next_id)
            :ets.insert(@table_name, {:next_id, current_id + 1})

            :ets.insert(@table_name, {
              {:doc, current_id},
              doc.content,
              doc.metadata,
              doc.embedding
            })
          end)

          count = max(:ets.info(@table_name, :size) - 1, 0)
          Logger.info("Auto-loaded #{count} documents from #{persist_path}")

        {:error, reason} ->
          Logger.warning("Failed to auto-load vector store: #{inspect(reason)}")
      end
    else
      Logger.info("No persisted vector store found at #{persist_path}, starting empty")
    end
  end

  @impl true
  def handle_call({:add_documents, docs}, _from, state) do
    Enum.each(docs, fn doc ->
      [{:next_id, current_id}] = :ets.lookup(@table_name, :next_id)
      :ets.insert(@table_name, {:next_id, current_id + 1})

      entry = {
        {:doc, current_id},
        doc.content,
        doc.metadata,
        doc.embedding
      }

      :ets.insert(@table_name, entry)
    end)

    count = document_count()
    Logger.info("Added #{length(docs)} documents to VectorStore (total: #{count})")
    {:reply, :ok, state}
  end

  @impl true
  def handle_call({:similarity_search, query_embedding, top_k}, _from, state) do
    results =
      :ets.foldl(
        fn
          {{:doc, _id}, content, metadata, embedding}, acc ->
            score = cosine_similarity(query_embedding, embedding)
            [%{content: content, metadata: metadata, score: score} | acc]

          _other, acc ->
            acc
        end,
        [],
        @table_name
      )
      |> Enum.sort_by(& &1.score, :desc)
      |> Enum.take(top_k)

    {:reply, {:ok, results}, state}
  end

  @impl true
  def handle_call(:count, _from, state) do
    {:reply, document_count(), state}
  end

  @impl true
  def handle_call(:clear, _from, state) do
    :ets.delete_all_objects(@table_name)
    :ets.insert(@table_name, {:next_id, 0})
    Logger.info("VectorStore cleared")
    {:reply, :ok, state}
  end

  @impl true
  def handle_call({:save_to_file, file_path}, _from, state) do
    abs_path = Path.expand(file_path)
    File.mkdir_p!(Path.dirname(abs_path))

    data =
      :ets.foldl(
        fn
          {{:doc, _id}, content, metadata, embedding}, acc ->
            [%{content: content, metadata: metadata, embedding: embedding} | acc]

          _other, acc ->
            acc
        end,
        [],
        @table_name
      )

    binary = :erlang.term_to_binary(data)

    case File.write(abs_path, binary) do
      :ok ->
        Logger.info("VectorStore saved to #{abs_path} (#{length(data)} documents)")
        {:reply, :ok, state}

      {:error, reason} ->
        {:reply, {:error, "Failed to save: #{inspect(reason)}"}, state}
    end
  end

  @impl true
  def handle_call({:load_from_file, file_path}, _from, state) do
    abs_path = Path.expand(file_path)

    case File.read(abs_path) do
      {:ok, binary} ->
        data = :erlang.binary_to_term(binary)

        # Clear existing data
        :ets.delete_all_objects(@table_name)
        :ets.insert(@table_name, {:next_id, 0})

        # Re-insert loaded documents
        Enum.each(data, fn doc ->
          [{:next_id, current_id}] = :ets.lookup(@table_name, :next_id)
          :ets.insert(@table_name, {:next_id, current_id + 1})

          :ets.insert(@table_name, {
            {:doc, current_id},
            doc.content,
            doc.metadata,
            doc.embedding
          })
        end)

        count = document_count()
        Logger.info("VectorStore loaded from #{abs_path} (#{count} documents)")
        {:reply, :ok, state}

      {:error, reason} ->
        {:reply, {:error, "Failed to load: #{inspect(reason)}"}, state}
    end
  end

  # ── Math Helpers ────────────────────────────────────────────────────

  @doc false
  def cosine_similarity(vec_a, vec_b) when length(vec_a) == length(vec_b) do
    dot = dot_product(vec_a, vec_b)
    norm_a = vector_norm(vec_a)
    norm_b = vector_norm(vec_b)

    if norm_a == 0.0 or norm_b == 0.0 do
      0.0
    else
      dot / (norm_a * norm_b)
    end
  end

  def cosine_similarity(_vec_a, _vec_b), do: 0.0

  defp dot_product(a, b) do
    a
    |> Enum.zip(b)
    |> Enum.reduce(0.0, fn {x, y}, acc -> acc + x * y end)
  end

  defp vector_norm(vec) do
    vec
    |> Enum.reduce(0.0, fn x, acc -> acc + x * x end)
    |> :math.sqrt()
  end

  defp document_count do
    # Total entries minus the :next_id counter
    max(:ets.info(@table_name, :size) - 1, 0)
  end
end
