defmodule Html2Markdown.Parser do
  @moduledoc """
  Handles HTML preprocessing and parsing operations.
  """

  @doc """
  Preprocesses HTML content by parsing it and filtering out non-content elements.
  """
  def preprocess_content(content, opts) do
    body_content = content
    |> prep_document()
    |> Floki.parse_document!()
    |> Floki.find("body")
    |> Floki.filter_out(:comment)
    
    # Extract children from body tag
    children = case body_content do
      [{"body", _, children}] -> children
      [] -> []
      other -> other
    end
    
    children
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
end
