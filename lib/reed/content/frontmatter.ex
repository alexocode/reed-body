defmodule Reed.Content.Frontmatter do
  @moduledoc """
  Parses YAML frontmatter from markdown files.

  Shared by both Pages and Pieces.
  """

  def parse(content) do
    case String.split(content, ~r/^---\s*$/m, parts: 3) do
      ["", yaml, body] ->
        case YamlElixir.read_from_string(yaml) do
          {:ok, frontmatter} -> {frontmatter, String.trim(body)}
          _ -> nil
        end

      _ ->
        nil
    end
  end

  def extract_title(content) do
    content
    |> String.split("\n")
    |> Enum.find_value(fn
      "# " <> title -> String.trim(title)
      _ -> nil
    end)
  end
end
