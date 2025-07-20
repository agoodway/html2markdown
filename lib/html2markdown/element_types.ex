defmodule Html2Markdown.ElementTypes do
  @moduledoc """
  Provides element type classification for HTML to Markdown conversion.

  This module categorizes HTML elements into block, inline, and other types
  to enable proper spacing and formatting decisions during conversion.
  """

  @block_elements ~w[
    p div h1 h2 h3 h4 h5 h6 ul ol li blockquote pre
    article section aside header footer main nav
    table tr td th thead tbody tfoot
    dl dt dd figure figcaption
    details summary
  ]

  @inline_elements ~w[
    a em strong code span i b u del sup sub
    img br hr abbr cite q time mark
  ]

  @list_elements ~w[ul ol li]

  @heading_elements ~w[h1 h2 h3 h4 h5 h6]

  @doc """
  Determines if an HTML element is a block-level element.

  Block elements typically start on a new line and take up the full width
  available. They should be separated by blank lines in markdown.

  ## Examples

      iex> Html2Markdown.ElementTypes.block_element?("p")
      true

      iex> Html2Markdown.ElementTypes.block_element?("span")
      false
  """
  @spec block_element?(String.t()) :: boolean()
  def block_element?(tag) when tag in @block_elements, do: true
  def block_element?(_), do: false

  @doc """
  Determines if an HTML element is an inline element.

  Inline elements flow within text and don't create line breaks.
  They should not have extra spacing added around them.

  ## Examples

      iex> Html2Markdown.ElementTypes.inline_element?("em")
      true

      iex> Html2Markdown.ElementTypes.inline_element?("p")
      false
  """
  @spec inline_element?(String.t()) :: boolean()
  def inline_element?(tag) when tag in @inline_elements, do: true
  def inline_element?(_), do: false

  @doc """
  Determines if an HTML element is a list element.

  ## Examples

      iex> Html2Markdown.ElementTypes.list_element?("ul")
      true

      iex> Html2Markdown.ElementTypes.list_element?("li")
      true

      iex> Html2Markdown.ElementTypes.list_element?("p")
      false
  """
  @spec list_element?(String.t()) :: boolean()
  def list_element?(tag) when tag in @list_elements, do: true
  def list_element?(_), do: false

  @doc """
  Determines if an HTML element is a heading element.

  ## Examples

      iex> Html2Markdown.ElementTypes.heading_element?("h1")
      true

      iex> Html2Markdown.ElementTypes.heading_element?("h7")
      false
  """
  @spec heading_element?(String.t()) :: boolean()
  def heading_element?(tag) when tag in @heading_elements, do: true
  def heading_element?(_), do: false

  @doc """
  Determines if an element should be treated as content.

  This is used to filter out empty text nodes, comments, etc.
  """
  @spec content_node?(Floki.html_node()) :: boolean()
  def content_node?({:comment, _}), do: false
  def content_node?({tag, _, _}) when is_binary(tag), do: true

  def content_node?(text) when is_binary(text) do
    String.trim(text) != ""
  end

  def content_node?(_), do: false

  @doc """
  Determines if processed content is empty.

  Used to filter out elements that produce no markdown output.
  """
  @spec empty_content?(iodata()) :: boolean()
  def empty_content?([]), do: true
  def empty_content?(""), do: true

  def empty_content?(content) when is_binary(content) do
    String.trim(content) == ""
  end

  def empty_content?(content) when is_list(content) do
    content
    |> IO.iodata_to_binary()
    |> String.trim()
    |> then(&(&1 == ""))
  end

  def empty_content?(_), do: false
end
