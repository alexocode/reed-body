defmodule Reed.Content.Piece do
  @moduledoc """
  A systemic.engineering piece.

  Parses markdown files, extracts title, maps to Ghost slug.
  The struct IS the piece — path, title, body, slug.
  """

  defstruct [:path, :title, :body, :key, :slug]

  alias Reed.Content.SlugMap

  def from_file(path) do
    case parse_filename(path) do
      nil ->
        nil

      key ->
        content = File.read!(path)
        title = extract_title(content) || key

        %__MODULE__{
          path: path,
          title: title,
          body: content,
          key: key,
          slug: SlugMap.lookup(key)
        }
    end
  end

  def to_html(%__MODULE__{body: body}) do
    {:ok, html, _warnings} = Earmark.as_html(body)
    html
  end

  defp parse_filename(path) do
    path
    |> Path.basename(".md")
    |> case do
      "Piece - " <> rest -> String.trim(rest)
      _ -> nil
    end
  end

  defp extract_title(content) do
    content
    |> String.split("\n")
    |> Enum.find_value(fn
      "# " <> title -> String.trim(title)
      _ -> nil
    end)
  end
end
