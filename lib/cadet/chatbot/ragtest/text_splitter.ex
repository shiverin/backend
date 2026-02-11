defmodule Cadet.Chatbot.Rag.TextSplitter do
  @moduledoc """
  Splits documents into smaller chunks for embedding and retrieval.

  Analogous to LangChain's CharacterTextSplitter. Splits text on a configurable
  separator (default: double newline) with a specified chunk size and overlap
  to preserve context across chunk boundaries.
  """

  @default_chunk_size 1000
  @default_chunk_overlap 100
  @default_separator "\n\n"

  @type chunk :: %{
          content: String.t(),
          metadata: %{
            source: String.t(),
            filename: String.t(),
            chunk_index: non_neg_integer(),
            loaded_at: DateTime.t()
          }
        }

  @type split_opts :: [
          chunk_size: pos_integer(),
          chunk_overlap: non_neg_integer(),
          separator: String.t()
        ]

  @doc """
  Splits a list of documents into smaller chunks.

  ## Options
    * `:chunk_size` - Maximum characters per chunk (default: #{@default_chunk_size})
    * `:chunk_overlap` - Number of overlapping characters between chunks (default: #{@default_chunk_overlap})
    * `:separator` - String to split on first (default: double newline)

  Returns a flat list of chunk maps, each containing `:content` and `:metadata`.
  """
  @spec split_documents([map()], split_opts()) :: [chunk()]
  def split_documents(documents, opts \\ []) do
    chunk_size = Keyword.get(opts, :chunk_size, @default_chunk_size)
    chunk_overlap = Keyword.get(opts, :chunk_overlap, @default_chunk_overlap)
    separator = Keyword.get(opts, :separator, @default_separator)

    documents
    |> Enum.flat_map(fn doc ->
      chunks = split_text(doc.content, chunk_size, chunk_overlap, separator)

      chunks
      |> Enum.with_index()
      |> Enum.map(fn {chunk_text, index} ->
        %{
          content: chunk_text,
          metadata: Map.merge(doc.metadata, %{chunk_index: index})
        }
      end)
    end)
  end

  @doc """
  Splits a single text string into chunks.
  """
  @spec split_text(String.t(), pos_integer(), non_neg_integer(), String.t()) :: [String.t()]
  def split_text(
        text,
        chunk_size \\ @default_chunk_size,
        chunk_overlap \\ @default_chunk_overlap,
        separator \\ @default_separator
      ) do
    # First split by separator to get natural segments
    segments = String.split(text, separator)

    # Merge segments into chunks respecting chunk_size
    merge_segments(segments, chunk_size, chunk_overlap, separator)
  end

  defp merge_segments(segments, chunk_size, chunk_overlap, separator) do
    segments
    |> Enum.reduce({[], ""}, fn segment, {chunks, current} ->
      candidate =
        if current == "" do
          segment
        else
          current <> separator <> segment
        end

      if String.length(candidate) <= chunk_size do
        {chunks, candidate}
      else
        if current == "" do
          # Single segment exceeds chunk_size — force-split by characters
          forced = force_split(segment, chunk_size, chunk_overlap)
          {last, rest} = List.pop_at(forced, -1)
          {chunks ++ rest, last || ""}
        else
          # Save current chunk, start a new one with overlap
          overlap_text = get_overlap(current, chunk_overlap)
          new_current = overlap_text <> separator <> segment

          if String.length(new_current) <= chunk_size do
            {chunks ++ [String.trim(current)], new_current}
          else
            # Even with overlap + new segment it's too big, just start fresh
            {chunks ++ [String.trim(current)], segment}
          end
        end
      end
    end)
    |> finalize_chunks()
  end

  defp finalize_chunks({chunks, ""}) do
    chunks
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&(&1 == ""))
  end

  defp finalize_chunks({chunks, remaining}) do
    (chunks ++ [remaining])
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&(&1 == ""))
  end

  defp force_split(text, chunk_size, chunk_overlap) do
    text
    |> String.graphemes()
    |> Enum.chunk_every(chunk_size, chunk_size - chunk_overlap, [])
    |> Enum.map(&Enum.join/1)
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&(&1 == ""))
  end

  defp get_overlap(text, overlap_size) do
    text
    |> String.slice(-overlap_size, overlap_size)
  end
end
