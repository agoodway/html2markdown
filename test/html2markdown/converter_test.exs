defmodule Html2Markdown.ConverterTest do
  use ExUnit.Case
  alias Html2Markdown.Converter
  alias Html2Markdown.Options

  describe "process_node/2 - headings" do
    test "converts h1 through h6 tags" do
      opts = Options.defaults()

      assert Converter.process_node({"h1", [], ["Getting Started with Phoenix"]}, opts) ==
               "# Getting Started with Phoenix"

      assert Converter.process_node({"h2", [], ["Installing Dependencies"]}, opts) ==
               "## Installing Dependencies"

      assert Converter.process_node({"h3", [], ["Mix and Hex"]}, opts) ==
               "### Mix and Hex"

      assert Converter.process_node({"h4", [], ["Creating a New Project"]}, opts) ==
               "#### Creating a New Project"

      assert Converter.process_node({"h5", [], ["Project Structure"]}, opts) ==
               "##### Project Structure"

      assert Converter.process_node({"h6", [], ["Configuration Files"]}, opts) ==
               "###### Configuration Files"
    end

    test "handles nested elements in headings" do
      opts = Options.defaults()

      heading = {"h2", [], ["Understanding ", {"code", [], ["GenServer"]}, " Behavior"]}
      assert Converter.process_node(heading, opts) == "## Understanding `GenServer` Behavior"

      heading_with_link = {"h3", [], [{"a", [{"href", "/docs"}], ["LiveView"]}, " Components"]}

      assert Converter.process_node(heading_with_link, opts) ==
               "### [LiveView](/docs) Components"
    end
  end

  describe "process_node/2 - paragraphs and text formatting" do
    test "converts paragraphs" do
      opts = Options.defaults()

      para = {"p", [], ["Phoenix makes it easy to build web applications."]}

      assert Converter.process_node(para, opts) ==
               "Phoenix makes it easy to build web applications."
    end

    test "converts text formatting tags" do
      opts = Options.defaults()

      assert Converter.process_node({"strong", [], ["Important"]}, opts) == "**Important**"
      assert Converter.process_node({"b", [], ["Bold"]}, opts) == "**Bold**"
      assert Converter.process_node({"em", [], ["Emphasized"]}, opts) == "*Emphasized*"
      assert Converter.process_node({"i", [], ["Italic"]}, opts) == "*Italic*"
      assert Converter.process_node({"u", [], ["Underlined"]}, opts) == "<u>Underlined</u>"
      assert Converter.process_node({"del", [], ["Deleted"]}, opts) == "~~Deleted~~"
      assert Converter.process_node({"sup", [], ["2"]}, opts) == "<sup>2</sup>"
      assert Converter.process_node({"sub", [], ["n"]}, opts) == "<sub>n</sub>"
    end

    test "handles nested formatting" do
      opts = Options.defaults()

      nested =
        {"p", [],
         [
           "In Elixir, ",
           {"strong", [], ["pattern matching"]},
           " is ",
           {"em", [], ["extremely"]},
           " powerful."
         ]}

      result = Converter.process_node(nested, opts)
      assert result == "In Elixir, **pattern matching** is *extremely* powerful."
    end
  end

  describe "process_node/2 - code elements" do
    test "converts inline code" do
      opts = Options.defaults()

      code = {"code", [], ["Enum.map/2"]}
      assert Converter.process_node(code, opts) == "`Enum.map/2`"
    end

    test "preserves whitespace in inline code" do
      opts = Options.defaults()

      code = {"code", [], ["  defmodule   MyApp  "]}
      assert Converter.process_node(code, opts) == "`  defmodule   MyApp  `"
    end

    test "converts code blocks without language" do
      opts = Options.defaults()

      pre_code = {"pre", [], [{"code", [], ["defmodule MyApp do\n  use Application\nend"]}]}
      expected = "```\ndefmodule MyApp do\n  use Application\nend\n```"

      assert Converter.process_node(pre_code, opts) == expected
    end

    test "converts code blocks with language class" do
      opts = Options.defaults()

      elixir_code =
        {"pre", [],
         [
           {"code", [{"class", "language-elixir"}],
            [
              "defmodule MyApp.Repo do\n  use Ecto.Repo,\n    otp_app: :my_app\nend"
            ]}
         ]}

      expected =
        "```elixir\ndefmodule MyApp.Repo do\n  use Ecto.Repo,\n    otp_app: :my_app\nend\n```"

      assert Converter.process_node(elixir_code, opts) == expected
    end

    test "handles pre tag without code tag" do
      opts = Options.defaults()

      pre = {"pre", [], ["$ mix phx.new my_app\n$ cd my_app\n$ mix deps.get"]}
      expected = "```\n$ mix phx.new my_app\n$ cd my_app\n$ mix deps.get\n```"

      assert Converter.process_node(pre, opts) == expected
    end
  end

  describe "process_node/2 - lists" do
    test "converts unordered lists" do
      opts = Options.defaults()

      ul =
        {"ul", [],
         [
           {"li", [], ["Phoenix Framework"]},
           {"li", [], ["LiveView"]},
           {"li", [], ["Ecto"]}
         ]}

      expected = "- Phoenix Framework\n- LiveView\n- Ecto"
      assert Converter.process_node(ul, opts) == expected
    end

    test "converts ordered lists" do
      opts = Options.defaults()

      ol =
        {"ol", [],
         [
           {"li", [], ["Install Elixir"]},
           {"li", [], ["Create new project"]},
           {"li", [], ["Start Phoenix server"]}
         ]}

      expected = "1. Install Elixir\n2. Create new project\n3. Start Phoenix server"
      assert Converter.process_node(ol, opts) == expected
    end

    test "handles nested lists" do
      opts = Options.defaults()

      nested_ul =
        {"ul", [],
         [
           {"li", [],
            [
              "Elixir Features",
              {"ul", [],
               [
                 {"li", [], ["Pattern Matching"]},
                 {"li", [], ["Actor Model"]}
               ]}
            ]},
           {"li", [], ["Phoenix Features"]}
         ]}

      expected =
        "- Elixir Features\n  - Pattern Matching\n  - Actor Model\n- Phoenix Features"

      assert Converter.process_node(nested_ul, opts) == expected
    end
  end

  describe "process_node/2 - links and images" do
    test "converts links with text" do
      opts = Options.defaults()

      link = {"a", [{"href", "https://elixir-lang.org"}], ["Elixir Official Site"]}

      assert Converter.process_node(link, opts) ==
               "[Elixir Official Site](https://elixir-lang.org)"
    end

    test "converts links without text" do
      opts = Options.defaults()

      link = {"a", [{"href", "https://hexdocs.pm"}], []}
      assert Converter.process_node(link, opts) == "[https://hexdocs.pm](https://hexdocs.pm)"
    end

    test "converts images" do
      opts = Options.defaults()

      img = {"img", [{"src", "/images/phoenix-logo.png"}, {"alt", "Phoenix Logo"}], []}
      assert Converter.process_node(img, opts) == "![Phoenix Logo](/images/phoenix-logo.png)"
    end

    test "handles picture elements" do
      opts = Options.defaults()

      picture =
        {"picture", [],
         [
           {"source", [{"srcset", "/images/logo.webp"}], []},
           {"img", [{"src", "/images/logo.png"}, {"alt", "Elixir Logo"}], []}
         ]}

      assert Converter.process_node(picture, opts) == "![Elixir Logo](/images/logo.png)"
    end
  end

  describe "process_node/2 - blockquotes" do
    test "converts blockquotes" do
      opts = Options.defaults()

      quote = {"blockquote", [], ["Elixir is a dynamic, functional language."]}

      assert Converter.process_node(quote, opts) ==
               "\n> Elixir is a dynamic, functional language.\n"
    end

    test "handles nested elements in blockquotes" do
      opts = Options.defaults()

      quote =
        {"blockquote", [],
         [
           "As José Valim said: ",
           {"strong", [], ["Elixir leverages the Erlang VM"]},
           "."
         ]}

      expected = "\n> As José Valim said: **Elixir leverages the Erlang VM**.\n"
      assert Converter.process_node(quote, opts) == expected
    end
  end

  describe "process_node/2 - definition lists" do
    test "converts simple definition lists" do
      opts = Options.defaults()

      dl =
        {"dl", [],
         [
           {"dt", [], ["Phoenix"]},
           {"dd", [], ["A web framework for Elixir"]},
           {"dt", [], ["LiveView"]},
           {"dd", [], ["Rich, interactive UIs without JavaScript"]}
         ]}

      result = Converter.process_node(dl, opts)
      assert String.contains?(result, "**Phoenix**")
      assert String.contains?(result, ": A web framework for Elixir")
      assert String.contains?(result, "**LiveView**")
      assert String.contains?(result, ": Rich, interactive UIs without JavaScript")
    end

    test "handles multiple definitions per term" do
      opts = Options.defaults()

      dl =
        {"dl", [],
         [
           {"dt", [], ["OTP"]},
           {"dd", [], ["Open Telecom Platform"]},
           {"dd", [], ["A set of libraries and design principles"]}
         ]}

      result = Converter.process_node(dl, opts)
      assert String.contains?(result, "**OTP**")
      assert String.contains?(result, ": Open Telecom Platform")
      assert String.contains?(result, ": A set of libraries and design principles")
    end
  end

  describe "process_node/2 - semantic elements" do
    test "converts section and article elements" do
      opts = Options.defaults()

      section = {"section", [], [{"h2", [], ["LiveView Basics"]}]}
      # Section uses block context which produces clean content without extra newlines
      assert Converter.process_node(section, opts) == "## LiveView Basics"

      article = {"article", [], [{"p", [], ["Content here"]}]}
      # Article uses block context which produces clean content without extra newlines
      assert Converter.process_node(article, opts) == "Content here"
    end

    test "converts figcaption" do
      opts = Options.defaults()

      figcaption = {"figcaption", [], ["Figure 1: Phoenix Architecture"]}
      assert Converter.process_node(figcaption, opts) == "**Figure 1: Phoenix Architecture**"
    end

    test "converts horizontal rules" do
      opts = Options.defaults()

      assert Converter.process_node({"hr", [], []}, opts) == "\n\n---\n\n"
    end

    test "converts line breaks" do
      opts = Options.defaults()

      assert Converter.process_node({"br", [], []}, opts) == "{{BR}}{{/BR}}"
    end
  end

  describe "process_node/2 - whitespace handling" do
    test "normalizes whitespace in text nodes by default" do
      opts = Options.defaults()

      text = "  Multiple   spaces   and\n\ttabs  "
      # The normalize_whitespace function preserves newlines but normalizes spaces
      assert Converter.process_node(text, opts) == "Multiple spaces and\ntabs"
    end

    test "preserves whitespace when normalize_whitespace is false" do
      opts = Options.merge(%{normalize_whitespace: false})

      text = "  Multiple   spaces  "
      assert Converter.process_node(text, opts) == "  Multiple   spaces  "
    end
  end

  describe "convert_to_markdown/2" do
    test "converts complete document structure" do
      opts = Options.defaults()

      doc = [
        {"h1", [], ["Getting Started with Phoenix"]},
        {"p", [], ["Phoenix is a web framework written in Elixir."]},
        {"h2", [], ["Installation"]},
        {"pre", [], [{"code", [], ["$ mix archive.install hex phx_new"]}]},
        {"p", [], ["Now you can create a new Phoenix app."]}
      ]

      result = Converter.convert_to_markdown(doc, opts)

      # Elements are joined with \n\n
      expected =
        "# Getting Started with Phoenix\n\nPhoenix is a web framework written in Elixir.\n\n## Installation\n\n```\n$ mix archive.install hex phx_new\n```\n\nNow you can create a new Phoenix app."

      assert result == expected
    end

    test "filters out empty strings between nodes" do
      opts = Options.defaults()

      doc = [
        {"p", [], ["First paragraph"]},
        "",
        {"p", [], ["Second paragraph"]},
        "",
        ""
      ]

      result = Converter.convert_to_markdown(doc, opts)
      # Paragraphs are joined with \n\n
      assert result == "First paragraph\n\nSecond paragraph"
    end
  end

  describe "process_children/2" do
    test "processes multiple child nodes" do
      opts = Options.defaults()

      children = [
        "Check out ",
        {"a", [{"href", "/docs"}], ["the documentation"]},
        " for ",
        {"code", [], ["Phoenix.LiveView"]},
        "."
      ]

      result = Converter.process_children(children, opts)
      assert result == "Check out [the documentation](/docs) for `Phoenix.LiveView`."
    end

    test "handles empty children list" do
      opts = Options.defaults()

      assert Converter.process_children([], opts) == ""
    end
  end
end
