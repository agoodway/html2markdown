defmodule Html2Markdown.ParagraphSpacingTest do
  use ExUnit.Case, async: true

  describe "paragraph spacing - issue #6" do
    test "consecutive paragraphs should have clean spacing" do
      # This is the exact test case from issue #6
      input = "<p>First paragraph.</p><p>Second paragraph.</p>"

      result = Html2Markdown.convert(input)
      expected = "First paragraph.\n\nSecond paragraph."

      assert result == expected, """
      Expected clean spacing between paragraphs
      Expected: #{inspect(expected)}
      Actual:   #{inspect(result)}
      """
    end

    test "single paragraph should not have extra newlines" do
      input = "<p>Single paragraph.</p>"

      result = Html2Markdown.convert(input)
      expected = "Single paragraph."

      assert result == expected, "Single paragraph should be clean"
    end

    test "three consecutive paragraphs" do
      input = "<p>First.</p><p>Second.</p><p>Third.</p>"

      result = Html2Markdown.convert(input)
      expected = "First.\n\nSecond.\n\nThird."

      assert result == expected
    end

    test "empty paragraph handling" do
      input = "<p></p><p>Content</p><p></p>"

      result = Html2Markdown.convert(input)
      expected = "Content"

      assert result == expected, "Empty paragraphs should be ignored"
    end

    test "paragraph with only whitespace" do
      input = "<p>   </p><p>Content</p><p>  \n  </p>"

      result = Html2Markdown.convert(input)
      expected = "Content"

      assert result == expected
    end
  end

  describe "mixed content spacing" do
    test "paragraph followed by header" do
      input = "<p>A paragraph.</p><h1>A header</h1>"

      result = Html2Markdown.convert(input)
      expected = "A paragraph.\n\n# A header"

      assert result == expected
    end

    test "header followed by paragraph" do
      input = "<h1>Header</h1><p>Paragraph content.</p>"

      result = Html2Markdown.convert(input)
      expected = "# Header\n\nParagraph content."

      assert result == expected
    end

    test "paragraph with list" do
      input = """
      <p>Introduction:</p>
      <ul>
        <li>Item 1</li>
        <li>Item 2</li>
      </ul>
      <p>Conclusion.</p>
      """

      result = Html2Markdown.convert(input)
      expected = "Introduction:\n\n- Item 1\n- Item 2\n\nConclusion."

      assert result == expected
    end

    test "complex mixed content" do
      input = """
      <h1>Title</h1>
      <p>First paragraph with <strong>bold</strong> text.</p>
      <p>Second paragraph with <em>italic</em> text.</p>
      <h2>Subtitle</h2>
      <p>Another paragraph.</p>
      <pre><code>some code</code></pre>
      <p>Final paragraph.</p>
      """

      result = Html2Markdown.convert(input)

      expected =
        """
        # Title

        First paragraph with **bold** text.

        Second paragraph with *italic* text.

        ## Subtitle

        Another paragraph.

        ```
        some code
        ```

        Final paragraph.
        """
        |> String.trim()

      assert result == expected
    end
  end

  describe "inline formatting within paragraphs" do
    test "paragraph with multiple inline elements" do
      input = "<p>Text with <strong>bold</strong>, <em>italic</em>, and <code>code</code>.</p>"

      result = Html2Markdown.convert(input)
      expected = "Text with **bold**, *italic*, and `code`."

      assert result == expected
    end

    test "nested inline elements" do
      input = "<p>This is <strong>bold with <em>italic</em> inside</strong>.</p>"

      result = Html2Markdown.convert(input)
      expected = "This is **bold with *italic* inside**."

      assert result == expected
    end

    test "paragraph with links" do
      input =
        "<p>Check out <a href=\"https://elixir-lang.org\">Elixir</a> and <a href=\"https://phoenixframework.org\">Phoenix</a>.</p>"

      result = Html2Markdown.convert(input)

      expected =
        "Check out [Elixir](https://elixir-lang.org) and [Phoenix](https://phoenixframework.org)."

      assert result == expected
    end
  end

  describe "edge cases" do
    test "deeply nested paragraphs" do
      input = "<div><section><article><p>Nested paragraph.</p></article></section></div>"

      result = Html2Markdown.convert(input)
      expected = "Nested paragraph."

      assert result == expected
    end

    test "paragraph with br tags" do
      input = "<p>Line one<br>Line two<br>Line three</p>"

      result = Html2Markdown.convert(input)
      expected = "Line one  \nLine two  \nLine three"

      assert result == expected
    end

    test "multiple paragraphs with various spacing" do
      input = """
      <p>First paragraph.</p>


      <p>Second paragraph after multiple newlines.</p>
      <p>Third paragraph immediately after.</p>
      """

      result = Html2Markdown.convert(input)

      expected =
        "First paragraph.\n\nSecond paragraph after multiple newlines.\n\nThird paragraph immediately after."

      assert result == expected
    end
  end
end
