defmodule IssueReproductionTest do
  @moduledoc """
  Test to reproduce the breaking change behavior between version 0.1.6 and 0.2.1.
  
  This test should pass with the corrected implementation.
  """
  
  use ExUnit.Case
  
  describe "paragraph conversion regression fix" do
    test "convert consecutive paragraphs matches 0.1.6 behavior" do
      input = "<p>First paragraph.</p><p>Second paragraph.</p>"
      
      # Expected behavior from version 0.1.6 (now restored)
      expected = "First paragraph.\n \nSecond paragraph."
      
      result = Html2Markdown.convert(input)
      
      assert result == expected, """
      Expected 0.1.6 behavior: #{inspect(expected)}
      Actual result:           #{inspect(result)}
      """
    end
    
    test "single paragraph should not have excessive newlines" do
      input = "<p>Single paragraph.</p>"
      
      # Should not have leading/trailing newlines for single paragraph
      result = Html2Markdown.convert(input)
      expected = "Single paragraph."
      
      assert result == expected, "Result should be clean: #{inspect(result)}"
    end
    
    test "three paragraphs should use consistent spacing" do
      input = "<p>First.</p><p>Second.</p><p>Third.</p>"
      
      result = Html2Markdown.convert(input)
      
      # Should use consistent spacing between all paragraphs
      # Based on 0.1.6 behavior, should be "\n \n" between paragraphs
      expected = "First.\n \nSecond.\n \nThird."
      
      assert result == expected, """
      Expected: #{inspect(expected)}
      Actual:   #{inspect(result)}
      """
    end
    
    test "mixed elements maintain proper spacing" do
      input = "<p>A paragraph.</p><h1>A header</h1>"
      
      result = Html2Markdown.convert(input)
      
      # Different element types should use \n\n separator
      expected = "A paragraph.\n\n# A header\n"
      
      assert result == expected, """
      Expected: #{inspect(expected)}
      Actual:   #{inspect(result)}
      """
    end
    
    test "paragraph with formatting maintains structure" do
      input = "<p>The <strong>bold</strong> flavors and <em>italic</em> text.</p>"
      
      result = Html2Markdown.convert(input)
      expected = "The **bold** flavors and *italic* text."
      
      assert result == expected, """
      Expected: #{inspect(expected)}
      Actual:   #{inspect(result)}
      """
    end
  end
end