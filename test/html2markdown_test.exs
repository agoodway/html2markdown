defmodule Html2MarkdownTest do
  use ExUnit.Case
  doctest Html2Markdown

  @fixture_path "test/support/fixtures/"

  describe "convert a HTML document to Markdown" do
    test "convert elixir-lang HTML document to Markdown" do
      {:ok, html} = File.read(@fixture_path <> "elixir.html")
      {:ok, markdown} = File.read(@fixture_path <> "elixir.md")

      assert Html2Markdown.convert(html) == markdown
    end

    test "convert wikipedia HTML document to Markdown" do
      {:ok, html} = File.read(@fixture_path <> "wikipedia.html")
      {:ok, markdown} = File.read(@fixture_path <> "wikipedia.md")

      assert Html2Markdown.convert(html) == markdown
    end
  end

  test "convert a HTML fragment to Markdown" do
    fragment = """
    <p>The <strong>bold</strong> flavors of aged cheddar, the <em>subtle</em> notes of brie, and the <del>stinky</del> <em>aromatic</em> presence of blue cheese make for an <code>unforgettable</code> culinary experience.</p>
    """

    markdown =
      "The **bold** flavors of aged cheddar, the *subtle* notes of brie, and the ~~stinky~~ *aromatic* presence of blue cheese make for an `unforgettable` culinary experience."

    assert Html2Markdown.convert(fragment) == markdown
  end

  test "handle <picture>" do
    fragment = """
    <p>
      <picture>
        <source type="image/avif" srcset="/img/ocmxZOf3tv-792.avif 792w">
        <source type="image/webp" srcset="/img/ocmxZOf3tv-792.webp 792w">
        <p>a stray paragraph</p>
        <img alt="a shadow" loading="lazy" decoding="async"
            src="https://upload.wikimedia.org/wikipedia/commons/thumb/3/31/Bombina_bombina_1_%28Marek_Szczepanek%29.jpg/440px-Bombina_bombina_1_%28Marek_Szczepanek%29.jpg"
            width="792" height="528">
      </picture>
    </p>
    """

    markdown =
      "![a shadow](https://upload.wikimedia.org/wikipedia/commons/thumb/3/31/Bombina_bombina_1_%28Marek_Szczepanek%29.jpg/440px-Bombina_bombina_1_%28Marek_Szczepanek%29.jpg)"

    assert Html2Markdown.convert(fragment) == markdown
  end
end
