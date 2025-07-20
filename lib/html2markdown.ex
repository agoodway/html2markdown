defmodule Html2Markdown do
  @moduledoc """
  Convert HTML documents to clean, readable Markdown.

  Html2Markdown intelligently extracts content from HTML while filtering out
  navigation, advertisements, and other non-content elements. It's designed
  for web scraping, content migration, and any scenario where you need to
  convert HTML to Markdown.

  ## Basic Usage

      iex> Html2Markdown.convert("<h1>Hello</h1><p>World</p>")
      "# Hello\\n\\nWorld"

  ## Configuration

  The library supports extensive configuration through the second parameter:

      Html2Markdown.convert(html, %{
        navigation_classes: ["nav", "menu", "sidebar"],
        non_content_tags: ["script", "style", "iframe"],
        markdown_flavor: :basic,
        normalize_whitespace: true
      })

  ## Features

  - **Smart filtering** - Automatically removes common non-content elements
  - **HTML5 support** - Handles modern semantic elements
  - **Table conversion** - Converts HTML tables to Markdown tables
  - **Entity decoding** - Automatically handled by Floki
  - **Whitespace normalization** - Optional cleanup of excessive whitespace
  - **Configurable** - Customize filtering behavior to your needs

  ## Examples

  ### Web Scraping

      # Extract article content from a web page
      {:ok, %{body: html}} = HTTPoison.get("https://example.com/article")
      
      content = Html2Markdown.convert(html, %{
        navigation_classes: ["header", "footer", "nav", "sidebar"],
        normalize_whitespace: true
      })

  ### Content Migration

      # Convert WordPress posts to Markdown
      post_html
      |> Html2Markdown.convert()
      |> File.write!("post.md")

  ### Email Processing

      # Clean up HTML emails
      email_body
      |> Html2Markdown.convert(%{
        non_content_tags: ["style", "meta", "link"],
        navigation_classes: ["unsubscribe", "footer"]
      })

  ## Supported HTML Elements

  ### Text Elements
  - Headings: `<h1>` through `<h6>`
  - Paragraphs: `<p>`
  - Emphasis: `<em>`, `<i>` → `*italic*`
  - Strong: `<strong>`, `<b>` → `**bold**`
  - Strikethrough: `<del>` → `~~strikethrough~~`
  - Code: `<code>` → `` `code` ``
  - Preformatted: `<pre>` → ``` code blocks ```

  ### Lists
  - Unordered lists: `<ul>`, `<li>` → `- item`
  - Ordered lists: `<ol>`, `<li>` → `1. item`
  - Definition lists: `<dl>`, `<dt>`, `<dd>`

  ### Links and Media
  - Links: `<a href="...">` → `[text](url)`
  - Images: `<img>` → `![alt](src)`
  - Picture: `<picture>` with fallback to `<img>`

  ### Tables
  Full support for HTML tables with automatic header detection:

      <table>
        <tr><th>Name</th><th>Value</th></tr>
        <tr><td>Elixir</td><td>1.15</td></tr>
      </table>

  Converts to:

      | Name | Value |
      | --- | --- |
      | Elixir | 1.15 |

  ### HTML5 Elements
  - `<details>` / `<summary>` - Collapsible sections
  - `<mark>` - Highlighted text (GFM: `==marked==`)
  - `<abbr title="...">` - Abbreviations with expansion
  - `<cite>` - Citations in italics
  - `<q cite="...">` - Inline quotes with optional citation
  - `<time datetime="...">` - Time with preserved datetime
  - `<video>` - Converted to markdown link

  ## Entity Handling

  HTML entities are automatically decoded by Floki:
  - `&amp;` → `&`
  - `&lt;` → `<`
  - `&gt;` → `>`
  - `&nbsp;` → non-breaking space
  - `&#123;` → `{`
  - `&#xAB;` → `«`
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
      "Hello"

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
