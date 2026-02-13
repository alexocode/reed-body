defmodule Reed.Content.SlugMapTest do
  use ExUnit.Case, async: true

  alias Reed.Content.SlugMap

  describe "lookup/1" do
    test "returns slug for known key" do
      assert SlugMap.lookup("AI") == "ai-did-not-take-your-agency-you-handed-it-over"
    end

    test "returns nil for unpublished key" do
      assert SlugMap.lookup("Authority") == nil
    end

    test "returns nil for unknown key" do
      assert SlugMap.lookup("Does Not Exist") == nil
    end
  end

  describe "all/0" do
    test "returns all mappings" do
      all = SlugMap.all()
      assert is_map(all)
      assert Map.has_key?(all, "AI")
      assert Map.has_key?(all, "Authority")
    end
  end

  describe "published/0" do
    test "returns only published mappings" do
      published = SlugMap.published()
      assert is_map(published)
      assert Map.has_key?(published, "AI")
      refute Map.has_key?(published, "Authority")
      assert Enum.all?(published, fn {_, v} -> not is_nil(v) end)
    end
  end

  describe "unpublished/0" do
    test "returns only unpublished mappings" do
      unpublished = SlugMap.unpublished()
      assert is_map(unpublished)
      refute Map.has_key?(unpublished, "AI")
      assert Map.has_key?(unpublished, "Authority")
      assert Enum.all?(unpublished, fn {_, v} -> is_nil(v) end)
    end
  end
end
