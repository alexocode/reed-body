defmodule Mix.Tasks.LexicalAnalyze do
  @moduledoc """
  Analyze Lexical transformation from published Ghost posts.

  Fetches published pieces, compares Lexical structure to source Markdown,
  and reverse-engineers the transformation.

  Usage:
      mix lexical_analyze                    # All published pieces
      mix lexical_analyze ai                 # Specific piece by partial slug
  """

  use Mix.Task

  alias Reed.Content.SlugMap
  alias Reed.Ghost.Client

  @shortdoc "Analyze Markdown → Lexical transformation"

  @impl Mix.Task
  def run(args) do
    Mix.Task.run("app.start")

    case args do
      [] -> analyze_all()
      [partial_slug] -> analyze_one(partial_slug)
    end
  end

  defp analyze_all do
    IO.puts("Analyzing all published pieces...\n")

    SlugMap.published()
    |> Enum.each(fn {key, slug} ->
      IO.puts("=== #{key} (#{slug}) ===")
      analyze_piece(slug)
      IO.puts("")
    end)
  end

  defp analyze_one(partial) do
    SlugMap.published()
    |> Enum.find(fn {_key, slug} -> String.contains?(slug, partial) end)
    |> case do
      {key, slug} ->
        IO.puts("=== #{key} (#{slug}) ===\n")
        analyze_piece(slug)

      nil ->
        IO.puts("No published piece found matching: #{partial}")
    end
  end

  defp analyze_piece(slug) do
    case Client.find_by_slug(slug) do
      {:ok, nil} ->
        IO.puts("  ⚠️  Not found on Ghost")

      {:ok, post} ->
        lexical = post["lexical"] |> Jason.decode!()
        analyze_lexical_structure(lexical)

      {:error, reason} ->
        IO.puts("  ❌ Error: #{inspect(reason)}")
    end
  end

  defp analyze_lexical_structure(lexical) do
    root = lexical["root"]
    children = root["children"]

    IO.puts("Root children: #{length(children)}")

    # Analyze node types
    node_types =
      children
      |> Enum.map(& &1["type"])
      |> Enum.frequencies()

    IO.puts("\nNode type distribution:")

    Enum.each(node_types, fn {type, count} ->
      IO.puts("  #{type}: #{count}")
    end)

    # Sample first few nodes
    IO.puts("\nFirst 3 nodes:")

    children
    |> Enum.take(3)
    |> Enum.with_index(1)
    |> Enum.each(fn {node, idx} ->
      IO.puts("\n  [#{idx}] #{node["type"]}")
      sample_node(node)
    end)
  end

  defp sample_node(%{"type" => "paragraph", "children" => children}) do
    text_nodes = Enum.filter(children, &(&1["type"] == "extended-text"))

    text_preview =
      text_nodes
      |> Enum.map(& &1["text"])
      |> Enum.join(" ")
      |> String.slice(0, 60)

    IO.puts("      Text: #{text_preview}...")
    IO.puts("      Children: #{length(children)} (#{Enum.count(text_nodes)} text, #{length(children) - Enum.count(text_nodes)} other)")
  end

  defp sample_node(%{"type" => "heading", "children" => children, "tag" => tag}) do
    text =
      children
      |> Enum.filter(&(&1["type"] == "extended-text"))
      |> Enum.map(& &1["text"])
      |> Enum.join(" ")

    IO.puts("      Tag: #{tag}")
    IO.puts("      Text: #{text}")
  end

  defp sample_node(%{"type" => _type} = node) do
    IO.puts("      Keys: #{node |> Map.keys() |> Enum.join(", ")}")
  end
end
