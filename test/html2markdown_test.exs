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

    expected =
      "The **bold** flavors of aged cheddar, the *subtle* notes of brie, and the ~~stinky~~ *aromatic* presence of blue cheese make for an `unforgettable` culinary experience."

    assert Html2Markdown.convert(fragment) == expected
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

    expected =
      "![a shadow](https://upload.wikimedia.org/wikipedia/commons/thumb/3/31/Bombina_bombina_1_%28Marek_Szczepanek%29.jpg/440px-Bombina_bombina_1_%28Marek_Szczepanek%29.jpg)"

    # The p tag adds newlines, so we just check if the image markdown is contained
    assert String.contains?(Html2Markdown.convert(fragment), expected)
  end

  describe "whitespace normalization" do
    test "normalizes multiple spaces to single space" do
      html = """
      <p>This    has     multiple    spaces     between    words.</p>
      <p>This	has	tabs	between	words.</p>
      """

      # Paragraphs are joined with \n \n (space between newlines)
      expected = "This has multiple spaces between words.\n \nThis has tabs between words."

      assert Html2Markdown.convert(html) == expected
    end

    test "removes leading and trailing whitespace from block elements" do
      html = """
      <p>   Leading and trailing spaces   </p>
      <h1>   Header with spaces   </h1>
      """

      # Paragraph and header are joined with \n\n, header adds its own \n prefix/suffix
      expected = "Leading and trailing spaces\n\n# Header with spaces\n"

      assert Html2Markdown.convert(html) == expected
    end

    test "preserves whitespace in code blocks" do
      html = """
      <pre><code>def example do
        # Indentation preserved
          nested_code
      end</code></pre>
      """

      expected = "\n```\ndef example do\n  # Indentation preserved\n    nested_code\nend\n```\n"

      assert Html2Markdown.convert(html) == expected
    end

    test "preserves whitespace in inline code" do
      html = """
      <p>Use <code>  spaced  code  </code> for examples.</p>
      """

      # Paragraph without extra newlines
      expected = "Use `  spaced  code  ` for examples."

      assert Html2Markdown.convert(html) == expected
    end

    test "whitespace normalization can be disabled" do
      html = """
      <p>This    has     multiple    spaces.</p>
      """

      result = Html2Markdown.convert(html, %{normalize_whitespace: false})

      # When disabled, spaces should be preserved (though still trimmed by process_children)
      assert String.contains?(result, "This    has     multiple    spaces.")
    end
  end

  describe "configuration options" do
    test "pre blocks always preserve whitespace" do
      html = "<pre>  Multiple    spaces   </pre>"

      # Pre blocks should preserve whitespace even with normalize_whitespace: true (default)
      result = Html2Markdown.convert(html)
      assert String.contains?(result, "```\n  Multiple    spaces   \n```")

      # Should also work with normalize_whitespace: false
      result = Html2Markdown.convert(html, %{normalize_whitespace: false})
      assert String.contains?(result, "  Multiple    spaces   ")
    end

    test "normalize_whitespace option" do
      html = """
      <p>Multiple    spaces     between    words</p>
      <p>  Leading and trailing spaces  </p>
      <div>
        Block element
        with newlines
      </div>
      <pre>  Preserve    whitespace   in   pre  </pre>
      <code>  Keep   spaces   in   code  </code>
      """

      # Default behavior - normalize_whitespace is true
      result = Html2Markdown.convert(html)
      assert String.contains?(result, "Multiple spaces between words")
      assert String.contains?(result, "Leading and trailing spaces")
      assert String.contains?(result, "Block element\nwith newlines")
      assert String.contains?(result, "```\n  Preserve    whitespace   in   pre  \n```")
      assert String.contains?(result, "`  Keep   spaces   in   code  `")

      # With normalize_whitespace disabled
      result = Html2Markdown.convert(html, %{normalize_whitespace: false})
      assert String.contains?(result, "Multiple    spaces     between    words")
      assert String.contains?(result, "  Leading and trailing spaces  ")
    end

    test "custom navigation_classes option" do
      html = """
      <div>
        <nav class="navigation">Navigation content</nav>
        <div class="custom-header">Custom header content</div>
        <div class="content">Main content</div>
        <div class="sidebar">Sidebar content</div>
      </div>
      """

      # Default behavior - removes nav tag and elements with default navigation classes (including "sidebar")
      result = Html2Markdown.convert(html)
      assert String.contains?(result, "Custom header content")
      assert String.contains?(result, "Main content")
      assert not String.contains?(result, "Navigation content")
      # Default includes "sidebar"
      assert not String.contains?(result, "Sidebar content")

      # With custom navigation classes
      result = Html2Markdown.convert(html, %{navigation_classes: ["custom-header"]})
      assert not String.contains?(result, "Custom header content")
      assert String.contains?(result, "Main content")
      # No longer filtered since we replaced defaults
      assert String.contains?(result, "Sidebar content")
    end

    test "custom non_content_tags option" do
      html = """
      <div>
        <p>Regular content</p>
        <custom-tag>Custom tag content</custom-tag>
        <script>alert('hello');</script>
      </div>
      """

      # Default behavior - removes script but not custom-tag
      result = Html2Markdown.convert(html)
      assert String.contains?(result, "Regular content")
      assert String.contains?(result, "Custom tag content")
      assert not String.contains?(result, "alert")

      # With custom non-content tags
      result = Html2Markdown.convert(html, %{non_content_tags: ["custom-tag", "script"]})
      assert String.contains?(result, "Regular content")
      assert not String.contains?(result, "Custom tag content")
      assert not String.contains?(result, "alert")
    end
  end

  describe "paragraph conversion" do
    test "convert consecutive paragraphs matches 0.1.6 behavior" do
      input = "<p>First paragraph.</p><p>Second paragraph.</p>"
      
      # Expected behavior from version 0.1.6 (now restored)
      expected = "First paragraph.\n \nSecond paragraph."
      
      result = Html2Markdown.convert(input)
      
      assert result == expected, """
      Expected 0.1.6 behavior: #{inspect(expected)}
      Actual result:           #{inspect(result)}
      """
    end
    
    test "single paragraph should not have excessive newlines" do
      input = "<p>Single paragraph.</p>"
      
      # Should not have leading/trailing newlines for single paragraph
      result = Html2Markdown.convert(input)
      expected = "Single paragraph."
      
      assert result == expected, "Result should be clean: #{inspect(result)}"
    end
    
    test "three paragraphs should use consistent spacing" do
      input = "<p>First.</p><p>Second.</p><p>Third.</p>"
      
      result = Html2Markdown.convert(input)
      
      # Should use consistent spacing between all paragraphs
      # Based on 0.1.6 behavior, should be "\n \n" between paragraphs
      expected = "First.\n \nSecond.\n \nThird."
      
      assert result == expected, """
      Expected: #{inspect(expected)}
      Actual:   #{inspect(result)}
      """
    end
    
    test "mixed elements maintain proper spacing" do
      input = "<p>A paragraph.</p><h1>A header</h1>"
      
      result = Html2Markdown.convert(input)
      
      # Different element types should use \n\n separator
      expected = "A paragraph.\n\n# A header\n"
      
      assert result == expected, """
      Expected: #{inspect(expected)}
      Actual:   #{inspect(result)}
      """
    end
    
    test "paragraph with formatting maintains structure" do
      input = "<p>The <strong>bold</strong> flavors and <em>italic</em> text.</p>"
      
      result = Html2Markdown.convert(input)
      expected = "The **bold** flavors and *italic* text."
      
      assert result == expected, """
      Expected: #{inspect(expected)}
      Actual:   #{inspect(result)}
      """
    end
  end

  describe "definition lists" do
    test "converts simple definition list" do
      html = """
      <dl>
        <dt>Elixir</dt>
        <dd>A dynamic, functional programming language</dd>
        <dt>Phoenix</dt>
        <dd>A productive web framework for Elixir</dd>
      </dl>
      """

      expected = """
      **Elixir**
      : A dynamic, functional programming language

      **Phoenix**
      : A productive web framework for Elixir
      """

      assert Html2Markdown.convert(html) |> String.trim() == String.trim(expected)
    end

    test "handles definition lists with multiple definitions per term" do
      html = """
      <dl>
        <dt>HTTP</dt>
        <dd>HyperText Transfer Protocol</dd>
        <dd>The foundation of data communication on the web</dd>
      </dl>
      """

      result = Html2Markdown.convert(html)
      assert String.contains?(result, "**HTTP**")
      assert String.contains?(result, ": HyperText Transfer Protocol")
      assert String.contains?(result, ": The foundation of data communication on the web")
    end

    test "handles definition lists with nested elements" do
      html = """
      <dl>
        <dt><strong>Important</strong> Term</dt>
        <dd>A definition with <em>emphasis</em> and <code>code</code></dd>
      </dl>
      """

      result = Html2Markdown.convert(html)
      # The dt element makes the content bold, and the nested strong makes "Important" extra bold
      assert String.contains?(result, "****Important** Term**")
      assert String.contains?(result, ": A definition with *emphasis* and `code`")
    end
  end

  describe "table edge cases" do
    test "converts table with empty tbody" do
      html = """
      <table>
        <thead>
          <tr>
            <th>Product</th>
            <th>Price</th>
            <th>Stock</th>
          </tr>
        </thead>
        <tbody>
          <tr></tr>
        </tbody>
      </table>
      """

      expected = """
      | Product | Price | Stock |
      | --- | --- | --- |
      |  |
      """

      assert Html2Markdown.convert(html) |> String.trim() == String.trim(expected)
    end

    test "converts table with message row spanning columns" do
      html = """
      <table>
        <thead>
          <tr>
            <th>Order ID</th>
            <th>Customer</th>
            <th>Total</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td colspan="3">No orders found.</td>
          </tr>
        </tbody>
      </table>
      """

      expected = """
      | Order ID | Customer | Total |
      | --- | --- | --- |
      | No orders found. | No orders found. | No orders found. |
      """

      assert Html2Markdown.convert(html) |> String.trim() == String.trim(expected)
    end

    test "converts dashboard with multiple empty tables" do
      html = """
      <div>
        <h2>Sales Dashboard</h2>
        <table>
          <thead>
            <tr>
              <th>Region</th>
              <th>Q1 Sales</th>
              <th>Q2 Sales</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td>No data available</td>
            </tr>
          </tbody>
        </table>

        <h2>Inventory Status</h2>
        <table>
          <thead>
            <tr>
              <th>Item</th>
              <th>Quantity</th>
              <th>Location</th>
            </tr>
          </thead>
          <tbody>
            <tr></tr>
          </tbody>
        </table>
      </div>
      """

      expected_contains = [
        "## Sales Dashboard",
        "| Region | Q1 Sales | Q2 Sales |",
        "| --- | --- | --- |",
        "| No data available |  |  |",
        "## Inventory Status",
        "| Item | Quantity | Location |",
        "| --- | --- | --- |",
        "|  |"
      ]

      result = Html2Markdown.convert(html)

      Enum.each(expected_contains, fn expected_line ->
        assert String.contains?(result, expected_line)
      end)
    end

    test "handles table with mixed empty and populated rows" do
      html = """
      <table>
        <tr>
          <th>Task</th>
          <th>Status</th>
        </tr>
        <tr>
          <td>Setup environment</td>
          <td>Complete</td>
        </tr>
        <tr></tr>
        <tr>
          <td>Deploy application</td>
          <td>Pending</td>
        </tr>
      </table>
      """

      expected = """
      | Task | Status |
      | --- | --- |
      | Setup environment | Complete |
      |  |
      | Deploy application | Pending |
      """

      assert Html2Markdown.convert(html) |> String.trim() == String.trim(expected)
    end

    test "handles malformed table cells" do
      html = """
      <table>
        <tr>
          <th>Name</th>
          <th>Value</th>
        </tr>
        <tr>
          Just text without td tags
        </tr>
        <tr>
          <td>Valid row</td>
          <td>Valid value</td>
        </tr>
      </table>
      """

      result = Html2Markdown.convert(html)

      # Should not crash and should include the valid row
      assert String.contains?(result, "| Valid row | Valid value |")
    end

    test "converts form with nested empty tables" do
      html = """
      <div>
        <h3>Search Results</h3>
        <div>
          <label>Filter:</label>
          <select><option>All</option></select>
        </div>
        <table>
          <thead>
            <tr>
              <th>ID</th>
              <th>Name</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td>No results found.</td>
            </tr>
          </tbody>
        </table>
        <div>
          <label>Page:</label>
          <select>
            <option>10</option>
            <option>25</option>
            <option>50</option>
          </select>
        </div>
      </div>
      """

      result = Html2Markdown.convert(html)

      assert String.contains?(result, "### Search Results")
      assert String.contains?(result, "| ID | Name | Actions |")
      assert String.contains?(result, "| No results found. |  |  |")
    end

    test "handles table with empty header row" do
      html = """
      <table>
        <thead>
          <tr></tr>
        </thead>
        <tbody>
          <tr>
            <td>Data 1</td>
            <td>Data 2</td>
          </tr>
        </tbody>
      </table>
      """

      result = Html2Markdown.convert(html)

      # Should handle empty header gracefully
      assert String.contains?(result, "|  |")
      assert String.contains?(result, "| --- |")
      assert String.contains?(result, "| Data 1 | Data 2 |")
    end

    test "handles table where first row has no cells for header separator" do
      html = """
      <table>
        <tr></tr>
        <tr>
          <td>Row with data</td>
          <td>More data</td>
        </tr>
      </table>
      """

      result = Html2Markdown.convert(html)

      # Should not crash and should process the valid row
      assert String.contains?(result, "| Row with data | More data |")
    end
  end

  describe "HTML entity handling" do
    test "decodes common HTML entities" do
      html = """
      <p>The &amp; symbol, &lt;tag&gt; brackets, and &quot;quotes&quot; are decoded.</p>
      <p>Non-breaking&nbsp;space and apostrophe&#39;s work too.</p>
      """

      # Note: nbsp is converted to a non-breaking space character by Floki
      result = Html2Markdown.convert(html)

      # Floki converts &nbsp; to Unicode non-breaking space (U+00A0)
      # Paragraphs are joined with \n \n (space between newlines)
      expected =
        "The & symbol, <tag> brackets, and \"quotes\" are decoded.\n \nNon-breaking\u00A0space and apostrophe's work too."

      assert result == expected
    end

    test "preserves entities in code blocks" do
      html = """
      <pre><code>&lt;div class=&quot;example&quot;&gt;
      Content &amp; more
      &lt;/div&gt;</code></pre>
      """

      expected = "\n```\n<div class=\"example\">\nContent & more\n</div>\n```\n"

      assert Html2Markdown.convert(html) == expected
    end

    test "handles numeric entities" do
      html = """
      <p>Copyright &#169; 2024 &#x2022; All rights reserved</p>
      """

      expected = "Copyright © 2024 • All rights reserved"

      assert Html2Markdown.convert(html) == expected
    end

    test "entities in inline code are preserved" do
      html = """
      <p>Use <code>&lt;div&gt;</code> for layout and <code>&amp;&amp;</code> for logical AND.</p>
      """

      expected = "Use `<div>` for layout and `&&` for logical AND."

      assert Html2Markdown.convert(html) == expected
    end
  end
end
