defmodule Cadet.Chatbot.Rag.RetrievalChain do
  @moduledoc """
  Retrieval QA chain that combines vector retrieval with LLM generation.

  Analogous to LangChain's RetrievalQA. Given a user query, this module:
  1. Embeds the query using the OpenAI Embeddings API
  2. Retrieves the top-k most similar document chunks from the VectorStore
  3. Constructs a prompt with the retrieved context
  4. Sends the prompt to the OpenAI Chat Completion API for an answer

  This implements the "stuff" chain type — all retrieved chunks are stuffed
  into the prompt as context.
  """

  require Logger

  alias Cadet.Chatbot.Rag.{Embeddings, VectorStore}

  @default_top_k 4
  @default_model "gpt-4"

  @system_prompt_template """
  You are a knowledgeable assistant. Answer the user's question based ONLY on \
  the following retrieved context. If the context does not contain enough \
  information to answer, say so clearly.

  --- RETRIEVED CONTEXT ---
  <%= context %>
  --- END CONTEXT ---
  """

  @type chain_opts :: [
          top_k: pos_integer(),
          model: String.t(),
          system_prompt: String.t() | nil
        ]

  @doc """
  Invokes the retrieval QA chain with a user query.

  ## Options
    * `:top_k` - Number of chunks to retrieve (default: #{@default_top_k})
    * `:model` - OpenAI model to use for generation (default: "#{@default_model}")
    * `:system_prompt` - Custom system prompt template (must contain `<%= context %>`)

  Returns `{:ok, %{answer: String.t(), sources: [map()]}}` or `{:error, reason}`.
  """
  @spec invoke(String.t(), chain_opts()) ::
          {:ok, %{answer: String.t(), sources: [map()]}} | {:error, String.t()}
  def invoke(query, opts \\ []) do
    top_k = Keyword.get(opts, :top_k, @default_top_k)
    model = Keyword.get(opts, :model, @default_model)
    system_template = Keyword.get(opts, :system_prompt, @system_prompt_template)

    Logger.info("RAG RetrievalChain invoked with query: #{String.slice(query, 0..80)}...")

    with {:ok, query_embedding} <- Embeddings.generate(query),
         {:ok, results} <- VectorStore.similarity_search(query_embedding, top_k: top_k),
         context <- format_context(results),
         system_prompt <- build_system_prompt(system_template, context),
         messages <- [
           %{role: "system", content: system_prompt},
           %{role: "user", content: query}
         ],
         {:ok, answer} <- call_llm(model, messages) do
      Logger.info("RAG chain completed. Retrieved #{length(results)} chunks.")

      {:ok,
       %{
         answer: answer,
         sources:
           Enum.map(results, fn r ->
             %{
               content: String.slice(r.content, 0..200),
               score: r.score,
               metadata: r.metadata
             }
           end)
       }}
    else
      {:error, reason} ->
        Logger.error("RAG RetrievalChain error: #{inspect(reason)}")
        {:error, reason}
    end
  end

  @doc """
  Retrieves relevant context chunks for a query without calling the LLM.
  Useful for augmenting an existing prompt with RAG context.

  Returns `{:ok, context_string}` or `{:error, reason}`.
  """
  @spec retrieve_context(String.t(), keyword()) :: {:ok, String.t()} | {:error, String.t()}
  def retrieve_context(query, opts \\ []) do
    top_k = Keyword.get(opts, :top_k, @default_top_k)

    with {:ok, query_embedding} <- Embeddings.generate(query),
         {:ok, results} <- VectorStore.similarity_search(query_embedding, top_k: top_k) do
      context = format_context(results)
      Logger.info("Retrieved #{length(results)} context chunks for query")
      {:ok, context}
    end
  end

  # ── Private Helpers ─────────────────────────────────────────────────

  defp format_context(results) do
    results
    |> Enum.with_index(1)
    |> Enum.map(fn {result, idx} ->
      source = Map.get(result.metadata, :filename, "unknown")
      "[#{idx}] (source: #{source}, score: #{Float.round(result.score, 4)})\n#{result.content}"
    end)
    |> Enum.join("\n\n")
  end

  defp build_system_prompt(template, context) do
    EEx.eval_string(template, context: context)
  end

  defp call_llm(model, messages) do
    case OpenAI.chat_completion(model: model, messages: messages) do
      {:ok, result_map} ->
        choices = Map.get(result_map, :choices, [])

        case Enum.at(choices, 0) do
          %{"message" => %{"content" => content}} ->
            {:ok, content}

          _ ->
            {:error, "No response content from LLM"}
        end

      {:error, reason} ->
        error_msg =
          case reason do
            %{"error" => %{"message" => msg}} -> msg
            other -> inspect(other)
          end

        {:error, "LLM API error: #{error_msg}"}
    end
  end
end
