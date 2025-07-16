defmodule Html2Markdown do
  @moduledoc """
  A library for converting HTML to Markdown syntax in Elixir
  
  ## Configuration Options (Phase 1.1 Implementation)
  
  The library now supports configuration options via `convert/2`:
  
  - `:navigation_classes` - Customize which CSS classes identify navigation elements to remove
  - `:non_content_tags` - Customize which HTML tags to filter out during conversion
  - `:markdown_flavor` - Currently only `:basic` is supported (future enhancement)
  - `:normalize_whitespace` - Currently not implemented (future enhancement)
  
  Note: HTML entity decoding is performed automatically by Floki and cannot be disabled.
  """

  @default_options %{
    navigation_classes: ["footer", "menu", "nav", "sidebar", "aside"],
    non_content_tags: [
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
    ],
    markdown_flavor: :basic,
    normalize_whitespace: true
  }

  @doc """
  Converts the content from an HTML document to Markdown (removing non-content sections and tags)
  
  Uses default options for conversion. To customize behavior, use `convert/2`.
  """
  def convert(document) when is_binary(document) do
    convert(document, %{})
  end

  @doc """
  Converts the content from an HTML document to Markdown with custom options

  ## Options

    * `:navigation_classes` - List of CSS classes to identify navigation elements to remove.
      Defaults to `["footer", "menu", "nav", "sidebar", "aside"]`
    * `:non_content_tags` - List of HTML tags to filter out during conversion.
      Defaults to common non-content tags like script, style, form, etc.
    * `:markdown_flavor` - Markdown flavor to use. Currently only `:basic` is supported. 
      Defaults to `:basic` (future enhancement for `:gfm`, `:commonmark`)
    * `:normalize_whitespace` - Whether to normalize whitespace. Defaults to `true`
      (not yet implemented)

  ## Examples

      iex> Html2Markdown.convert("<p>Hello</p>", %{navigation_classes: ["custom-nav"]})
      "Hello"

  """
  def convert(document, options) when is_binary(document) and is_map(options) do
    opts = Map.merge(@default_options, options)

    document
    |> preprocess_content(opts)
    |> convert_to_markdown(opts)
  end

  def convert(_document, _options), do: {:error, "Could not convert HTML to Markdown"}

  defp preprocess_content(content, opts) do
    content
    |> prep_document()
    |> Floki.parse_document!()
    |> Floki.find("body")
    |> Floki.filter_out(:comment)
    |> remove_non_content_tags(opts.non_content_tags)
    |> remove_nav_elements(opts.navigation_classes)
  end

  defp prep_document(content) do
    if is_html_document?(content), do: content, else: wrap_fragment(content)
  end

  defp is_html_document?(content) do
    content
    |> String.downcase()
    |> String.contains?(["<html", "<body", "<head"])
  end

  defp wrap_fragment(fragment), do: "<html><body>#{fragment}</body></html>"

  defp remove_non_content_tags(document, non_content_tags) do
    Enum.reduce(non_content_tags, document, &Floki.filter_out(&2, &1))
  end

  defp remove_nav_elements(document, navigation_classes) do
    Floki.find_and_update(document, "*", fn
      {tag, attrs} when is_list(attrs) ->
        case List.keyfind(attrs, "class", 0) do
          {"class", class} ->
            if contains_nav_class?(class, navigation_classes) && tag != "body" do
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

  defp contains_nav_class?(string, navigation_classes) do
    Enum.any?(navigation_classes, &String.contains?(string, &1))
  end

  defp convert_to_markdown(document, opts) do
    Enum.map_join(document, "\n\n", &process_node(&1, opts))
  end

  defp process_node({"h1", _, children}, opts),
    do: newline() <> "# #{process_children(children, opts)}" <> newline()

  defp process_node({"h2", _, children}, opts),
    do: newline() <> "## #{process_children(children, opts)}" <> newline()

  defp process_node({"h3", _, children}, opts),
    do: newline() <> "### #{process_children(children, opts)}" <> newline()

  defp process_node({"h4", _, children}, opts),
    do: newline() <> "#### #{process_children(children, opts)}" <> newline()

  defp process_node({"h5", _, children}, opts),
    do: newline() <> "##### #{process_children(children, opts)}" <> newline()

  defp process_node({"h6", _, children}, opts),
    do: newline() <> "###### #{process_children(children, opts)}" <> newline()

  defp process_node({"p", _, children}, opts),
    do: newline() <> "#{process_children(children, opts)}" <> newline()

  defp process_node({"ul", _, children}, opts), do: process_ul_list(children, opts)
  defp process_node({"ol", _, children}, opts), do: process_ol_list(children, opts)
  defp process_node({"li", _, children}, opts), do: "- " <> process_children(children, opts) <> newline()

  defp process_node({"pre", _, [{"code", [{"class", classes}], children}]}, opts),
    do: process_code_block(classes, children, opts)

  defp process_node({"pre", _, [{"code", _, children}]}, opts),
    do: process_code_block(children, opts)

  defp process_node({"pre", _, children}, opts), do: process_code_block(children, opts)

  defp process_node({"blockquote", _, children}, opts),
    do: newline() <> "> #{process_children(children, opts)}" <> newline()

  defp process_node({"table", _, children}, opts), do: process_table(children, opts)
  defp process_node({"strong", _, children}, opts), do: "**#{process_children(children, opts)}**"
  defp process_node({"b", _, children}, opts), do: "**#{process_children(children, opts)}**"
  defp process_node({"em", _, children}, opts), do: "*#{process_children(children, opts)}*"
  defp process_node({"i", _, children}, opts), do: "*#{process_children(children, opts)}*"
  defp process_node({"u", _, children}, opts), do: "<u>#{process_children(children, opts)}</u>"
  defp process_node({"del", _, children}, opts), do: "~~#{process_children(children, opts)}~~"
  defp process_node({"sup", _, children}, opts), do: "<sup>#{process_children(children, opts)}</sup>"
  defp process_node({"sub", _, children}, opts), do: "<sub>#{process_children(children, opts)}</sub>"
  defp process_node({"code", _, children}, opts), do: "`#{process_children(children, opts)}`"
  defp process_node({"a", attrs, children}, opts), do: process_href(attrs, children, opts)
  defp process_node({"img", [{"src", src}, {"alt", alt}], _}, _opts), do: "![#{alt}](#{src})"

  defp process_node({"caption", _, children}, opts),
    do: "| " <> process_children(children, opts) <> " |" <> newline()

  defp process_node({"figcaption", _, children}, opts), do: "**#{process_children(children, opts)}**"
  defp process_node({"br", _, _}, _opts), do: newline(2)
  defp process_node({"hr", _, _}, _opts), do: newline() <> newline() <> "---" <> newline(2)

  defp process_node({"section", _, children}, opts),
    do: newline() <> "#{process_children(children, opts)}" <> newline()

  defp process_node({"article", _, children}, opts),
    do: newline() <> "#{process_children(children, opts)}" <> newline()

  defp process_node({"picture", _, children}, _opts) do
    with {"img", attrs, _} <- Enum.find(children, fn {tag, _, _} -> tag == "img" end),
         %{"alt" => alt, "src" => src} <- Enum.into(attrs, %{}) do
      "![#{alt}](#{src})"
    end
  end

  defp process_node({"div", _, children}, opts), do: "#{process_children(children, opts)}" <> newline()
  defp process_node({_, _, children}, opts), do: process_children(children, opts)
  defp process_node(text, _opts) when is_binary(text), do: String.trim(text)

  defp process_href(attrs, children, opts) do
    case Enum.find(attrs, fn {attr, _} -> attr == "href" end) do
      {"href", url} ->
        case process_children(children, opts) do
          "" -> "[#{url}](#{url})"
          children -> "[#{children}](#{url})"
        end

      _ ->
        process_children(children, opts)
    end
  end

  defp process_code_block(children, opts) do
    newline() <> "```\n#{process_children(children, opts)}\n```" <> newline()
  end

  defp process_code_block(classes, children, opts) do
    language = detect_language(classes)
    newline() <> "```#{language}\n#{process_children(children, opts)}\n```" <> newline()
  end

  defp detect_language(classes) do
    case Regex.run(~r/language-(\w+)/, classes) do
      [_, lang] -> lang
      _ -> ""
    end
  end

  defp process_ul_list(children, opts) when is_list(children) do
    newline() <> Enum.map_join(children, "\n", &process_list_item(&1, opts)) <> newline()
  end

  defp process_ol_list(children, opts) when is_list(children) do
    ol_list =
      children
      |> Enum.with_index()
      |> Enum.map_join("\n", fn {child, index} ->
        process_ordered_list_item(child, index + 1, opts)
      end)

    newline() <> ol_list <> newline()
  end

  defp process_list_item({"li", _, children}, opts), do: "- " <> process_children(children, opts)
  defp process_list_item(other, opts), do: process_node(other, opts)

  defp process_ordered_list_item({"li", _, children}, index, opts),
    do: "#{index}. " <> process_children(children, opts)

  defp process_ordered_list_item(other, _index, opts), do: process_node(other, opts)

  defp process_table(children, opts) do
    table =
      children
      |> extract_rows()
      |> process_table_rows(opts)

    newline() <> table <> newline()
  end

  defp extract_rows(children) do
    # Check for thead and tbody
    thead =
      Enum.find(children, fn
        {"thead", _, _} -> true
        _ -> false
      end)

    tbody =
      Enum.find(children, fn
        {"tbody", _, _} -> true
        _ -> false
      end)

    case {thead, tbody} do
      {{"thead", _, thead_rows}, {"tbody", _, tbody_rows}} ->
        # Combine thead and tbody rows
        thead_rows ++ tbody_rows

      {nil, {"tbody", _, rows}} ->
        # Only tbody
        rows

      {{"thead", _, rows}, nil} ->
        # Only thead
        rows

      _ ->
        # Direct rows (no thead/tbody wrapper)
        children
    end
  end

  defp process_table_rows(rows, opts) do
    # Get the number of columns from the first row
    column_count =
      case List.first(rows) do
        {"tr", _, cells} when is_list(cells) ->
          Enum.reduce(cells, 0, fn
            {_, attrs, _}, acc ->
              colspan = get_colspan(attrs)
              if colspan > 1, do: acc + colspan, else: acc + 1

            _, acc ->
              acc + 1
          end)

        # default column count
        _ ->
          3
      end

    # Check if first row has only th elements (indicating it's a header row)
    is_header_row =
      case List.first(rows) do
        {"tr", _, cells} when is_list(cells) ->
          Enum.all?(cells, fn
            {"th", _, _} -> true
            _ -> false
          end)

        _ ->
          false
      end

    rows
    |> Enum.with_index()
    |> Enum.map_join("\n", fn {row, index} ->
      row_str = process_table_row(row, column_count, opts)

      if index == 0 && is_header_row do
        row_str <> newline() <> header_separator(row)
      else
        row_str
      end
    end)
  end

  # Process table row with column count

  defp process_table_row({"tr", _attrs, cells}, column_count, opts)
       when is_list(cells) and length(cells) > 0 do
    case List.first(cells) do
      nil ->
        "|  |"

      {_, attrs, _} ->
        colspan = get_colspan(attrs)

        processed_cells =
          if colspan > 1 do
            {_, _, content} = List.first(cells)
            cell_content = process_children(content, opts)
            # Repeat the content for each column spanned
            Enum.map_join(1..colspan, " | ", fn _ -> cell_content end)
          else
            # Process all cells normally
            cell_contents = Enum.map(cells, &process_table_cell(&1, opts))
            # Calculate how many cells were processed
            cells_count =
              Enum.reduce(cells, 0, fn
                {_, cell_attrs, _}, acc ->
                  cell_colspan = get_colspan(cell_attrs)
                  if cell_colspan > 1, do: acc + cell_colspan, else: acc + 1

                _, acc ->
                  acc + 1
              end)

            # Add empty cells if needed to match column count
            if cells_count < column_count do
              empty_cells = List.duplicate("", column_count - cells_count)
              Enum.join(cell_contents ++ empty_cells, " | ")
            else
              Enum.join(cell_contents, " | ")
            end
          end

        "| " <> processed_cells <> " |"

      _ ->
        # Handle non-standard cell format (e.g., plain text)
        "| " <> Enum.map_join(cells, " | ", &process_cell(&1, opts)) <> " |"
    end
  end

  defp process_table_row({"tr", _attrs, []}, _column_count, _opts), do: "|  |"
  defp process_table_row({"tr", _attrs, nil}, _column_count, _opts), do: "|  |"
  defp process_table_row(_, _, _), do: ""

  # Helper function to handle various cell formats
  defp process_cell({_, _, content}, opts), do: process_children(content, opts)
  defp process_cell(text, _opts) when is_binary(text), do: String.trim(text)
  defp process_cell(_, _), do: ""

  defp process_table_cell({_, attrs, content}, opts) do
    cell_content = process_children(content, opts)
    indent = get_indent(attrs)
    String.duplicate("&ensp;", indent) <> cell_content
  end

  defp process_table_cell(_, _), do: ""

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

  defp header_separator({"thead", _, [{"tr", _, cells}]}), do: header_separator({"tr", [], cells})

  defp header_separator({"tr", _, cells}) when is_list(cells) do
    case cells do
      [] ->
        "| --- |"

      _ ->
        case List.first(cells) do
          nil ->
            "| --- |"

          {_, attrs, _} ->
            colspan = get_colspan(attrs)

            separator =
              if colspan >= 1 do
                Enum.map_join(1..colspan, " | ", fn _ -> "---" end)
              else
                Enum.map_join(cells, " | ", fn _ -> "---" end)
              end

            "| " <> separator <> " |"

          _ ->
            # Handle non-standard cell format
            "| " <> Enum.map_join(cells, " | ", fn _ -> "---" end) <> " |"
        end
    end
  end

  defp header_separator(_), do: "| --- |"

  defp process_children(children, opts) do
    children
    |> Enum.map_join(" ", &process_node(&1, opts))
    |> String.trim()
  end

  defp newline, do: "\n"
  defp newline(count), do: String.duplicate("\n", count)
end
