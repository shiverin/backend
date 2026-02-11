defmodule Cadet.Chatbot.PromptBuilder do
  @moduledoc """
  The PromptBuilder module is responsible for building the prompt for the chatbot.
  Now supports optional RAG (Retrieval-Augmented Generation) context injection.
  """

  require Logger

  alias Cadet.Chatbot.SicpNotes
  alias Cadet.Chatbot.Rag

  @prompt_prefix """
  You are a competent tutor, assisting a student who is learning computer science following the textbook "Structure and Interpretation of Computer Programs, JavaScript edition". The student request is about a paragraph of the book. The request may be a follow-up request to a request that was posed to you previously.
  What follows are:
  (1) the summary of section (2) the full paragraph (3) additional retrieved context from course materials, if available. Please answer the student request,
  not the requests of the history. If the student request is not related to the book, ask them to ask questions that are related to the book. Do not say that I provide you text.

  """

  @query_prefix "\n(2) Here is the paragraph:\n"
  @rag_prefix "\n(3) Here is additional context retrieved from course materials (past exam questions, notes, etc.):\n"

  @doc """
  Builds the system prompt with SICP section summary, visible paragraph text,
  and optionally RAG-retrieved context based on the user's message.

  ## Parameters
    * `section` - The SICP section identifier
    * `context` - The visible paragraph text from the frontend
    * `user_message` - (optional) The user's question, used to retrieve RAG context
  """
  def build_prompt(section, context, user_message \\ nil) do
    section_summary = SicpNotes.get_summary(section)

    section_prefix =
      case section_summary do
        nil ->
          "\n(1) There is no section summary for this section. Please answer the question based on the following paragraph.\n"

        summary ->
          "\n(1) Here is the summary of this section:\n" <> summary
      end

    rag_context = retrieve_rag_context(user_message)

    @prompt_prefix <> section_prefix <> @query_prefix <> context <> rag_context
  end

  defp retrieve_rag_context(nil), do: ""

  defp retrieve_rag_context(user_message) do
    if Rag.store_count() > 0 do
      case Rag.retrieve_context(user_message, top_k: 10) do
        {:ok, context} when context != "" ->
          Logger.info(
            "RAG context injected into prompt for query: #{String.slice(user_message, 0..50)}"
          )

          IO.puts("RAG retrieved:\n#{context}")
          @rag_prefix <> context

        _ ->
          Logger.info("No RAG context available, proceeding without it")
          IO.puts("No RAG context retrieved")
          ""
      end
    else
      IO.puts("No RAG store available (store_count = 0)")
      ""
    end
  end
end
