defmodule Reed.Content.FrontmatterTest do
  use ExUnit.Case

  alias Reed.Content.Frontmatter

  describe "parse/1" do
    test "parses valid frontmatter" do
      content = """
      ---
      Slug: test-page
      Status: published
      ---
      # Title

      Body content.
      """

      assert {frontmatter, body} = Frontmatter.parse(content)
      assert frontmatter["Slug"] == "test-page"
      assert frontmatter["Status"] == "published"
      assert body =~ "# Title"
      assert body =~ "Body content"
    end

    test "returns nil for invalid YAML" do
      content = """
      ---
      invalid: yaml: here:
      ---
      Body
      """

      assert Frontmatter.parse(content) == nil
    end

    test "returns nil when no frontmatter" do
      content = "Just regular markdown content."

      assert Frontmatter.parse(content) == nil
    end
  end

  describe "extract_title/1" do
    test "extracts title from markdown heading" do
      content = """
      # Main Title

      Some content here.
      """

      assert Frontmatter.extract_title(content) == "Main Title"
    end

    test "returns nil when no title found" do
      content = "No title here, just content."

      assert Frontmatter.extract_title(content) == nil
    end

    test "returns first heading if multiple exist" do
      content = """
      # First Title

      ## Second Heading

      # Another Title
      """

      assert Frontmatter.extract_title(content) == "First Title"
    end
  end
end
