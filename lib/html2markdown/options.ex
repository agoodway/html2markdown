defmodule Html2Markdown.Options do
  @moduledoc """
  Handles configuration options for HTML to Markdown conversion.

  ## Available Options

  - `:navigation_classes` - List of CSS classes that identify navigation elements to remove.
    Default: `["footer", "menu", "nav", "sidebar", "aside"]`

  - `:non_content_tags` - List of HTML tags to filter out completely.
    Default includes tags like `script`, `style`, `iframe`, etc.

  - `:markdown_flavor` - The markdown variant to generate.
    Currently only `:basic` is supported. Future versions may support `:gfm` and `:commonmark`.

  - `:normalize_whitespace` - Whether to collapse multiple spaces and trim whitespace.
    Default: `true`. Code blocks always preserve whitespace regardless of this setting.

  ## Examples

      # Use all defaults
      options = Options.defaults()

      # Merge custom options with defaults
      custom = Options.merge(%{
        navigation_classes: ["custom-nav", "advertisement"],
        normalize_whitespace: false
      })
  """

  @type t :: %{
          navigation_classes: [String.t()],
          non_content_tags: [String.t()],
          markdown_flavor: :basic | :gfm,
          normalize_whitespace: boolean()
        }

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
      "track"
    ],
    markdown_flavor: :basic,
    normalize_whitespace: true
  }

  @doc """
  Returns the default options map.
  """
  @spec defaults() :: t()
  def defaults do
    @default_options
  end

  @doc """
  Merges user options with defaults.
  """
  @spec merge(map()) :: t()
  def merge(user_options) when is_map(user_options) do
    Map.merge(@default_options, user_options)
  end
end
