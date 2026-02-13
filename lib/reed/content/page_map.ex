defmodule Reed.Content.PageMap do
  @moduledoc """
  Maps local page titles to Ghost slugs.

  Pages are static content (not blog posts).
  """

  @map %{
    "In a Nutshell" => "in-a-nutshell",
    "Work with me" => "work-with-me",
    "For Leadership" => "for-leadership",
    "For HR" => "for-hr",
    "For Tech" => "for-tech"
  }

  def to_slug(title) when is_binary(title) do
    Map.get(@map, title)
  end

  def to_slug(_), do: nil

  def all_pages do
    Map.keys(@map)
  end
end
