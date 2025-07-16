defmodule Html2Markdown.ParserTest do
  use ExUnit.Case
  alias Html2Markdown.Parser
  alias Html2Markdown.Options

  describe "preprocess_content/2" do
    test "wraps HTML fragments in proper document structure" do
      fragment = "<p>Learn Phoenix LiveView</p>"
      opts = Options.defaults()

      result = Parser.preprocess_content(fragment, opts)

      # Should return parsed body content
      assert [{"p", [], ["Learn Phoenix LiveView"]}] = result
    end

    test "handles complete HTML documents" do
      html = """
      <html>
        <head><title>Elixir Guide</title></head>
        <body>
          <p>Welcome to Elixir</p>
        </body>
      </html>
      """

      opts = Options.defaults()

      result = Parser.preprocess_content(html, opts)

      assert [{"p", [], ["Welcome to Elixir"]}] = result
    end

    test "removes navigation elements with default classes" do
      html = """
      <body>
        <nav class="top-nav">
          <a href="/docs">Documentation</a>
        </nav>
        <div class="sidebar">
          <a href="/guides">Guides</a>  
        </div>
        <main>
          <h1>Phoenix Framework</h1>
          <p>Build rich, interactive web applications</p>
        </main>
        <footer class="site-footer">
          <p>© 2024 Phoenix Team</p>
        </footer>
      </body>
      """

      opts = Options.defaults()

      result = Parser.preprocess_content(html, opts)

      # Should only contain main content
      assert [{"main", [], content}] = result
      assert {"h1", [], ["Phoenix Framework"]} in content
      assert {"p", [], ["Build rich, interactive web applications"]} in content

      # Navigation elements should be removed
      refute Enum.any?(result, &match?({"nav", _, _}, &1))
      refute Enum.any?(result, &match?({"footer", _, _}, &1))
    end

    test "removes custom navigation classes" do
      html = """
      <body>
        <div class="phoenix-nav">Phoenix Navigation</div>
        <div class="liveview-menu">LiveView Menu</div>
        <article>
          <h2>Understanding GenServers</h2>
          <p>GenServers are a core abstraction in Elixir.</p>
        </article>
      </body>
      """

      opts = Options.merge(%{navigation_classes: ["phoenix-nav", "liveview-menu"]})

      result = Parser.preprocess_content(html, opts)

      # Only article should remain
      assert [{"article", [], content}] = result
      assert {"h2", [], ["Understanding GenServers"]} in content
    end

    test "filters out non-content tags" do
      html = """
      <body>
        <script>console.log('tracking');</script>
        <style>.highlight { color: purple; }</style>
        <article>
          <h1>Elixir Processes</h1>
          <p>Lightweight and isolated</p>
          <form>
            <input type="email" placeholder="Subscribe">
          </form>
          <iframe src="/ads"></iframe>
        </article>
        <noscript>Please enable JavaScript</noscript>
      </body>
      """

      opts = Options.defaults()

      result = Parser.preprocess_content(html, opts)

      # Should only have article without form/iframe
      assert [{"article", [], content}] = result
      assert {"h1", [], ["Elixir Processes"]} in content
      assert {"p", [], ["Lightweight and isolated"]} in content

      # Non-content tags should be removed
      refute has_tag?(result, "script")
      refute has_tag?(result, "style")
      refute has_tag?(result, "form")
      refute has_tag?(result, "iframe")
      refute has_tag?(result, "noscript")
    end

    test "removes HTML comments" do
      html = """
      <body>
        <!-- Navigation Menu -->
        <nav>Menu</nav>
        <!-- Main Content -->
        <main>
          <h1>Phoenix LiveView</h1>
          <!-- TODO: Add more examples -->
          <p>Build interactive UIs</p>
        </main>
        <!-- Footer -->
      </body>
      """

      opts = Options.defaults()

      result = Parser.preprocess_content(html, opts)

      # Comments should be removed but content preserved
      assert [{"main", [], content}] = result
      assert {"h1", [], ["Phoenix LiveView"]} in content
      assert {"p", [], ["Build interactive UIs"]} in content
    end

    test "handles nested navigation elements" do
      html = """
      <body>
        <div class="wrapper">
          <aside class="sidebar">
            <nav>
              <a href="/home">Home</a>
            </nav>
          </aside>
          <main>
            <h1>Pattern Matching</h1>
            <p>One of Elixir's most powerful features</p>
          </main>
        </div>
      </body>
      """

      opts = Options.defaults()

      result = Parser.preprocess_content(html, opts)

      # Should handle nested structure correctly
      assert [{"div", [{"class", "wrapper"}], content}] = result

      # Find the main element in content
      main_elem =
        Enum.find(content, fn
          {"main", _, _} -> true
          _ -> false
        end)

      assert {"main", [], main_content} = main_elem
      assert {"h1", [], ["Pattern Matching"]} in main_content

      # Nested nav elements should be removed
      refute has_tag?(result, "aside")
      refute has_tag?(result, "nav")
    end

    test "preserves body tag when it has navigation class" do
      html = """
      <body class="nav">
        <h1>This should be preserved</h1>
      </body>
      """

      opts = Options.defaults()

      result = Parser.preprocess_content(html, opts)

      # Body tag should not be removed even with nav class
      assert [{"h1", [], ["This should be preserved"]}] = result
    end
  end

  # Helper function to check if a tag exists in the structure
  defp has_tag?(nodes, tag) when is_list(nodes) do
    Enum.any?(nodes, &has_tag?(&1, tag))
  end

  defp has_tag?({tag, _, _}, tag), do: true

  defp has_tag?({_, _, children}, tag) when is_list(children) do
    has_tag?(children, tag)
  end

  defp has_tag?(_, _), do: false
end
