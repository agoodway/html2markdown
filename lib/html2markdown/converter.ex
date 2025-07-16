defmodule Html2Markdown.Converter do
  @moduledoc """
  Handles the conversion of HTML nodes to Markdown format.
  """

  alias Html2Markdown.TableConverter

  def convert_to_markdown(document, opts) do
    document
    |> Enum.map(&process_node(&1, opts))
    |> Enum.reject(&(&1 == ""))
    |> Enum.join("\n\n")
  end

  def process_node({"h1", _, children}, opts),
    do: "\n" <> "# #{process_children(children, opts)}" <> "\n"

  def process_node({"h2", _, children}, opts),
    do: "\n" <> "## #{process_children(children, opts)}" <> "\n"

  def process_node({"h3", _, children}, opts),
    do: "\n" <> "### #{process_children(children, opts)}" <> "\n"

  def process_node({"h4", _, children}, opts),
    do: "\n" <> "#### #{process_children(children, opts)}" <> "\n"

  def process_node({"h5", _, children}, opts),
    do: "\n" <> "##### #{process_children(children, opts)}" <> "\n"

  def process_node({"h6", _, children}, opts),
    do: "\n" <> "###### #{process_children(children, opts)}" <> "\n"

  def process_node({"p", _, children}, opts),
    do: "\n" <> "#{process_children(children, opts)}" <> "\n"

  def process_node({"ul", _, children}, opts), do: process_ul_list(children, opts)
  def process_node({"ol", _, children}, opts), do: process_ol_list(children, opts)
  def process_node({"li", _, children}, opts), do: "- " <> process_children(children, opts) <> "\n"

  def process_node({"pre", _, [{"code", [{"class", classes}], children}]}, opts),
    do: process_code_block(classes, children, opts)

  def process_node({"pre", _, [{"code", _, children}]}, opts),
    do: process_code_block(children, opts)

  def process_node({"pre", _, children}, opts), do: process_code_block(children, opts)

  def process_node({"blockquote", _, children}, opts),
    do: "\n" <> "> #{process_children(children, opts)}" <> "\n"

  def process_node({"dl", _, children}, opts), do: process_definition_list(children, opts)
  def process_node({"dt", _, children}, opts), do: "**#{process_children(children, opts)}**"
  def process_node({"dd", _, children}, opts), do: ": #{process_children(children, opts)}"

  def process_node({"table", _, children}, opts), do: TableConverter.process_table(children, opts)
  def process_node({"strong", _, children}, opts), do: "**#{process_children(children, opts)}**"
  def process_node({"b", _, children}, opts), do: "**#{process_children(children, opts)}**"
  def process_node({"em", _, children}, opts), do: "*#{process_children(children, opts)}*"
  def process_node({"i", _, children}, opts), do: "*#{process_children(children, opts)}*"
  def process_node({"u", _, children}, opts), do: "<u>#{process_children(children, opts)}</u>"
  def process_node({"del", _, children}, opts), do: "~~#{process_children(children, opts)}~~"
  def process_node({"sup", _, children}, opts), do: "<sup>#{process_children(children, opts)}</sup>"
  def process_node({"sub", _, children}, opts), do: "<sub>#{process_children(children, opts)}</sub>"
  def process_node({"code", _, children}, opts) do
    # Disable whitespace normalization for inline code
    code_opts = Map.put(opts, :normalize_whitespace, false)
    "`#{process_children(children, code_opts)}`"
  end
  def process_node({"a", attrs, children}, opts), do: process_href(attrs, children, opts)
  def process_node({"img", [{"src", src}, {"alt", alt}], _}, _opts), do: "![#{alt}](#{src})"

  def process_node({"caption", _, children}, opts),
    do: "| " <> process_children(children, opts) <> " |" <> "\n"

  def process_node({"figcaption", _, children}, opts), do: "**#{process_children(children, opts)}**"
  def process_node({"br", _, _}, _opts), do: "\n\n"
  def process_node({"hr", _, _}, _opts), do: "\n" <> "\n" <> "---" <> "\n\n"

  def process_node({"section", _, children}, opts),
    do: "\n#{process_children(children, opts)}\n"

  def process_node({"article", _, children}, opts),
    do: "\n#{process_children(children, opts)}\n"

  def process_node({"picture", _, children}, _opts) do
    with {"img", attrs, _} <- Enum.find(children, fn {tag, _, _} -> tag == "img" end),
         %{"alt" => alt, "src" => src} <- Enum.into(attrs, %{}) do
      "![#{alt}](#{src})"
    end
  end

  def process_node({"div", _, children}, opts), do: "#{process_children(children, opts)}" <> "\n"
  def process_node({_, _, children}, opts), do: process_children(children, opts)
  def process_node(text, opts) when is_binary(text) do
    if opts.normalize_whitespace do
      text
      |> String.trim()
      |> normalize_whitespace()
    else
      text
    end
  end

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
    # Disable whitespace normalization for code blocks
    code_opts = Map.put(opts, :normalize_whitespace, false)
    content = process_children(children, code_opts)
    "\n```\n#{content}\n```\n"
  end

  defp process_code_block(classes, children, opts) do
    # Disable whitespace normalization for code blocks
    code_opts = Map.put(opts, :normalize_whitespace, false)
    language = detect_language(classes)
    "\n```#{language}\n#{process_children(children, code_opts)}\n```\n"
  end

  defp detect_language(classes) do
    case Regex.run(~r/language-(\w+)/, classes) do
      [_, lang] -> lang
      _ -> ""
    end
  end

  defp process_definition_list(children, opts) when is_list(children) do
    # Group elements into definition groups (dt followed by its dd elements)
    {groups, last_group} = children
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
    all_groups = if last_group do
      groups ++ [last_group]
    else
      groups
    end

    # Process each group
    result = all_groups
    |> Enum.map_join("\n\n", fn
      %{dt: nil, dds: [], other: other} ->
        # Just process the other element
        process_node(other, opts)

      %{dt: nil, dds: dds} ->
        # Just dd elements without dt
        Enum.map_join(dds, "\n", &process_node(&1, opts))

      %{dt: dt, dds: []} ->
        # Just dt without dd
        process_node(dt, opts)

      %{dt: dt, dds: dds} ->
        # dt with dd elements
        dt_text = process_node(dt, opts)
        dd_texts = Enum.map_join(dds, "\n", &process_node(&1, opts))
        dt_text <> "\n" <> dd_texts
    end)

    "\n" <> result <> "\n"
  end

  defp process_ul_list(children, opts) when is_list(children) do
    "\n" <> Enum.map_join(children, "\n", &process_list_item(&1, opts)) <> "\n"
  end

  defp process_ol_list(children, opts) when is_list(children) do
    ol_list =
      children
      |> Enum.with_index()
      |> Enum.map_join("\n", fn {child, index} ->
        process_ordered_list_item(child, index + 1, opts)
      end)

    "\n" <> ol_list <> "\n"
  end

  defp process_list_item({"li", _, children}, opts), do: "- " <> process_children(children, opts)
  defp process_list_item(other, opts), do: process_node(other, opts)

  defp process_ordered_list_item({"li", _, children}, index, opts),
    do: "#{index}. " <> process_children(children, opts)

  defp process_ordered_list_item(other, _index, opts), do: process_node(other, opts)

  def process_children(children, opts) do
    result =
      children
      |> Enum.map(&process_node(&1, opts))
      |> Enum.join(" ")

    # Only trim if we're normalizing whitespace
    if opts.normalize_whitespace do
      String.trim(result)
    else
      result
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
end
