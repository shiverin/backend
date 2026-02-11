defmodule Cadet.Chatbot.Rag.Embeddings do
  @moduledoc """
  Generates vector embeddings using the OpenAI Embeddings API.

  Analogous to LangChain's OpenAIEmbeddings. Calls the OpenAI
  `text-embedding-3-small` model (configurable) to produce dense
  vector representations of text chunks.

  Uses HTTPoison (already a project dependency) to call the API directly,
  since the `openai` hex package does not expose an embeddings endpoint.
  """

  require Logger

  @default_model "text-embedding-3-small"
  @openai_embeddings_url "https://api.openai.com/v1/embeddings"

  @doc """
  Generates an embedding vector for a single text string.

  Returns `{:ok, vector}` where vector is a list of floats,
  or `{:error, reason}`.
  """
  @spec generate(String.t(), keyword()) :: {:ok, [float()]} | {:error, String.t()}
  def generate(text, opts \\ []) do
    model = Keyword.get(opts, :model, @default_model)
    api_key = get_api_key()

    body = Jason.encode!(%{input: text, model: model})

    headers = [
      {"Content-Type", "application/json"},
      {"Authorization", "Bearer #{api_key}"}
    ]

    http_opts = get_http_options()

    case HTTPoison.post(@openai_embeddings_url, body, headers, http_opts) do
      {:ok, %HTTPoison.Response{status_code: 200, body: resp_body}} ->
        case Jason.decode(resp_body) do
          {:ok, %{"data" => [%{"embedding" => embedding} | _]}} ->
            {:ok, embedding}

          {:ok, unexpected} ->
            Logger.error("Unexpected embedding response format: #{inspect(unexpected)}")
            {:error, "Unexpected response format from OpenAI embeddings API"}

          {:error, decode_err} ->
            {:error, "Failed to decode embedding response: #{inspect(decode_err)}"}
        end

      {:ok, %HTTPoison.Response{status_code: status, body: resp_body}} ->
        error_msg =
          case Jason.decode(resp_body) do
            {:ok, %{"error" => %{"message" => msg}}} -> msg
            _ -> "HTTP #{status}"
          end

        Logger.error("OpenAI Embeddings API error (HTTP #{status}): #{error_msg}")
        {:error, "OpenAI API error: #{error_msg}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        Logger.error("HTTP request failed for embeddings: #{inspect(reason)}")
        {:error, "HTTP request failed: #{inspect(reason)}"}
    end
  end

  @doc """
  Generates embeddings for a batch of texts.

  Calls the OpenAI API once per text (the batch endpoint accepts a list of
  inputs but we process individually for clearer error handling).

  Returns `{:ok, [{text, vector}]}` or `{:error, reason}` on the first failure.
  """
  @spec generate_batch([String.t()], keyword()) ::
          {:ok, [{String.t(), [float()]}]} | {:error, String.t()}
  def generate_batch(texts, opts \\ []) do
    model = Keyword.get(opts, :model, @default_model)
    api_key = get_api_key()

    # Use batch API for efficiency — send all texts at once
    body = Jason.encode!(%{input: texts, model: model})

    headers = [
      {"Content-Type", "application/json"},
      {"Authorization", "Bearer #{api_key}"}
    ]

    http_opts = get_http_options()

    case HTTPoison.post(@openai_embeddings_url, body, headers, http_opts) do
      {:ok, %HTTPoison.Response{status_code: 200, body: resp_body}} ->
        case Jason.decode(resp_body) do
          {:ok, %{"data" => data}} when is_list(data) ->
            # Sort by index to maintain order
            sorted =
              data
              |> Enum.sort_by(& &1["index"])
              |> Enum.map(& &1["embedding"])

            pairs = Enum.zip(texts, sorted)
            {:ok, pairs}

          {:ok, unexpected} ->
            {:error, "Unexpected batch response: #{inspect(unexpected)}"}

          {:error, decode_err} ->
            {:error, "Failed to decode batch response: #{inspect(decode_err)}"}
        end

      {:ok, %HTTPoison.Response{status_code: status, body: resp_body}} ->
        error_msg =
          case Jason.decode(resp_body) do
            {:ok, %{"error" => %{"message" => msg}}} -> msg
            _ -> "HTTP #{status}"
          end

        Logger.error("OpenAI batch embeddings error (HTTP #{status}): #{error_msg}")
        {:error, "OpenAI API error: #{error_msg}"}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, "HTTP request failed: #{inspect(reason)}"}
    end
  end

  @doc """
  Returns the dimensionality of the configured embedding model.
  text-embedding-3-small produces 1536-dimensional vectors.
  """
  @spec dimensions() :: pos_integer()
  def dimensions, do: 1536

  defp get_api_key do
    Application.get_env(:openai, :api_key) ||
      raise "OpenAI API key not configured. Set :openai, :api_key in config."
  end

  defp get_http_options do
    default_opts = [recv_timeout: 60_000, timeout: 60_000]
    configured = Application.get_env(:openai, :http_options, [])
    Keyword.merge(default_opts, configured)
  end
end
