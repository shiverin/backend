defmodule Cadet.Chatbot.PixelPromptBuilder do
  @moduledoc """
  The PixelPromptBuilder module is responsible for building the system prompt for the Pixel chatbot.
  Unlike Louis's PromptBuilder (SICP-specific), Pixel is a general-purpose context-aware assistant
  that uses page context from wherever the user currently is in Source Academy.
  """

  require Logger

  @prompt_prefix """
  You are Pixel, a helpful and friendly assistant for the Source Academy platform. \
  Source Academy is an educational platform for learning computer science, featuring \
  a Playground code editor (using the Source language, a subset of JavaScript), \
  assessments (missions, quests, paths), and various learning tools.

  The user is currently browsing a page on Source Academy. You will be given the actual \
  content they are seeing on their screen — this may include their code in the editor, \
  assessment questions they are working on, student submissions they are grading, \
  program output, and other page-specific data. Use this context to give accurate, \
  relevant answers.

  If the user asks about their code, refer to the code shown in the context. \
  If they ask about an assessment question, use the question text from the context. \
  Always be aware that the context represents what is literally on the user's screen right now.

  If the question is unrelated to Source Academy or computer science, you may still \
  help but gently guide them back to relevant topics.
  """

  @page_context_prefix "\n--- CONTENT CURRENTLY VISIBLE ON THE USER'S SCREEN ---\n"
  @page_type_prefix "\nPage type: "

  @doc """
  Builds the system prompt for Pixel with optional page context and page type.

  ## Parameters
    * `page_context` - Text content captured from the current page (can be nil or empty)
    * `page_type` - The type of page the user is on (e.g., "playground", "assessment", "grading")
  """
  def build_prompt(page_context \\ nil, page_type \\ nil) do
    page_type_section = build_page_type_section(page_type)
    context_section = build_context_section(page_context)

    @prompt_prefix <> page_type_section <> context_section
  end

  defp build_page_type_section(nil), do: ""
  defp build_page_type_section(""), do: ""

  defp build_page_type_section(page_type) do
    @page_type_prefix <> page_type <> "\n"
  end

  defp build_context_section(nil), do: ""
  defp build_context_section(""), do: ""

  defp build_context_section(page_context) do
    @page_context_prefix <> page_context
  end
end
