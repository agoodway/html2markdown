defmodule Html2Markdown.TableConverter do
  @moduledoc """
  Handles conversion of HTML tables to Markdown format.

  Converts HTML tables to GitHub Flavored Markdown tables with support for:
  - Header detection (from `<th>` elements or `<thead>`)
  - Complex table structures with `<thead>` and `<tbody>`
  - Colspan handling (content repeated across columns)
  - Empty cells and malformed tables

  ## Examples

      # Simple table
      <table>
        <tr><th>Name</th><th>Age</th></tr>
        <tr><td>Alice</td><td>30</td></tr>
      </table>

      # Converts to:
      | Name | Age |
      | --- | --- |
      | Alice | 30 |

  ## Implementation Notes

  - Tables without headers still generate valid Markdown tables
  - Empty cells are preserved as empty columns
  - Malformed HTML is handled gracefully
  """

  alias Html2Markdown.{Converter, Options}

  @spec process_table(list(Floki.html_node()), Options.t()) :: String.t()
  def process_table(children, opts) do
    table =
      children
      |> extract_rows()
      |> process_table_rows(opts)

    "\n" <> table <> "\n"
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
        row_str <> "\n" <> header_separator(row)
      else
        row_str
      end
    end)
  end

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
            cell_content = Converter.process_children(content, opts)
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
  defp process_cell({_, _, content}, opts), do: Converter.process_children(content, opts)
  defp process_cell(text, _opts) when is_binary(text), do: String.trim(text)
  defp process_cell(_, _), do: ""

  defp process_table_cell({_, attrs, content}, opts) do
    cell_content = Converter.process_children(content, opts)
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
end
