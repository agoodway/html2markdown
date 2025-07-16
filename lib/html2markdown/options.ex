defmodule Html2Markdown.Options do
  @moduledoc """
  Handles configuration options for HTML to Markdown conversion.
  """

  @default_options %{
    navigation_classes: ["footer", "menu", "nav", "sidebar", "aside"],
    non_content_tags: [
      "aside",
      "audio",
      "base",
      "button",
      "datalist",
      "embed",
      "form",
      "iframe",
      "input",
      "keygen",
      "nav",
      "noscript",
      "object",
      "output",
      "script",
      "select",
      "source",
      "style",
      "svg",
      "template",
      "textarea",
      "track",
      "video"
    ],
    markdown_flavor: :basic,
    normalize_whitespace: true
  }

  @doc """
  Returns the default options map.
  """
  def defaults do
    @default_options
  end

  @doc """
  Merges user options with defaults.
  """
  def merge(user_options) when is_map(user_options) do
    Map.merge(@default_options, user_options)
  end
end
