defmodule Html2Markdown.OptionsTest do
  use ExUnit.Case
  alias Html2Markdown.Options

  describe "defaults/0" do
    test "returns default options map" do
      defaults = Options.defaults()
      
      assert is_map(defaults)
      assert defaults.navigation_classes == ["footer", "menu", "nav", "sidebar", "aside"]
      assert "script" in defaults.non_content_tags
      assert "style" in defaults.non_content_tags
      assert defaults.markdown_flavor == :basic
      assert defaults.normalize_whitespace == true
    end

    test "includes all expected non-content tags" do
      defaults = Options.defaults()
      
      expected_tags = ~w[aside audio base button datalist embed form iframe input 
                        keygen nav noscript object output script select source 
                        style svg template textarea track]
      
      Enum.each(expected_tags, fn tag ->
        assert tag in defaults.non_content_tags, "Expected #{tag} to be in non_content_tags"
      end)
    end
  end

  describe "merge/1" do
    test "merges user options with defaults" do
      user_options = %{
        navigation_classes: ["phoenix-nav", "liveview-sidebar"],
        normalize_whitespace: false
      }
      
      merged = Options.merge(user_options)
      
      # User options should override
      assert merged.navigation_classes == ["phoenix-nav", "liveview-sidebar"]
      assert merged.normalize_whitespace == false
      
      # Other options should remain default
      assert merged.markdown_flavor == :basic
      assert "script" in merged.non_content_tags
    end

    test "handles empty user options" do
      merged = Options.merge(%{})
      defaults = Options.defaults()
      
      assert merged == defaults
    end

    test "allows adding custom non-content tags" do
      user_options = %{
        non_content_tags: ["custom-ad", "newsletter-signup", "tracking-pixel"]
      }
      
      merged = Options.merge(user_options)
      
      # Should completely replace the default tags
      assert merged.non_content_tags == ["custom-ad", "newsletter-signup", "tracking-pixel"]
    end
  end
end