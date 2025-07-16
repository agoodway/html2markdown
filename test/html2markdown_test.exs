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

  describe "configuration options" do
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
      assert not String.contains?(result, "Sidebar content")  # Default includes "sidebar"
      
      # With custom navigation classes
      result = Html2Markdown.convert(html, %{navigation_classes: ["custom-header"]})
      assert not String.contains?(result, "Custom header content")
      assert String.contains?(result, "Main content")
      assert String.contains?(result, "Sidebar content")  # No longer filtered since we replaced defaults
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
end
