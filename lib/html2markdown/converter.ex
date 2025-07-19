defmodule Html2Markdown.Converter do
  @moduledoc """
  Handles the conversion of HTML nodes to Markdown format.

  This module is responsible for transforming parsed HTML nodes into their
  Markdown equivalents. It uses an efficient IOList-based approach for
  building the output string.

  ## Implementation Details

  The converter uses pattern matching to handle different HTML elements:
  - Headers (`h1`-`h6`) → Markdown headers with appropriate `#` prefixes
  - Text formatting (`strong`, `em`, `del`) → Markdown emphasis markers
  - Lists (`ul`, `ol`) → Markdown list syntax with proper nesting
  - Tables → Delegated to `Html2Markdown.TableConverter`
  - Links and images → Markdown link syntax
  - Code blocks → Fenced code blocks with language detection

  ## Performance Optimizations

  - Uses IOList building instead of string concatenation
  - Processes nodes in a single pass
  - Preserves whitespace in code blocks while normalizing elsewhere
  """

  alias Html2Markdown.{TableConverter, Options}

  @spec convert_to_markdown(list(Floki.html_node()), Options.t()) :: String.t()
  def convert_to_markdown(document, opts) do
    document
    |> build_markdown_iolist(opts)
    |> IO.iodata_to_binary()
  end

  # Optimized: Build iolist instead of string concatenation
  defp build_markdown_iolist(nodes, opts) do
    nodes
    |> Enum.reduce({[], nil}, fn node, {acc, prev_node_type} ->
      case process_node_to_iolist(node, opts) do
        [] ->
          {acc, prev_node_type}

        "" ->
          {acc, prev_node_type}

        iodata ->
          current_node_type = get_node_type(node)
          
          new_acc = if acc == [] do
            [iodata]
          else
            separator = get_separator(prev_node_type, current_node_type)
            [acc, separator, iodata]
          end
          
          {new_acc, current_node_type}
      end
    end)
    |> elem(0)  # Extract just the accumulated iolist
  end

  # Get the type of node for spacing decisions
  defp get_node_type({tag, _, _}) when is_binary(tag), do: tag
  defp get_node_type(_), do: :text

  # Determine the separator between different node types
  defp get_separator("p", "p"), do: "\n \n"
  defp get_separator(_, _), do: "\n\n"

  # Process nodes to iolist for better performance
  defp process_node_to_iolist({"h1", _, children}, opts),
    do: ["\n", "# ", process_children_to_iolist(children, opts), "\n"]

  defp process_node_to_iolist({"h2", _, children}, opts),
    do: ["\n", "## ", process_children_to_iolist(children, opts), "\n"]

  defp process_node_to_iolist({"h3", _, children}, opts),
    do: ["\n", "### ", process_children_to_iolist(children, opts), "\n"]

  defp process_node_to_iolist({"h4", _, children}, opts),
    do: ["\n", "#### ", process_children_to_iolist(children, opts), "\n"]

  defp process_node_to_iolist({"h5", _, children}, opts),
    do: ["\n", "##### ", process_children_to_iolist(children, opts), "\n"]

  defp process_node_to_iolist({"h6", _, children}, opts),
    do: ["\n", "###### ", process_children_to_iolist(children, opts), "\n"]

  defp process_node_to_iolist({"p", _, children}, opts),
    do: process_children_to_iolist(children, opts)

  defp process_node_to_iolist({"ul", _, children}, opts),
    do: process_ul_list_to_iolist(children, opts)

  defp process_node_to_iolist({"ol", _, children}, opts),
    do: process_ol_list_to_iolist(children, opts)

  defp process_node_to_iolist({"li", _, children}, opts),
    do: ["- ", process_children_to_iolist(children, opts), "\n"]

  defp process_node_to_iolist({"pre", _, [{"code", [{"class", classes}], children}]}, opts),
    do: process_code_block_to_iolist(classes, children, opts)

  defp process_node_to_iolist({"pre", _, [{"code", _, children}]}, opts),
    do: process_code_block_to_iolist(children, opts)

  defp process_node_to_iolist({"pre", _, children}, opts),
    do: process_code_block_to_iolist(children, opts)

  defp process_node_to_iolist({"blockquote", _, children}, opts),
    do: ["\n", "> ", process_children_to_iolist(children, opts), "\n"]

  defp process_node_to_iolist({"dl", _, children}, opts),
    do: process_definition_list_to_iolist(children, opts)

  defp process_node_to_iolist({"dt", _, children}, opts),
    do: ["**", process_children_to_iolist(children, opts), "**"]

  defp process_node_to_iolist({"dd", _, children}, opts),
    do: [": ", process_children_to_iolist(children, opts)]

  defp process_node_to_iolist({"table", _, children}, opts),
    do: TableConverter.process_table(children, opts)

  defp process_node_to_iolist({"strong", _, children}, opts),
    do: ["**", process_children_to_iolist(children, opts), "**"]

  defp process_node_to_iolist({"b", _, children}, opts),
    do: ["**", process_children_to_iolist(children, opts), "**"]

  defp process_node_to_iolist({"em", _, children}, opts),
    do: ["*", process_children_to_iolist(children, opts), "*"]

  defp process_node_to_iolist({"i", _, children}, opts),
    do: ["*", process_children_to_iolist(children, opts), "*"]

  defp process_node_to_iolist({"u", _, children}, opts),
    do: ["<u>", process_children_to_iolist(children, opts), "</u>"]

  defp process_node_to_iolist({"del", _, children}, opts),
    do: ["~~", process_children_to_iolist(children, opts), "~~"]

  defp process_node_to_iolist({"sup", _, children}, opts),
    do: ["<sup>", process_children_to_iolist(children, opts), "</sup>"]

  defp process_node_to_iolist({"sub", _, children}, opts),
    do: ["<sub>", process_children_to_iolist(children, opts), "</sub>"]

  defp process_node_to_iolist({"code", _, children}, opts) do
    # Disable whitespace normalization for inline code
    code_opts = Map.put(opts, :normalize_whitespace, false)
    ["`", process_children_to_iolist(children, code_opts), "`"]
  end

  defp process_node_to_iolist({"a", attrs, children}, opts),
    do: process_href_to_iolist(attrs, children, opts)

  defp process_node_to_iolist({"img", attrs, _}, _opts) do
    case {List.keyfind(attrs, "src", 0), List.keyfind(attrs, "alt", 0)} do
      {{"src", src}, {"alt", alt}} -> ["![", alt, "](", src, ")"]
      {{"src", src}, _} -> ["![](", src, ")"]
      _ -> []
    end
  end

  defp process_node_to_iolist({"caption", _, children}, opts),
    do: ["| ", process_children_to_iolist(children, opts), " |\n"]

  defp process_node_to_iolist({"figcaption", _, children}, opts),
    do: ["**", process_children_to_iolist(children, opts), "**"]

  # HTML5 elements
  defp process_node_to_iolist({"details", _, children}, opts),
    do: process_details_to_iolist(children, opts)

  defp process_node_to_iolist({"summary", _, children}, opts),
    do: ["**", process_children_to_iolist(children, opts), "**"]

  defp process_node_to_iolist({"mark", _, children}, opts) do
    # Use == for marked/highlighted text if GFM flavor, otherwise bold
    if opts[:markdown_flavor] == :gfm do
      ["==", process_children_to_iolist(children, opts), "=="]
    else
      ["**", process_children_to_iolist(children, opts), "**"]
    end
  end

  defp process_node_to_iolist({"abbr", attrs, children}, opts) do
    case List.keyfind(attrs, "title", 0) do
      {"title", title} ->
        ["", process_children_to_iolist(children, opts), " (", title, ")"]

      _ ->
        process_children_to_iolist(children, opts)
    end
  end

  defp process_node_to_iolist({"cite", _, children}, opts),
    do: ["*", process_children_to_iolist(children, opts), "*"]

  defp process_node_to_iolist({"q", attrs, children}, opts) do
    # Handle cite attribute if present
    quote_content = ["\"", process_children_to_iolist(children, opts), "\""]

    case List.keyfind(attrs, "cite", 0) do
      {"cite", url} ->
        [quote_content, " (", url, ")"]

      _ ->
        quote_content
    end
  end

  defp process_node_to_iolist({"time", attrs, children}, opts) do
    case List.keyfind(attrs, "datetime", 0) do
      {"datetime", datetime} ->
        # Include datetime as title attribute in markdown
        ["", process_children_to_iolist(children, opts), " <time datetime=\"", datetime, "\">"]

      _ ->
        process_children_to_iolist(children, opts)
    end
  end

  defp process_node_to_iolist({"video", attrs, _}, _opts) do
    case List.keyfind(attrs, "src", 0) do
      {"src", src} ->
        # Convert video to a link
        ["[Video](", src, ")"]

      _ ->
        # Check for source children
        "[Video]"
    end
  end

  defp process_node_to_iolist({"br", _, _}, _opts), do: "\n\n"
  defp process_node_to_iolist({"hr", _, _}, _opts), do: "\n\n---\n\n"

  defp process_node_to_iolist({"section", _, children}, opts),
    do: ["\n", process_children_to_iolist(children, opts), "\n"]

  defp process_node_to_iolist({"article", _, children}, opts),
    do: ["\n", process_children_to_iolist(children, opts), "\n"]

  defp process_node_to_iolist({"picture", _, children}, opts) do
    case Enum.find(children, fn
           {tag, _, _} when is_binary(tag) -> tag == "img"
           _ -> false
         end) do
      {"img", attrs, _} ->
        case {List.keyfind(attrs, "src", 0), List.keyfind(attrs, "alt", 0)} do
          {{"src", src}, {"alt", alt}} -> ["![", alt, "](", src, ")"]
          {{"src", src}, _} -> ["![](", src, ")"]
          _ -> []
        end

      _ ->
        # No img found, process children normally
        process_children_to_iolist(children, opts)
    end
  end

  defp process_node_to_iolist({"div", _, children}, opts),
    do: [process_children_to_iolist(children, opts), "\n"]

  defp process_node_to_iolist({_, _, children}, opts),
    do: process_children_to_iolist(children, opts)

  defp process_node_to_iolist(text, opts) when is_binary(text) do
    if opts.normalize_whitespace do
      text
      |> String.trim()
      |> normalize_whitespace()
    else
      text
    end
  end

  defp process_href_to_iolist(attrs, children, opts) do
    case List.keyfind(attrs, "href", 0) do
      {"href", url} ->
        children_text = IO.iodata_to_binary(process_children_to_iolist(children, opts))

        if children_text == "" do
          ["[", url, "](", url, ")"]
        else
          ["[", children_text, "](", url, ")"]
        end

      _ ->
        process_children_to_iolist(children, opts)
    end
  end

  defp process_code_block_to_iolist(children, opts) do
    # Disable whitespace normalization for code blocks
    code_opts = Map.put(opts, :normalize_whitespace, false)
    content = process_children_to_iolist(children, code_opts)
    ["\n```\n", content, "\n```\n"]
  end

  defp process_code_block_to_iolist(classes, children, opts) do
    # Disable whitespace normalization for code blocks
    code_opts = Map.put(opts, :normalize_whitespace, false)
    language = detect_language(classes)
    ["\n```", language, "\n", process_children_to_iolist(children, code_opts), "\n```\n"]
  end

  defp detect_language(classes) do
    case Regex.run(~r/language-(\w+)/, classes) do
      [_, lang] -> lang
      _ -> ""
    end
  end

  defp process_definition_list_to_iolist(children, opts) when is_list(children) do
    # Group elements into definition groups (dt followed by its dd elements)
    {groups, last_group} =
      children
      |> Enum.reduce({[], nil}, fn
        {"dt", _, _} = dt, {groups, current_group} ->
          # Start a new group with this dt
          new_group = %{dt: dt, dds: []}

          if current_group do
            {groups ++ [current_group], new_group}
          else
            {groups, new_group}
          end

        {"dd", _, _} = dd, {groups, current_group} when not is_nil(current_group) ->
          # Add dd to current group
          updated_group = Map.update!(current_group, :dds, &(&1 ++ [dd]))
          {groups, updated_group}

        {"dd", _, _} = dd, {groups, nil} ->
          # dd without preceding dt - create a group with no dt
          {groups ++ [%{dt: nil, dds: [dd]}], nil}

        other, {groups, current_group} ->
          # Other elements get their own group
          groups_with_current = if current_group, do: groups ++ [current_group], else: groups
          {groups_with_current ++ [%{dt: nil, dds: [], other: other}], nil}
      end)

    # Add the last group if any
    all_groups =
      if last_group do
        groups ++ [last_group]
      else
        groups
      end

    # Process each group
    result =
      all_groups
      |> Enum.reduce([], fn group, acc ->
        group_iolist =
          case group do
            %{dt: nil, dds: [], other: other} ->
              # Just process the other element
              process_node_to_iolist(other, opts)

            %{dt: nil, dds: dds} ->
              # Just dd elements without dt
              Enum.map(dds, &process_node_to_iolist(&1, opts))
              |> Enum.intersperse("\n")

            %{dt: dt, dds: []} ->
              # Just dt without dd
              process_node_to_iolist(dt, opts)

            %{dt: dt, dds: dds} ->
              # dt with dd elements
              dt_iolist = process_node_to_iolist(dt, opts)
              dd_iolists = Enum.map(dds, &process_node_to_iolist(&1, opts))
              [dt_iolist, "\n", Enum.intersperse(dd_iolists, "\n")]
          end

        if acc == [] do
          [group_iolist]
        else
          [acc, "\n\n", group_iolist]
        end
      end)

    ["\n", result, "\n"]
  end

  defp process_ul_list_to_iolist(children, opts) when is_list(children) do
    items =
      children
      |> Enum.map(&process_list_item_to_iolist(&1, opts))
      |> Enum.intersperse("\n")

    ["\n", items, "\n"]
  end

  defp process_ol_list_to_iolist(children, opts) when is_list(children) do
    items =
      children
      |> Enum.with_index(1)
      |> Enum.map(fn {child, index} ->
        process_ordered_list_item_to_iolist(child, index, opts)
      end)
      |> Enum.intersperse("\n")

    ["\n", items, "\n"]
  end

  defp process_list_item_to_iolist({"li", _, children}, opts),
    do: ["- ", process_children_to_iolist(children, opts)]

  defp process_list_item_to_iolist(other, opts),
    do: process_node_to_iolist(other, opts)

  defp process_ordered_list_item_to_iolist({"li", _, children}, index, opts),
    do: [Integer.to_string(index), ". ", process_children_to_iolist(children, opts)]

  defp process_ordered_list_item_to_iolist(other, _index, opts),
    do: process_node_to_iolist(other, opts)

  defp process_children_to_iolist(children, opts) do
    iolist =
      children
      |> Enum.map(&process_node_to_iolist(&1, opts))
      |> Enum.intersperse(" ")

    # Only trim if we're normalizing whitespace
    if opts.normalize_whitespace do
      iolist |> IO.iodata_to_binary() |> String.trim()
    else
      iolist
    end
  end

  defp normalize_whitespace(text) do
    text
    |> String.split("\n", trim: false)
    |> Enum.map(fn line ->
      line
      |> String.replace(~r/[ \t]+/, " ")
      |> String.trim()
    end)
    |> Enum.join("\n")
  end

  # Process details/summary elements
  defp process_details_to_iolist(children, opts) do
    {summary, content} =
      Enum.split_with(children, fn
        {"summary", _, _} -> true
        _ -> false
      end)

    summary_iolist =
      case summary do
        [{"summary", _, summary_children} | _] ->
          ["**", process_children_to_iolist(summary_children, opts), "**"]

        _ ->
          ["**Details**"]
      end

    content_iolist = process_children_to_iolist(content, opts)

    ["\n", summary_iolist, "\n", content_iolist, "\n"]
  end

  # Compatibility wrapper functions
  @spec process_node(Floki.html_node(), Options.t()) :: String.t()
  def process_node(node, opts) do
    node
    |> process_node_to_iolist(opts)
    |> IO.iodata_to_binary()
  end

  @spec process_children(list(Floki.html_node()), Options.t()) :: String.t()
  def process_children(children, opts) do
    children
    |> process_children_to_iolist(opts)
    |> IO.iodata_to_binary()
  end
end
