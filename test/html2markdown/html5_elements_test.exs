defmodule Html2Markdown.Html5ElementsTest do
  use ExUnit.Case

  describe "details and summary elements" do
    test "converts details with summary" do
      html = """
      <details>
        <summary>Phoenix Framework Features</summary>
        <p>Phoenix provides real-time features, fault tolerance, and excellent performance.</p>
      </details>
      """
      
      result = Html2Markdown.convert(html)
      
      assert String.contains?(result, "**Phoenix Framework Features**")
      assert String.contains?(result, "Phoenix provides real-time features")
    end

    test "converts details without summary" do
      html = """
      <details>
        <p>This is some detailed content without a summary.</p>
      </details>
      """
      
      result = Html2Markdown.convert(html)
      
      assert String.contains?(result, "**Details**")
      assert String.contains?(result, "This is some detailed content")
    end

    test "handles nested elements in summary" do
      html = """
      <details>
        <summary>Learn about <code>GenServer</code></summary>
        <p>GenServer provides a generic server behavior in Elixir.</p>
      </details>
      """
      
      result = Html2Markdown.convert(html)
      
      assert String.contains?(result, "**Learn about `GenServer`**")
    end

    test "converts multiple details elements" do
      html = """
      <div>
        <details>
          <summary>OTP Behaviors</summary>
          <p>GenServer, Supervisor, Application</p>
        </details>
        <details>
          <summary>Phoenix Components</summary>
          <p>LiveView, Channels, Presence</p>
        </details>
      </div>
      """
      
      result = Html2Markdown.convert(html)
      
      assert String.contains?(result, "**OTP Behaviors**")
      assert String.contains?(result, "**Phoenix Components**")
      assert String.contains?(result, "GenServer, Supervisor, Application")
      assert String.contains?(result, "LiveView, Channels, Presence")
    end
  end

  describe "mark element" do
    test "converts mark element with basic flavor" do
      html = """
      <p>The <mark>important</mark> part is highlighted.</p>
      """
      
      # Default flavor is basic, should use bold
      result = Html2Markdown.convert(html)
      
      assert String.contains?(result, "**important**")
    end

    test "converts mark element with GFM flavor" do
      html = """
      <p>The <mark>important</mark> part is highlighted.</p>
      """
      
      result = Html2Markdown.convert(html, %{markdown_flavor: :gfm})
      
      assert String.contains?(result, "==important==")
    end

    test "handles nested elements in mark" do
      html = """
      <p>The <mark>very <em>important</em> code</mark> is here.</p>
      """
      
      result = Html2Markdown.convert(html)
      
      assert String.contains?(result, "**very *important* code**")
    end
  end

  describe "abbr element" do
    test "converts abbr with title attribute" do
      html = """
      <p>We use <abbr title="Open Telecom Platform">OTP</abbr> for building distributed systems.</p>
      """
      
      result = Html2Markdown.convert(html)
      
      assert String.contains?(result, "OTP (Open Telecom Platform)")
    end

    test "converts abbr without title attribute" do
      html = """
      <p>The <abbr>API</abbr> is well documented.</p>
      """
      
      result = Html2Markdown.convert(html)
      
      assert String.contains?(result, "API")
      assert not String.contains?(result, "API (")
    end

    test "handles nested elements in abbr" do
      html = """
      <p>The <abbr title="HyperText Markup Language"><strong>HTML</strong></abbr> spec.</p>
      """
      
      result = Html2Markdown.convert(html)
      
      assert String.contains?(result, "**HTML** (HyperText Markup Language)")
    end
  end

  describe "cite element" do
    test "converts cite element to italic" do
      html = """
      <p>As mentioned in <cite>Programming Elixir</cite>, pattern matching is powerful.</p>
      """
      
      result = Html2Markdown.convert(html)
      
      assert String.contains?(result, "*Programming Elixir*")
    end

    test "handles nested elements in cite" do
      html = """
      <p>From <cite>The <strong>Phoenix</strong> Framework Guide</cite>.</p>
      """
      
      result = Html2Markdown.convert(html)
      
      assert String.contains?(result, "*The **Phoenix** Framework Guide*")
    end
  end

  describe "q element" do
    test "converts q element with quotes" do
      html = """
      <p>Joe Armstrong said <q>Let it crash</q> about error handling.</p>
      """
      
      result = Html2Markdown.convert(html)
      
      assert String.contains?(result, "\"Let it crash\"")
    end

    test "converts q element with cite attribute" do
      html = """
      <p>The docs state <q cite="https://hexdocs.pm/elixir">Elixir is dynamic</q>.</p>
      """
      
      result = Html2Markdown.convert(html)
      
      assert String.contains?(result, "\"Elixir is dynamic\" (https://hexdocs.pm/elixir)")
    end

    test "handles nested elements in q" do
      html = """
      <p>They said <q>Use <code>IO.inspect</code> for debugging</q>.</p>
      """
      
      result = Html2Markdown.convert(html)
      
      assert String.contains?(result, "\"Use `IO.inspect` for debugging\"")
    end
  end

  describe "time element" do
    test "converts time with datetime attribute" do
      html = """
      <p>The conference starts on <time datetime="2024-09-05T09:00:00Z">September 5th</time>.</p>
      """
      
      result = Html2Markdown.convert(html)
      
      assert String.contains?(result, "September 5th <time datetime=\"2024-09-05T09:00:00Z\">")
    end

    test "converts time without datetime attribute" do
      html = """
      <p>We'll meet <time>tomorrow</time> to discuss.</p>
      """
      
      result = Html2Markdown.convert(html)
      
      assert String.contains?(result, "tomorrow")
      assert not String.contains?(result, "<time")
    end

    test "handles nested elements in time" do
      html = """
      <p>Event on <time datetime="2024-12-25"><strong>Christmas</strong> Day</time>.</p>
      """
      
      result = Html2Markdown.convert(html)
      
      assert String.contains?(result, "**Christmas** Day <time datetime=\"2024-12-25\">")
    end
  end

  describe "video element" do
    test "converts video with src attribute" do
      html = """
      <p>Watch the <video src="/tutorials/phoenix-intro.mp4">Phoenix introduction</video>.</p>
      """
      
      result = Html2Markdown.convert(html)
      
      assert String.contains?(result, "[Video](/tutorials/phoenix-intro.mp4)")
    end

    test "converts video without src attribute" do
      html = """
      <p>The <video>tutorial video</video> is below.</p>
      """
      
      result = Html2Markdown.convert(html)
      
      assert String.contains?(result, "[Video]")
    end

    test "handles multiple videos" do
      html = """
      <div>
        <video src="/intro.mp4">Introduction</video>
        <video src="/advanced.mp4">Advanced Topics</video>
      </div>
      """
      
      result = Html2Markdown.convert(html)
      
      assert String.contains?(result, "[Video](/intro.mp4)")
      assert String.contains?(result, "[Video](/advanced.mp4)")
    end
  end

  describe "mixed HTML5 elements" do
    test "converts document with multiple HTML5 elements" do
      html = """
      <article>
        <h2>Understanding <abbr title="Erlang Virtual Machine">BEAM</abbr></h2>
        <p>As noted in <cite>Erlang in Anger</cite>, the <mark>BEAM</mark> is highly reliable.</p>
        <details>
          <summary>Key Features</summary>
          <ul>
            <li>Fault tolerance</li>
            <li>Hot code reloading</li>
          </ul>
        </details>
        <p>The conference is on <time datetime="2024-10-15">October 15th</time>.</p>
        <p>José Valim said <q cite="https://elixir-lang.org">Elixir leverages Erlang</q>.</p>
        <video src="/beam-intro.mp4">BEAM Introduction</video>
      </article>
      """
      
      result = Html2Markdown.convert(html)
      
      # Check all conversions
      assert String.contains?(result, "## Understanding BEAM (Erlang Virtual Machine)")
      assert String.contains?(result, "*Erlang in Anger*")
      assert String.contains?(result, "**BEAM**")  # mark with basic flavor
      assert String.contains?(result, "**Key Features**")
      assert String.contains?(result, "- Fault tolerance")
      assert String.contains?(result, "October 15th <time datetime=\"2024-10-15\">")
      assert String.contains?(result, "\"Elixir leverages Erlang\" (https://elixir-lang.org)")
      assert String.contains?(result, "[Video](/beam-intro.mp4)")
    end

    test "handles HTML5 elements with configuration options" do
      html = """
      <div>
        <nav class="navigation">
          <a href="#top">Back to top</a>
        </nav>
        <main>
          <p>Check the <mark>highlighted</mark> section in <cite>The Guide</cite>.</p>
          <p><abbr title="Application Programming Interface">API</abbr> docs are <time datetime="2024-01-01">here</time>.</p>
        </main>
      </div>
      """
      
      # Test with GFM flavor and custom navigation classes
      result = Html2Markdown.convert(html, %{
        markdown_flavor: :gfm,
        navigation_classes: ["navigation", "nav-menu"]
      })
      
      # Navigation should be filtered out
      assert not String.contains?(result, "Back to top")
      
      # Mark should use GFM syntax
      assert String.contains?(result, "==highlighted==")
      
      # Other elements should work normally
      assert String.contains?(result, "*The Guide*")
      assert String.contains?(result, "API (Application Programming Interface)")
    end
  end
end