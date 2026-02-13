defmodule Reed.Content.Page do
  @moduledoc """
  Represents a Ghost page from a markdown file.

  Pages are static content (not blog posts).
  Requires frontmatter with Slug (and optional Status).
  """

  alias Reed.Content.Frontmatter

  defstruct [:title, :slug, :status, :body, :path]

  def from_file(path) do
    with {:ok, content} <- File.read(path),
         {frontmatter, body} <- Frontmatter.parse(content),
         slug when not is_nil(slug) <- frontmatter["Slug"],
         title when not is_nil(title) <- Frontmatter.extract_title(body) do
      %__MODULE__{
        title: title,
        slug: slug,
        status: frontmatter["Status"] || "draft",
        body: body,
        path: path
      }
    else
      _ -> nil
    end
  end

  def to_html(page) do
    {:ok, html, _warnings} = Earmark.as_html(page.body)
    html
  end
end
