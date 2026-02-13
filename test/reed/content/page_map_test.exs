defmodule Reed.Content.PageMapTest do
  use ExUnit.Case

  alias Reed.Content.PageMap

  describe "to_slug/1" do
    test "returns slug for known page" do
      assert PageMap.to_slug("Work with me") == "work-with-me"
      assert PageMap.to_slug("In a Nutshell") == "in-a-nutshell"
      assert PageMap.to_slug("For Leadership") == "for-leadership"
    end

    test "returns nil for unknown page" do
      assert PageMap.to_slug("Unknown Page") == nil
    end

    test "returns nil for non-string input" do
      assert PageMap.to_slug(123) == nil
      assert PageMap.to_slug(nil) == nil
      assert PageMap.to_slug(:atom) == nil
    end
  end

  describe "all_pages/0" do
    test "returns list of all known pages" do
      pages = PageMap.all_pages()

      assert is_list(pages)
      assert "Work with me" in pages
      assert "In a Nutshell" in pages
      assert "For Leadership" in pages
      assert "For HR" in pages
      assert "For Tech" in pages
    end
  end
end
