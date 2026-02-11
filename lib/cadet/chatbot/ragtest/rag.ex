defmodule Cadet.Chatbot.Rag do
  @moduledoc """
  Main entry point for the RAG (Retrieval-Augmented Generation) pipeline.

  Orchestrates the full RAG workflow analogous to the following Python/LangChain
  pipeline:

      1. Load documents          → DocumentLoader
      2. Split into chunks       → TextSplitter
      3. Generate embeddings     → Embeddings (OpenAI text-embedding-3-small)
      4. Store in vector DB      → VectorStore (ETS-backed, cosine similarity)
      5. Retrieval QA            → RetrievalChain (retrieve + LLM answer)

  ## Quick Start

      # Ingest documents from a folder
      Cadet.Chatbot.Rag.ingest_directory("/path/to/documents")

      # Ask a question using RAG
      {:ok, result} = Cadet.Chatbot.Rag.query("What does the document say about X?")
      IO.puts(result.answer)

  ## Persisting the Vector Store

      # Save to disk after ingestion
      Cadet.Chatbot.Rag.save_store("priv/rag/vector_store.bin")

      # Load on next startup
      Cadet.Chatbot.Rag.load_store("priv/rag/vector_store.bin")
  """

  require Logger

  alias Cadet.Chatbot.Rag.{DocumentLoader, TextSplitter, Embeddings, VectorStore, RetrievalChain}

  # Maximum texts to embed in a single API call (OpenAI limit & memory)
  @batch_size 20

  # Default path to persist the vector store inside the ragtest folder
  @default_persist_path "lib/cadet/chatbot/ragtest/vector_db/vector_store.bin"

  @doc """
  Ingests all supported documents from a directory into the vector store.

  This is the main "setup" function — call it once (or whenever documents
  change) to build the vector store. Equivalent to steps 1–4 of the
  Python RAG example.

  ## Options
    * `:chunk_size` - Max chars per chunk (default: 1000)
    * `:chunk_overlap` - Overlap between chunks (default: 100)
    * `:separator` - Separator for splitting (default: "\\n\\n")
    * `:embedding_model` - OpenAI embedding model (default: "text-embedding-3-small")

  Returns `{:ok, %{documents: integer(), chunks: integer()}}` or `{:error, reason}`.
  """
  @spec ingest_directory(String.t(), keyword()) ::
          {:ok, %{documents: non_neg_integer(), chunks: non_neg_integer()}} | {:error, String.t()}
  def ingest_directory(dir_path, opts \\ []) do
    Logger.info("Starting RAG ingestion from: #{dir_path}")

    with {:ok, documents} <- DocumentLoader.load_directory(dir_path),
         {:ok, _} <- validate_documents(documents),
         chunks <- TextSplitter.split_documents(documents, opts),
         {:ok, _} <- embed_and_store(chunks, opts) do
      Logger.info(
        "RAG ingestion complete: #{length(documents)} documents → #{length(chunks)} chunks"
      )

      {:ok, %{documents: length(documents), chunks: length(chunks)}}
    end
  end

  @doc """
  Ingests a list of file paths into the vector store.
  """
  @spec ingest_files([String.t()], keyword()) ::
          {:ok, %{documents: non_neg_integer(), chunks: non_neg_integer()}} | {:error, String.t()}
  def ingest_files(file_paths, opts \\ []) do
    Logger.info("Starting RAG ingestion for #{length(file_paths)} file(s)")

    with {:ok, documents} <- DocumentLoader.load_files(file_paths),
         {:ok, _} <- validate_documents(documents),
         chunks <- TextSplitter.split_documents(documents, opts),
         {:ok, _} <- embed_and_store(chunks, opts) do
      {:ok, %{documents: length(documents), chunks: length(chunks)}}
    end
  end

  @doc """
  Ingests raw text content directly (useful for processing existing data
  like the SICP notes already in the system).

  ## Parameters
    * `texts` - A list of `%{content: String.t(), metadata: map()}` maps
    * `opts` - Splitting and embedding options
  """
  @spec ingest_texts([%{content: String.t(), metadata: map()}], keyword()) ::
          {:ok, %{chunks: non_neg_integer()}} | {:error, String.t()}
  def ingest_texts(texts, opts \\ []) do
    Logger.info("Starting RAG ingestion for #{length(texts)} text(s)")

    chunks = TextSplitter.split_documents(texts, opts)

    case embed_and_store(chunks, opts) do
      {:ok, _} ->
        {:ok, %{chunks: length(chunks)}}

      error ->
        error
    end
  end

  @doc """
  Queries the RAG system with a natural language question.

  Equivalent to step 6 of the Python example — embeds the query, retrieves
  relevant chunks, and generates an answer using the LLM.

  ## Options
    * `:top_k` - Number of chunks to retrieve (default: 4)
    * `:model` - LLM model for answer generation (default: "gpt-4")

  Returns `{:ok, %{answer: String.t(), sources: [map()]}}` or `{:error, reason}`.
  """
  @spec query(String.t(), keyword()) ::
          {:ok, %{answer: String.t(), sources: [map()]}} | {:error, String.t()}
  def query(question, opts \\ []) do
    RetrievalChain.invoke(question, opts)
  end

  @doc """
  Retrieves relevant context for a query without calling the LLM.
  Useful for augmenting the existing chatbot's `PromptBuilder` with
  RAG-retrieved context.

  Returns `{:ok, context_string}` or `{:error, reason}`.
  """
  @spec retrieve_context(String.t(), keyword()) :: {:ok, String.t()} | {:error, String.t()}
  def retrieve_context(question, opts \\ []) do
    RetrievalChain.retrieve_context(question, opts)
  end

  @doc """
  Returns the number of document chunks currently in the vector store.
  """
  @spec store_count() :: non_neg_integer()
  def store_count, do: VectorStore.count()

  @doc """
  Clears all documents from the vector store.
  """
  @spec clear_store() :: :ok
  def clear_store, do: VectorStore.clear()

  @doc """
  Saves the vector store to disk for persistence across restarts.
  Defaults to `#{@default_persist_path}` inside the ragtest folder.
  """
  @spec save_store(String.t()) :: :ok | {:error, String.t()}
  def save_store(file_path \\ @default_persist_path), do: VectorStore.save_to_file(file_path)

  @doc """
  Loads a previously saved vector store from disk.
  Defaults to `#{@default_persist_path}` inside the ragtest folder.
  """
  @spec load_store(String.t()) :: :ok | {:error, String.t()}
  def load_store(file_path \\ @default_persist_path), do: VectorStore.load_from_file(file_path)

  # ── Private Helpers ─────────────────────────────────────────────────

  defp validate_documents([]) do
    {:error, "No documents found to ingest"}
  end

  defp validate_documents(documents), do: {:ok, documents}

  defp embed_and_store(chunks, opts) do
    embedding_model = Keyword.get(opts, :embedding_model, "text-embedding-3-small")

    Logger.info("Generating embeddings for #{length(chunks)} chunks...")

    # Process in batches to avoid overwhelming the API
    chunks
    |> Enum.chunk_every(@batch_size)
    |> Enum.with_index(1)
    |> Enum.reduce_while(:ok, fn {batch, batch_num}, _acc ->
      total_batches = ceil(length(chunks) / @batch_size)
      Logger.info("Processing batch #{batch_num}/#{total_batches}...")

      texts = Enum.map(batch, & &1.content)

      case Embeddings.generate_batch(texts, model: embedding_model) do
        {:ok, text_embedding_pairs} ->
          docs_with_embeddings =
            batch
            |> Enum.zip(text_embedding_pairs)
            |> Enum.map(fn {chunk, {_text, embedding}} ->
              Map.put(chunk, :embedding, embedding)
            end)

          VectorStore.add_documents(docs_with_embeddings)
          {:cont, :ok}

        {:error, reason} ->
          Logger.error("Embedding batch #{batch_num} failed: #{reason}")
          {:halt, {:error, reason}}
      end
    end)
    |> case do
      :ok -> {:ok, length(chunks)}
      error -> error
    end
  end
end
