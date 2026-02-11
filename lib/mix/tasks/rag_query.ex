defmodule Mix.Tasks.Rag.Query do
  @moduledoc """
  Mix task to query the RAG system from the command line.

  ## Usage

      # Ask a question (make sure documents have been ingested first)
      mix rag.query "What does the document say about higher-order functions?"

      # Load a saved vector store before querying
      mix rag.query --load priv/rag/vector_store.bin "What is data abstraction?"

      # Adjust the number of retrieved chunks
      mix rag.query --top-k 3 "Explain recursion"
  """

  use Mix.Task

  @shortdoc "Query the RAG system with a natural language question"

  @impl Mix.Task
  def run(args) do
    Mix.Task.run("app.start")

    {opts, positional, _} =
      OptionParser.parse(args,
        strict: [
          load: :string,
          top_k: :integer,
          model: :string
        ],
        aliases: [l: :load, k: :top_k, m: :model]
      )

    load_path = Keyword.get(opts, :load)
    top_k = Keyword.get(opts, :top_k, 4)
    model = Keyword.get(opts, :model, "gpt-4")

    if load_path do
      Mix.shell().info("📂 Loading vector store from: #{load_path}")

      case Cadet.Chatbot.Rag.load_store(load_path) do
        :ok -> Mix.shell().info("   Loaded #{Cadet.Chatbot.Rag.store_count()} chunks")
        {:error, reason} -> Mix.shell().error("❌ Failed to load: #{reason}")
      end
    end

    query = Enum.join(positional, " ")

    if query == "" do
      Mix.shell().error("❌ Please provide a query. Usage: mix rag.query \"your question\"")
    else
      count = Cadet.Chatbot.Rag.store_count()

      if count == 0 do
        Mix.shell().error("❌ Vector store is empty. Run `mix rag.ingest` first.")
      else
        Mix.shell().info("🤔 Querying RAG system (#{count} chunks, top_k=#{top_k})...")
        Mix.shell().info("   Question: #{query}\n")

        case Cadet.Chatbot.Rag.query(query, top_k: top_k, model: model) do
          {:ok, result} ->
            Mix.shell().info("💡 Answer:\n#{result.answer}\n")
            Mix.shell().info("📚 Sources (#{length(result.sources)}):")

            Enum.each(result.sources, fn source ->
              Mix.shell().info(
                "   • [score: #{Float.round(source.score, 4)}] #{source.metadata[:filename] || "unknown"}"
              )
            end)

          {:error, reason} ->
            Mix.shell().error("❌ Query failed: #{reason}")
        end
      end
    end
  end
end
