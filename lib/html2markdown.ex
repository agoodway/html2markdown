defmodule Html2Markdown do
  @moduledoc """
  A library for converting HTML to Markdown syntax in Elixir
  """

  @navigation_classes ["footer", "menu", "nav", "sidebar", "aside"]

  @non_content_tags [
    "aside",
    "audio",
    "base",
    "button",
    "datalist",
    "embed",
    "form",
    "iframe",
    "input",
    "keygen",
    "nav",
    "noscript",
    "object",
    "output",
    "script",
    "select",
    "source",
    "style",
    "svg",
    "template",
    "textarea",
    "track",
    "video"
  ]

  @doc """
  Converts the content from an HTML document to Markdown (removing non-content sections and tags)

  TODO:
  - Allow passing/overriding of tags and classes
  - Allow skipping of tag & element removal
  - Handle lists nested within lists
  - Deal with space between end of sentence and period (and similar cases)
  """
  def convert(document) when is_binary(document) do
    document
    |> preprocess_content()
    |> markdown()
  end

  def convert(_document), do: {:error, "Could not convert HTML to Markdown"}

  defp preprocess_content(document) do
    document
    |> Floki.parse_document!()
    |> Floki.find("body")
    |> Floki.filter_out(:comment)
    |> remove_non_content_tags()
    |> remove_nav_elements()
  end

  defp remove_non_content_tags(document) do
    Enum.reduce(@non_content_tags, document, &Floki.filter_out(&2, &1))
  end

  defp remove_nav_elements(document) do
    Floki.find_and_update(document, "*", fn
      {tag, attrs} when is_list(attrs) ->
        case List.keyfind(attrs, "class", 0) do
          {"class", class} ->
            if contains_nav_class?(class) do
              :delete
            else
              {tag, attrs}
            end

          _ ->
            {tag, attrs}
        end

      element ->
        element
    end)
  end

  defp contains_nav_class?(string) do
    Enum.any?(@navigation_classes, &String.contains?(string, &1))
  end

  defp markdown(document) do
    Enum.map_join(document, "\n\n", &process_node/1)
  end

  defp process_node({"h1", _, children}),
    do: newline() <> "# #{process_children(children)}" <> newline()

  defp process_node({"h2", _, children}),
    do: newline() <> "## #{process_children(children)}" <> newline()

  defp process_node({"h3", _, children}),
    do: newline() <> "### #{process_children(children)}" <> newline()

  defp process_node({"h4", _, children}),
    do: newline() <> "#### #{process_children(children)}" <> newline()

  defp process_node({"h5", _, children}),
    do: newline() <> "##### #{process_children(children)}" <> newline()

  defp process_node({"h6", _, children}),
    do: newline() <> "###### #{process_children(children)}" <> newline()

  defp process_node({"p", _, children}),
    do: newline() <> "#{process_children(children)}" <> newline()

  defp process_node({"ul", _, children}), do: process_ul_list(children)
  defp process_node({"ol", _, children}), do: process_ol_list(children)
  defp process_node({"li", _, children}), do: "- " <> process_children(children) <> newline()

  defp process_node({"pre", _, [{"code", [{"class", classes}], children}]}),
    do: process_code_block(classes, children)

  defp process_node({"pre", _, children}), do: process_code_block(children)

  defp process_node({"blockquote", _, children}),
    do: newline() <> "> #{process_children(children)}" <> newline()

  defp process_node({"table", _, children}), do: process_table(children)
  defp process_node({"strong", _, children}), do: "**#{process_children(children)}**"
  defp process_node({"b", _, children}), do: "**#{process_children(children)}**"
  defp process_node({"em", _, children}), do: "*#{process_children(children)}*"
  defp process_node({"i", _, children}), do: "*#{process_children(children)}*"
  defp process_node({"u", _, children}), do: "<u>#{process_children(children)}</u>"
  defp process_node({"del", _, children}), do: "~~#{process_children(children)}~~"
  defp process_node({"sup", _, children}), do: "<sup>#{process_children(children)}</sup>"
  defp process_node({"sub", _, children}), do: "<sub>#{process_children(children)}</sub>"
  defp process_node({"code", _, children}), do: "`#{process_children(children)}`"
  defp process_node({"a", attrs, children}), do: process_href(attrs, children)
  defp process_node({"img", [{"src", src}, {"alt", alt}], _}), do: "![#{alt}](#{src})"

  defp process_node({"caption", _, children}),
    do: "| " <> process_children(children) <> " |" <> newline()

  defp process_node({"figcaption", _, children}), do: "**#{process_children(children)}**"
  defp process_node({"br", _, _}), do: newline(2)
  defp process_node({"hr", _, _}), do: newline() <> newline() <> "---" <> newline(2)

  defp process_node({"section", _, children}),
    do: newline() <> "#{process_children(children)}" <> newline()

  defp process_node({"article", _, children}),
    do: newline() <> "#{process_children(children)}" <> newline()

  defp process_node({"div", _, children}), do: "#{process_children(children)}" <> newline()
  defp process_node({_, _, children}), do: process_children(children)
  defp process_node(text) when is_binary(text), do: String.trim(text)

  defp process_href(attrs, children) do
    case Enum.find(attrs, fn {attr, _} -> attr == "href" end) do
      {"href", url} -> "[#{process_children(children)}](#{url})"
      _ -> process_children(children)
    end
  end

  defp process_code_block(children) do
    newline() <> "```\n#{process_children(children)}\n```" <> newline()
  end

  defp process_code_block(classes, children) do
    language = detect_language(classes)
    newline() <> "```#{language}\n#{process_children(children)}\n```" <> newline()
  end

  defp detect_language(classes) do
    case Regex.run(~r/language-(\w+)/, classes) do
      [_, lang] -> lang
      _ -> ""
    end
  end

  defp process_ul_list(children) when is_list(children) do
    newline() <> Enum.map_join(children, "\n", &process_list_item/1) <> newline()
  end

  defp process_ol_list(children) when is_list(children) do
    ol_list =
      children
      |> Enum.with_index()
      |> Enum.map_join("\n", fn {child, index} ->
        process_ordered_list_item(child, index + 1)
      end)

    newline() <> ol_list <> newline()
  end

  defp process_list_item({"li", _, children}), do: "- " <> process_children(children)
  defp process_list_item(other), do: process_node(other)

  defp process_ordered_list_item({"li", _, children}, index),
    do: "#{index}. " <> process_children(children)

  defp process_ordered_list_item(other, _index), do: process_node(other)

  defp process_table(children) do
    table =
      children
      |> extract_rows()
      |> process_table_rows()

    newline() <> table <> newline()
  end

  defp extract_rows(children) do
    rows =
      Enum.find(children, fn
        {"tbody", _, _} -> true
        _ -> false
      end)

    case rows do
      {"tbody", _, rows} -> rows
      _ -> children
    end
  end

  defp process_table_rows(rows) do
    rows
    |> Enum.with_index()
    |> Enum.map_join("\n", fn {row, index} ->
      row_str = process_table_row(row)

      if index == 0 do
        row_str <> newline() <> header_separator(row)
      else
        row_str
      end
    end)
  end

  defp process_table_row({"tr", _attrs, cells}) do
    {_, attrs, _} = List.first(cells)
    colspan = get_colspan(attrs)

    processed_cells =
      if colspan >= 1 do
        {_, _, content} = List.first(cells)
        cell_content = process_children(content)
        spans = Enum.map_join(1..colspan, " | ", &process_table_cell/1)
        cell_content <> spans
      else
        Enum.map_join(cells, " | ", &process_table_cell/1)
      end

    "| " <> processed_cells <> " |"
  end

  defp process_table_row(_), do: ""

  defp process_table_cell({_, attrs, content}) do
    cell_content = process_children(content)
    indent = get_indent(attrs)
    String.duplicate("&ensp;", indent) <> cell_content
  end

  defp process_table_cell(_), do: ""

  defp get_colspan(attrs) do
    case Enum.find(attrs, fn {attr, _} -> attr == "colspan" end) do
      {"colspan", value} -> String.to_integer(value)
      _ -> 0
    end
  end

  defp get_indent(attrs) do
    case Enum.find(attrs, fn {attr, _} -> attr == "style" end) do
      {"style", style} ->
        case Regex.run(~r/padding-left:(\d+\.\d+)em;/, style) do
          [_, indent] ->
            indent |> String.to_float() |> ceil()

          _ ->
            0
        end

      _ ->
        0
    end
  end

  defp header_separator({"tr", _, cells}) do
    {_, attrs, _} = List.first(cells)
    colspan = get_colspan(attrs)

    separator =
      if colspan >= 1 do
        Enum.map_join(1..colspan, " | ", fn _ -> "---" end)
      else
        Enum.map_join(cells, " | ", fn _ -> "---" end)
      end

    "| " <> separator <> " |"
  end

  defp process_children(children) do
    children
    |> Enum.map_join(" ", &process_node/1)
    |> String.trim()
  end

  defp newline, do: "\n"
  defp newline(count), do: String.duplicate("\n", count)
end
