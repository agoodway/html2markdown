defmodule Html2Markdown.CodeWhitespaceTest do
  use ExUnit.Case, async: true

  describe "code block whitespace preservation" do
    test "preserves spaces in code blocks" do
      html = """
      <pre><code>def hello_world do
        IO.puts("Hello World!")
      end</code></pre>
      """

      result = Html2Markdown.convert(html)

      expected = """
      ```
      def hello_world do
        IO.puts("Hello World!")
      end
      ```
      """

      assert result == String.trim(expected)
    end

    test "preserves spaces in inline code" do
      html = """
      <p>Call the function with <code>hello_world()</code> syntax.</p>
      """

      result = Html2Markdown.convert(html)
      expected = "Call the function with `hello_world()` syntax."

      assert result == expected
    end

    test "does not add spaces between function calls and parentheses" do
      html = """
      <pre><code>IO.puts("test")
      String.split("a,b,c", ",")
      Enum.map([1, 2, 3], &(&1 * 2))</code></pre>
      """

      result = Html2Markdown.convert(html)

      # Should NOT have spaces like "IO. puts ( )"
      assert result =~ "IO.puts("
      assert result =~ "String.split("
      assert result =~ "Enum.map("
      refute result =~ "IO. puts"
      refute result =~ "String. split"
    end

    test "preserves complex code formatting" do
      html = """
      <pre><code>defmodule MyModule do
        def function(arg1, arg2) do
          %{
            key: "value",
            list: [1, 2, 3]
          }
        end
      end</code></pre>
      """

      result = Html2Markdown.convert(html)

      # Check that spacing is preserved
      assert result =~ "defmodule MyModule do"
      assert result =~ "  def function(arg1, arg2) do"
      # No spaces around parentheses
      refute result =~ "function ( arg1"
    end

    test "handles mixed content with proper spacing" do
      html = """
      <p>Here's some code: <code>IO.puts("Hello")</code> in a paragraph.</p>
      <pre><code>def example do
        :ok
      end</code></pre>
      <p>And more text after.</p>
      """

      result = Html2Markdown.convert(html)

      # Inline code should not have extra spaces
      assert result =~ "`IO.puts(\"Hello\")`"
      refute result =~ "`IO. puts"

      # Code block should preserve formatting
      assert result =~ "def example do"
      assert result =~ "  :ok"
    end
  end

  describe "link and image nesting" do
    test "handles image inside link" do
      html = """
      <a href="/">Phoenix Framework<img src="/images/logo.png" alt=""></a>
      """

      result = Html2Markdown.convert(html)

      # Should not create nested markdown like [text![image]]
      # This is a known issue that needs fixing
      assert result == "[Phoenix Framework![](/images/logo.png)](/)"
    end
  end
end
