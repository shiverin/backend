defmodule Cadet.Chatbot.Rag.DocumentLoader do
  @moduledoc """
  Loads documents from the filesystem for RAG processing.

  Supports plain text (.txt), Markdown (.md), and raw file loading.
  Each loaded document is returned as a map with `:content` and `:metadata`.

  Analogous to LangChain's PyPDFLoader / TextLoader.
  """

  require Logger

  @supported_extensions ~w(.txt .md .text .markdown)

  @type document :: %{
          content: String.t(),
          metadata: %{
            source: String.t(),
            filename: String.t(),
            loaded_at: DateTime.t()
          }
        }

  @doc """
  Loads all supported documents from the given directory path.
  Returns `{:ok, documents}` or `{:error, reason}`.
  """
  @spec load_directory(String.t()) :: {:ok, [document()]} | {:error, String.t()}
  def load_directory(dir_path) do
    abs_path = Path.expand(dir_path)

    if File.dir?(abs_path) do
      documents =
        abs_path
        |> File.ls!()
        |> Enum.filter(&supported_file?/1)
        |> Enum.sort()
        |> Enum.flat_map(fn filename ->
          file_path = Path.join(abs_path, filename)

          case load_file(file_path) do
            {:ok, doc} ->
              [doc]

            {:error, reason} ->
              Logger.warning("Skipping file #{filename}: #{reason}")
              []
          end
        end)

      Logger.info("Loaded #{length(documents)} document(s) from #{abs_path}")
      {:ok, documents}
    else
      {:error, "Directory does not exist: #{abs_path}"}
    end
  end

  @doc """
  Loads a single file and returns it as a document map.
  """
  @spec load_file(String.t()) :: {:ok, document()} | {:error, String.t()}
  def load_file(file_path) do
    abs_path = Path.expand(file_path)

    case File.read(abs_path) do
      {:ok, content} ->
        doc = %{
          content: String.trim(content),
          metadata: %{
            source: abs_path,
            filename: Path.basename(abs_path),
            loaded_at: DateTime.utc_now()
          }
        }

        {:ok, doc}

      {:error, reason} ->
        {:error, "Failed to read #{abs_path}: #{inspect(reason)}"}
    end
  end

  @doc """
  Loads multiple files by their paths.
  """
  @spec load_files([String.t()]) :: {:ok, [document()]} | {:error, String.t()}
  def load_files(file_paths) when is_list(file_paths) do
    documents =
      file_paths
      |> Enum.flat_map(fn path ->
        case load_file(path) do
          {:ok, doc} -> [doc]
          {:error, reason} ->
            Logger.warning("Skipping file #{path}: #{reason}")
            []
        end
      end)

    {:ok, documents}
  end

  defp supported_file?(filename) do
    ext = Path.extname(filename) |> String.downcase()
    ext in @supported_extensions
  end
end
