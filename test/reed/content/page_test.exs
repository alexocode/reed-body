defmodule Reed.Content.PageTest do
  use ExUnit.Case

  alias Reed.Content.Page

  describe "from_file/1" do
    test "parses page with frontmatter and title" do
      content = """
      ---
      Status: published
      Slug: work-with-me
      ---
      # Work with me

      This is the content.
      """

      File.write!("/tmp/test_page.md", content)
      page = Page.from_file("/tmp/test_page.md")

      assert page.title == "Work with me"
      assert page.slug == "work-with-me"
      assert page.status == "published"
      assert page.body =~ "This is the content"
      assert page.body =~ "# Work with me"
      assert page.path == "/tmp/test_page.md"
    after
      File.rm("/tmp/test_page.md")
    end

    test "defaults to draft status if not specified" do
      content = """
      ---
      Slug: test-page
      ---
      # Test Page

      Content.
      """

      File.write!("/tmp/draft_page.md", content)
      page = Page.from_file("/tmp/draft_page.md")

      assert page.status == "draft"
    after
      File.rm("/tmp/draft_page.md")
    end

    test "returns nil if file doesn't exist" do
      assert Page.from_file("/nonexistent/file.md") == nil
    end

    test "returns nil if no title found" do
      content = """
      ---
      Slug: no-title
      ---
      Just content without a title.
      """

      File.write!("/tmp/no_title.md", content)
      assert Page.from_file("/tmp/no_title.md") == nil
    after
      File.rm("/tmp/no_title.md")
    end

    test "returns nil if no slug in frontmatter" do
      content = """
      ---
      Status: published
      ---
      # Test Page

      Content.
      """

      File.write!("/tmp/no_slug.md", content)
      assert Page.from_file("/tmp/no_slug.md") == nil
    after
      File.rm("/tmp/no_slug.md")
    end

    test "returns nil if no frontmatter" do
      content = "# Test Page\n\nSome content."

      File.write!("/tmp/no_frontmatter.md", content)
      assert Page.from_file("/tmp/no_frontmatter.md") == nil
    after
      File.rm("/tmp/no_frontmatter.md")
    end
  end

  describe "to_html/1" do
    test "converts markdown body to HTML" do
      page = %Page{
        title: "Test Page",
        slug: "test-page",
        body: "This is **bold** and *italic*.",
        path: "/tmp/test.md"
      }

      html = Page.to_html(page)

      assert html =~ "<p>"
      assert html =~ "<strong>bold</strong>"
      assert html =~ "<em>italic</em>"
    end

    test "preserves newlines as paragraphs" do
      page = %Page{
        title: "Test",
        slug: "test",
        body: "Paragraph one.\n\nParagraph two.",
        path: "/tmp/test.md"
      }

      html = Page.to_html(page)

      assert html =~ "Paragraph one"
      assert html =~ "Paragraph two"
    end
  end
end
