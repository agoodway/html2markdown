defmodule Html2Markdown.Parser do
  @moduledoc """
  Handles HTML preprocessing and parsing operations.
  """

  alias Html2Markdown.Options

  @type html_tree :: list(Floki.html_node())

  @doc """
  Preprocesses HTML content by parsing it and filtering out non-content elements.
  """
  @spec preprocess_content(String.t(), Options.t()) :: html_tree()
  def preprocess_content(content, opts) do
    # Convert lists to MapSets for O(1) lookup performance
    non_content_tags_set = MapSet.new(opts.non_content_tags)
    navigation_classes_set = MapSet.new(opts.navigation_classes)

    content
    |> prep_document()
    |> Floki.parse_document!()
    |> extract_and_filter_body(non_content_tags_set, navigation_classes_set)
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

  # Optimized: Single traversal for all filtering operations
  defp extract_and_filter_body(document, non_content_tags_set, navigation_classes_set) do
    # Find body tag and extract its children
    body_nodes = Floki.find(document, "body")

    nodes_to_filter =
      case body_nodes do
        [{"body", _, children}] -> children
        [] -> document
        other -> other
      end

    # Filter all nodes in a single pass
    filter_nodes(nodes_to_filter, non_content_tags_set, navigation_classes_set)
  end

  defp filter_children(children, non_content_tags_set, navigation_classes_set) do
    children
    |> Enum.map(&filter_node(&1, non_content_tags_set, navigation_classes_set))
    |> Enum.reject(&is_nil/1)
  end

  defp filter_nodes(nodes, non_content_tags_set, navigation_classes_set) when is_list(nodes) do
    nodes
    |> Enum.map(&filter_node(&1, non_content_tags_set, navigation_classes_set))
    |> Enum.reject(&is_nil/1)
  end

  defp filter_node({:comment, _}, _, _), do: nil

  defp filter_node({tag, attrs, children}, non_content_tags_set, navigation_classes_set)
       when is_binary(tag) do
    cond do
      # Check if it's a non-content tag
      MapSet.member?(non_content_tags_set, tag) ->
        nil

      # Check for navigation classes (except body)
      tag != "body" && has_nav_class?(attrs, navigation_classes_set) ->
        nil

      # Otherwise, filter children recursively
      true ->
        filtered_children =
          filter_children(children, non_content_tags_set, navigation_classes_set)

        {tag, attrs, filtered_children}
    end
  end

  defp filter_node(node, _, _), do: node

  # Optimized: Check if any navigation class is contained in the class string
  defp has_nav_class?(attrs, navigation_classes_set) do
    case List.keyfind(attrs, "class", 0) do
      {"class", class_string} ->
        # Check if any navigation class is a substring of the class string
        Enum.any?(navigation_classes_set, fn nav_class ->
          String.contains?(class_string, nav_class)
        end)

      _ ->
        false
    end
  end
end
