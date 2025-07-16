defmodule Html2Markdown.TableConverterTest do
  use ExUnit.Case
  alias Html2Markdown.TableConverter
  alias Html2Markdown.Options

  describe "process_table/2 - basic tables" do
    test "converts simple table with headers" do
      opts = Options.defaults()
      
      table = [
        {"tr", [], [
          {"th", [], ["Framework"]},
          {"th", [], ["Language"]},
          {"th", [], ["Type"]}
        ]},
        {"tr", [], [
          {"td", [], ["Phoenix"]},
          {"td", [], ["Elixir"]},
          {"td", [], ["Web"]}
        ]},
        {"tr", [], [
          {"td", [], ["Rails"]},
          {"td", [], ["Ruby"]},
          {"td", [], ["Web"]}
        ]}
      ]
      
      result = TableConverter.process_table(table, opts)
      
      expected = """
      | Framework | Language | Type |
      | --- | --- | --- |
      | Phoenix | Elixir | Web |
      | Rails | Ruby | Web |
      """
      
      assert String.trim(result) == String.trim(expected)
    end

    test "converts table without headers" do
      opts = Options.defaults()
      
      table = [
        {"tr", [], [
          {"td", [], ["Elixir"]},
          {"td", [], ["1.15.0"]}
        ]},
        {"tr", [], [
          {"td", [], ["Phoenix"]},
          {"td", [], ["1.7.0"]}
        ]}
      ]
      
      result = TableConverter.process_table(table, opts)
      
      expected = """
      | Elixir | 1.15.0 |
      | Phoenix | 1.7.0 |
      """
      
      assert String.trim(result) == String.trim(expected)
    end
  end

  describe "process_table/2 - complex structures" do
    test "handles thead and tbody elements" do
      opts = Options.defaults()
      
      table = [
        {"thead", [], [
          {"tr", [], [
            {"th", [], ["Library"]},
            {"th", [], ["Purpose"]}
          ]}
        ]},
        {"tbody", [], [
          {"tr", [], [
            {"td", [], ["Ecto"]},
            {"td", [], ["Database wrapper"]}
          ]},
          {"tr", [], [
            {"td", [], ["Plug"]},
            {"td", [], ["Composable modules"]}
          ]}
        ]}
      ]
      
      result = TableConverter.process_table(table, opts)
      
      expected = """
      | Library | Purpose |
      | --- | --- |
      | Ecto | Database wrapper |
      | Plug | Composable modules |
      """
      
      assert String.trim(result) == String.trim(expected)
    end

    test "handles colspan attributes" do
      opts = Options.defaults()
      
      table = [
        {"tr", [], [
          {"th", [{"colspan", "2"}], ["Elixir Ecosystem"]}
        ]},
        {"tr", [], [
          {"td", [], ["Phoenix"]},
          {"td", [], ["Web Framework"]}
        ]}
      ]
      
      result = TableConverter.process_table(table, opts)
      
      # Should repeat content for each spanned column
      assert String.contains?(result, "| Elixir Ecosystem | Elixir Ecosystem |")
      assert String.contains?(result, "| Phoenix | Web Framework |")
    end

    test "handles empty cells" do
      opts = Options.defaults()
      
      table = [
        {"tr", [], [
          {"td", [], ["LiveView"]},
          {"td", [], []},
          {"td", [], ["Interactive"]}
        ]},
        {"tr", [], [
          {"td", [], []},
          {"td", [], ["Middle"]},
          {"td", [], []}
        ]}
      ]
      
      result = TableConverter.process_table(table, opts)
      
      expected = """
      | LiveView |  | Interactive |
      |  | Middle |  |
      """
      
      assert String.trim(result) == String.trim(expected)
    end

    test "handles nested elements in cells" do
      opts = Options.defaults()
      
      table = [
        {"tr", [], [
          {"th", [], ["Feature"]},
          {"th", [], ["Description"]}
        ]},
        {"tr", [], [
          {"td", [], [{"strong", [], ["Pattern Matching"]}]},
          {"td", [], ["Extract values from ", {"code", [], ["data structures"]}]}
        ]},
        {"tr", [], [
          {"td", [], [{"a", [{"href", "/docs/genserver"}], ["GenServer"]}]},
          {"td", [], ["Generic ", {"em", [], ["server"]}, " behavior"]}
        ]}
      ]
      
      result = TableConverter.process_table(table, opts)
      
      assert String.contains?(result, "| Feature | Description |")
      assert String.contains?(result, "| --- | --- |")
      assert String.contains?(result, "| **Pattern Matching** | Extract values from `data structures` |")
      assert String.contains?(result, "| [GenServer](/docs/genserver) | Generic *server* behavior |")
    end

    test "handles style-based indentation" do
      opts = Options.defaults()
      
      table = [
        {"tr", [], [
          {"td", [], ["Root"]},
          {"td", [], ["Level 0"]}
        ]},
        {"tr", [], [
          {"td", [{"style", "padding-left:2.5em;"}], ["Child"]},
          {"td", [], ["Level 1"]}
        ]},
        {"tr", [], [
          {"td", [{"style", "padding-left:5.0em;"}], ["Grandchild"]},
          {"td", [], ["Level 2"]}
        ]}
      ]
      
      result = TableConverter.process_table(table, opts)
      
      # Should add &ensp; for indentation
      assert String.contains?(result, "| Root | Level 0 |")
      assert String.contains?(result, "&ensp;&ensp;&ensp;Child")
      assert String.contains?(result, "&ensp;&ensp;&ensp;&ensp;&ensp;Grandchild")
    end
  end

  describe "process_table/2 - edge cases" do
    test "handles empty table" do
      opts = Options.defaults()
      
      result = TableConverter.process_table([], opts)
      assert String.trim(result) == ""
    end

    test "handles table with empty rows" do
      opts = Options.defaults()
      
      table = [
        {"tr", [], []},
        {"tr", [], [
          {"td", [], ["Data"]}
        ]},
        {"tr", [], []}
      ]
      
      result = TableConverter.process_table(table, opts)
      
      assert String.contains?(result, "|  |")
      assert String.contains?(result, "| Data |")
    end

    test "handles malformed rows" do
      opts = Options.defaults()
      
      table = [
        {"tr", [], [
          {"td", [], ["Normal cell"]},
          "Text node",
          {"td", [], ["Another cell"]}
        ]},
        {"not-tr", [], ["Should be ignored"]},
        {"tr", [], [
          {"td", [], ["Final row"]}
        ]}
      ]
      
      result = TableConverter.process_table(table, opts)
      
      # Should handle text nodes and non-tr elements gracefully
      # Text nodes are processed but may not preserve exact text
      assert String.contains?(result, "| Normal cell")
      assert String.contains?(result, "Another cell |")
      assert String.contains?(result, "| Final row")
    end

    test "adjusts column count for irregular tables" do
      opts = Options.defaults()
      
      table = [
        {"tr", [], [
          {"td", [], ["A"]},
          {"td", [], ["B"]},
          {"td", [], ["C"]}
        ]},
        {"tr", [], [
          {"td", [], ["D"]}
        ]},
        {"tr", [], [
          {"td", [], ["E"]},
          {"td", [], ["F"]}
        ]}
      ]
      
      result = TableConverter.process_table(table, opts)
      
      # Should pad shorter rows with empty cells
      assert String.contains?(result, "| A | B | C |")
      assert String.contains?(result, "| D |  |  |")
      assert String.contains?(result, "| E | F |  |")
    end

    test "handles very large colspan values" do
      opts = Options.defaults()
      
      table = [
        {"tr", [], [
          {"td", [{"colspan", "10"}], ["Wide cell"]}
        ]},
        {"tr", [], [
          {"td", [], ["A"]},
          {"td", [], ["B"]}
        ]}
      ]
      
      result = TableConverter.process_table(table, opts)
      
      # Should repeat content for all 10 columns
      assert result =~ ~r/Wide cell.*Wide cell.*Wide cell/
    end
  end

  describe "process_table/2 - real world examples" do
    test "converts Phoenix router table" do
      opts = Options.defaults()
      
      table = [
        {"thead", [], [
          {"tr", [], [
            {"th", [], ["Method"]},
            {"th", [], ["Path"]},
            {"th", [], ["Controller#Action"]}
          ]}
        ]},
        {"tbody", [], [
          {"tr", [], [
            {"td", [], ["GET"]},
            {"td", [], [{"code", [], ["/"]}]},
            {"td", [], ["PageController#index"]}
          ]},
          {"tr", [], [
            {"td", [], ["GET"]},
            {"td", [], [{"code", [], ["/users"]}]},
            {"td", [], ["UserController#index"]}
          ]},
          {"tr", [], [
            {"td", [], ["POST"]},
            {"td", [], [{"code", [], ["/users"]}]},
            {"td", [], ["UserController#create"]}
          ]}
        ]}
      ]
      
      result = TableConverter.process_table(table, opts)
      
      assert String.contains?(result, "| Method | Path | Controller#Action |")
      assert String.contains?(result, "| --- | --- | --- |")
      assert String.contains?(result, "| GET | `/` | PageController#index |")
      assert String.contains?(result, "| GET | `/users` | UserController#index |")
      assert String.contains?(result, "| POST | `/users` | UserController#create |")
    end

    test "converts Ecto migration table" do
      opts = Options.defaults()
      
      table = [
        {"tr", [], [
          {"th", [], ["Type"]},
          {"th", [], ["Elixir"]},
          {"th", [], ["PostgreSQL"]},
          {"th", [], ["MySQL"]}
        ]},
        {"tr", [], [
          {"td", [], [{"code", [], [":id"]}]},
          {"td", [], ["integer"]},
          {"td", [], ["serial"]},
          {"td", [], ["integer auto_increment"]}
        ]},
        {"tr", [], [
          {"td", [], [{"code", [], [":string"]}]},
          {"td", [], ["string"]},
          {"td", [], ["varchar"]},
          {"td", [], ["varchar"]}
        ]},
        {"tr", [], [
          {"td", [], [{"code", [], [":text"]}]},
          {"td", [], ["string"]},
          {"td", [], ["text"]},
          {"td", [], ["text"]}
        ]}
      ]
      
      result = TableConverter.process_table(table, opts)
      
      assert String.contains?(result, "| Type | Elixir | PostgreSQL | MySQL |")
      assert String.contains?(result, "| `:id` | integer | serial | integer auto_increment |")
      assert String.contains?(result, "| `:string` | string | varchar | varchar |")
      assert String.contains?(result, "| `:text` | string | text | text |")
    end
  end
end