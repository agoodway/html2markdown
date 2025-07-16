# Html2Markdown

[![Hex.pm](https://img.shields.io/hexpm/v/html2markdown.svg)](https://hex.pm/packages/html2markdown)
[![Hex Docs](https://img.shields.io/badge/hex-docs-purple.svg)](https://hexdocs.pm/html2markdown)
[![License](https://img.shields.io/hexpm/l/html2markdown.svg)](https://github.com/cpursley/html2markdown/blob/main/LICENSE)

Convert HTML to clean, readable Markdown. Designed for content extraction, this library intelligently handles common HTML patterns while filtering out non-content elements like navigation and and scripts.

## Installation

Add `html2markdown` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:html2markdown, "~> 0.2.0"}
  ]
end
```

## Quick Start

```elixir
# Basic conversion
Html2Markdown.convert("<h1>Hello World</h1><p>Welcome to <strong>Elixir</strong>!</p>")
# => "\n# Hello World\n\n\n\nWelcome to **Elixir**!\n"

# With custom options
Html2Markdown.convert(html, %{
  navigation_classes: ["nav", "menu", "custom-nav"],
  normalize_whitespace: true
})
```

## Features

- **Smart Content Extraction**: Automatically removes navigation, ads, and other non-content elements
- **HTML5 Support**: Handles modern semantic elements like `<details>`, `<mark>`, `<time>`
- **Table Conversion**: Converts HTML tables to clean Markdown tables
- **Entity Handling**: Properly decodes HTML entities (`&amp;`, `&lt;`, `&nbsp;`, etc.)
- **Configurable**: Customize filtering and processing behavior

## Configuration Options

```elixir
Html2Markdown.convert(html, %{
  # CSS classes that identify navigation elements to remove
  navigation_classes: ["footer", "menu", "nav", "sidebar", "aside"],
  
  # HTML tags to filter out during conversion
  non_content_tags: ["script", "style", "form", "nav", ...],
  
  # Markdown flavor (currently :basic, future: :gfm, :commonmark)
  markdown_flavor: :basic,
  
  # Normalize whitespace (collapses multiple spaces, trims)
  normalize_whitespace: true
})
```

## Common Use Cases

### Web Scraping
Extract readable content from web pages:

```elixir
{:ok, %{body: html}} = HTTPoison.get(url)
markdown = Html2Markdown.convert(html)
```

### Content Migration
Convert existing HTML content to Markdown:

```elixir
# Convert blog posts from HTML to Markdown
html_content
|> Html2Markdown.convert(%{normalize_whitespace: true})
|> save_as_markdown()
```

### Email Processing
Clean up HTML emails for plain text storage:

```elixir
email_html
|> Html2Markdown.convert(%{
  non_content_tags: ["style", "script", "meta"],
  navigation_classes: ["unsubscribe", "footer"]
})
```

## Supported Elements

- **Headings**: `<h1>` through `<h6>`
- **Text**: Paragraphs, emphasis (`<em>`, `<i>`), strong (`<strong>`, `<b>`)
- **Lists**: Ordered and unordered lists with nesting
- **Links**: `<a>` tags with proper URL handling
- **Images**: `<img>` and `<picture>` elements
- **Code**: Both inline `<code>` and block `<pre>` elements
- **Tables**: Full table support with headers
- **Quotes**: `<blockquote>` and `<q>` elements
- **HTML5**: `<details>`, `<summary>`, `<mark>`, `<abbr>`, `<cite>`, `<time>`, `<video>`

## Documentation

Full documentation is available at [https://hexdocs.pm/html2markdown](https://hexdocs.pm/html2markdown).

## License

MIT License - see [LICENSE](LICENSE) file for details.

