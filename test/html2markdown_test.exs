defmodule Html2MarkdownTest do
  use ExUnit.Case
  doctest Html2Markdown

  @fixture_path "test/support/fixtures/"

  test "convert a HTML document to Markdown" do
    {:ok, html} = File.read(@fixture_path <> "elixir.html")
    {:ok, markdown} = File.read(@fixture_path <> "elixir.md")

    assert Html2Markdown.convert(html) == markdown
  end

  test "convert a HTML fragment to Markdown" do
    fragment = """
    <p>The <strong>bold</strong> flavors of aged cheddar, the <em>subtle</em> notes of brie, and the <del>stinky</del> <em>aromatic</em> presence of blue cheese make for an <code>unforgettable</code> culinary experience.</p>
    """

    markdown =
      "The **bold** flavors of aged cheddar, the *subtle* notes of brie, and the ~~stinky~~ *aromatic* presence of blue cheese make for an `unforgettable` culinary experience."

    assert Html2Markdown.convert(fragment) == markdown
  end
end
