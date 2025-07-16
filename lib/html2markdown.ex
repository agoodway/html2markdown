defmodule Html2Markdown do
  @moduledoc """
  A library for converting HTML to Markdown syntax in Elixir

  ## Configuration Options

  The library supports configuration options via `convert/2`:

  - `:navigation_classes` - Customize which CSS classes identify navigation elements to remove
  - `:non_content_tags` - Customize which HTML tags to filter out during conversion
  - `:markdown_flavor` - Currently only `:basic` is supported (future enhancement)
  - `:normalize_whitespace` - Normalize whitespace in text content

  Note: HTML entity decoding is performed automatically by Floki for all content.
  Common entities like &amp;, &lt;, &gt;, &quot;, &#39;, &nbsp; and numeric entities
  are decoded to their corresponding characters.
  """

  alias Html2Markdown.{Options, Parser, Converter}

  @type html_content :: String.t()
  @type markdown_content :: String.t()
  @type conversion_options :: %{
          optional(:navigation_classes) => [String.t()],
          optional(:non_content_tags) => [String.t()],
          optional(:markdown_flavor) => :basic | :gfm,
          optional(:normalize_whitespace) => boolean()
        }

  @doc """
  Converts the content from an HTML document to Markdown (removing non-content sections and tags)

  Uses default options for conversion. To customize behavior, use `convert/2`.
  """
  @spec convert(html_content()) :: markdown_content()
  def convert(document) when is_binary(document) do
    convert(document, %{})
  end

  @doc """
  Converts the content from an HTML document to Markdown with custom options

  ## Options

    * `:navigation_classes` - List of CSS classes to identify navigation elements to remove.
      Defaults to `["footer", "menu", "nav", "sidebar", "aside"]`
    * `:non_content_tags` - List of HTML tags to filter out during conversion.
      Defaults to common non-content tags like script, style, form, etc.
    * `:markdown_flavor` - Markdown flavor to use. Currently only `:basic` is supported.
      Defaults to `:basic` (future enhancement for `:gfm`, `:commonmark`)
    * `:normalize_whitespace` - Whether to normalize whitespace. When enabled, multiple
      spaces/tabs are converted to single spaces and leading/trailing whitespace is trimmed.
      Whitespace in code blocks and inline code is always preserved. Defaults to `true`

  ## Examples

      iex> Html2Markdown.convert("<p>Hello</p>", %{navigation_classes: ["custom-nav"]})
      "\\nHello\\n"

  """
  @spec convert(html_content(), conversion_options()) :: markdown_content()
  def convert(document, options) when is_binary(document) and is_map(options) do
    opts = Options.merge(options)

    document
    |> Parser.preprocess_content(opts)
    |> Converter.convert_to_markdown(opts)
  end

  @spec convert(any(), any()) :: {:error, String.t()}
  def convert(_document, _options), do: {:error, "Could not convert HTML to Markdown"}
end
