defmodule Html2MarkdownTest do
  use ExUnit.Case
  doctest Html2Markdown

  @fixture_path "test/support/fixtures/"

  test "convert a HTML document to Markdown" do
    {:ok, html} = File.read(@fixture_path <> "elixir.html")
    {:ok, markdown} = File.read(@fixture_path <> "elixir.md")

    assert Html2Markdown.convert(html) == markdown
  end
end
