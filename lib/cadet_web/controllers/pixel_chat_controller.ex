defmodule CadetWeb.PixelChatController do
  @moduledoc """
  Handles the Pixel chatbot conversation API endpoints.
  Each user has exactly one Pixel conversation.
  Pixel is a general-purpose context-aware chatbot that appears on all pages except SICP.
  """
  use CadetWeb, :controller
  use PhoenixSwagger
  require Logger

  alias Cadet.Chatbot.{PixelConversation, PixelConversations}
  @max_content_size 1000

  def init_chat(conn, _params) do
    user = conn.assigns.current_user
    Logger.info("Pixel: Initializing chat for user #{user.id}")

    case PixelConversations.get_or_create_conversation(user.id) do
      {:ok, conversation} ->
        Logger.info(
          "Pixel: Chat initialized successfully for user #{user.id}. Conversation ID: #{conversation.id}."
        )

        conn
        |> put_status(:ok)
        |> render("conversation_init.json", %{
          conversation_id: conversation.id,
          messages: conversation.messages,
          max_content_size: @max_content_size
        })

      {:error, error_message} ->
        Logger.error(
          "Pixel: Failed to initialize chat for user #{user.id}. Error: #{error_message}."
        )

        send_resp(conn, :unprocessable_entity, error_message)
    end
  end

  swagger_path :chat do
    put("/pixel")

    summary("Pixel chatbot — general-purpose context-aware assistant")

    security([%{JWT: []}])

    consumes("application/json")

    parameters do
      message(
        :body,
        :list,
        "User message to send to the Pixel chatbot. Each user has a single conversation."
      )
    end

    response(200, "OK")
    response(400, "Missing or invalid parameter(s)")
    response(401, "Unauthorized")
    response(404, "No conversation found for user")
    response(422, "Message exceeds the maximum allowed length")
    response(500, "When OpenAI API returns an error")
  end

  def chat(conn, %{
        "message" => user_message,
        "pageContext" => page_context,
        "pageType" => page_type
      }) do
    user = conn.assigns.current_user

    Logger.info(
      "Pixel: Processing chat message for user #{user.id}. Message length: #{String.length(user_message)}."
    )

    with true <- String.length(user_message) <= @max_content_size || {:error, :message_too_long},
         {:ok, conversation} <- PixelConversations.get_conversation_for_user(user.id),
         {:ok, updated_conversation} <-
           PixelConversations.add_message(conversation, "user", user_message),
         system_prompt <-
           Cadet.Chatbot.PixelPromptBuilder.build_prompt(page_context, page_type),
         payload <- generate_payload(updated_conversation, system_prompt) do
      case OpenAI.chat_completion(model: "gpt-4", messages: payload) do
        {:ok, result_map} ->
          choices = Map.get(result_map, :choices, [])
          bot_message = Enum.at(choices, 0)["message"]["content"]

          case PixelConversations.add_message(updated_conversation, "assistant", bot_message) do
            {:ok, _} ->
              Logger.info(
                "Pixel: Chat message processed successfully for user #{user.id}, conversation #{conversation.id}."
              )

              render(conn, "conversation.json", %{
                conversation_id: conversation.id,
                response: bot_message
              })

            {:error, error_message} ->
              Logger.error(
                "Pixel: Failed to save bot response for user #{user.id}, conversation #{conversation.id}: #{error_message}."
              )

              send_resp(conn, 500, error_message)
          end

        {:error, reason} ->
          error_message = reason["error"]["message"]

          Logger.error(
            "Pixel: OpenAI API error for user #{user.id}, conversation #{conversation.id}: #{error_message}."
          )

          PixelConversations.add_error_message(updated_conversation)
          send_resp(conn, 500, error_message)
      end
    else
      {:error, :message_too_long} ->
        Logger.error(
          "Pixel: Message too long for user #{user.id}. Length: #{String.length(user_message)}."
        )

        send_resp(
          conn,
          :unprocessable_entity,
          "Message exceeds the maximum allowed length of #{@max_content_size}"
        )

      {:error, {:not_found, error_message}} ->
        Logger.error(
          "Pixel: No conversation found for user #{user.id}. User must init_chat first."
        )

        send_resp(conn, :not_found, error_message)

      {:error, error_message} ->
        Logger.error("Pixel: An error occurred for user #{user.id}. Error: #{error_message}.")
        send_resp(conn, 500, error_message)
    end
  end

  @context_size 10

  @spec generate_payload(PixelConversation.t(), String.t()) :: list(map())
  defp generate_payload(conversation, system_prompt) do
    system_context = [%{role: "system", content: system_prompt}]

    messages_payload =
      conversation.messages
      |> Enum.reverse()
      |> Enum.take(@context_size)
      |> Enum.map(&Map.take(&1, [:role, :content, "role", "content"]))
      |> Enum.reverse()

    system_context ++ messages_payload
  end

  def max_content_length, do: @max_content_size
end
