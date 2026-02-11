defmodule Mix.Tasks.Rag.Ingest do
  @moduledoc """
  Mix task to ingest documents into the RAG vector store.

  ## Usage

      # Ingest all documents from the default directory
      mix rag.ingest

      # Ingest from a custom directory
      mix rag.ingest --dir /path/to/documents

      # Ingest and save the vector store to disk
      mix rag.ingest --save priv/rag/vector_store.bin

      # Customize chunk size and overlap
      mix rag.ingest --chunk-size 500 --chunk-overlap 50
  """

  use Mix.Task

  require Logger

  @shortdoc "Ingest documents into the RAG vector store"

  @default_dir "lib/cadet/chatbot/ragtest/documents"
  @default_save_path "lib/cadet/chatbot/ragtest/vector_db/vector_store.bin"

  @impl Mix.Task
  def run(args) do
    # Start the application so we have access to HTTPoison, ETS, config, etc.
    Mix.Task.run("app.start")

    {opts, _, _} =
      OptionParser.parse(args,
        strict: [
          dir: :string,
          save: :string,
          no_save: :boolean,
          chunk_size: :integer,
          chunk_overlap: :integer
        ],
        aliases: [d: :dir, s: :save]
      )

    dir = Keyword.get(opts, :dir, @default_dir)
    no_save = Keyword.get(opts, :no_save, false)
    save_path = if no_save, do: nil, else: Keyword.get(opts, :save, @default_save_path)
    chunk_size = Keyword.get(opts, :chunk_size, 1000)
    chunk_overlap = Keyword.get(opts, :chunk_overlap, 100)

    Mix.shell().info("🔍 Ingesting documents from: #{dir}")
    Mix.shell().info("   Chunk size: #{chunk_size}, Overlap: #{chunk_overlap}")

    case Cadet.Chatbot.Rag.ingest_directory(dir,
           chunk_size: chunk_size,
           chunk_overlap: chunk_overlap
         ) do
      {:ok, stats} ->
        Mix.shell().info(
          "✅ Ingestion complete: #{stats.documents} document(s) → #{stats.chunks} chunk(s)"
        )

        Mix.shell().info("   Vector store count: #{Cadet.Chatbot.Rag.store_count()}")

        if save_path do
          case Cadet.Chatbot.Rag.save_store(save_path) do
            :ok ->
              Mix.shell().info("💾 Vector store saved to: #{save_path}")

            {:error, reason} ->
              Mix.shell().error("❌ Failed to save vector store: #{reason}")
          end
        end

      {:error, reason} ->
        Mix.shell().error("❌ Ingestion failed: #{reason}")
    end
  end
end
