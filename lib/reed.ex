defmodule Reed do
  @moduledoc """
  Sync markdown pieces from repo to Ghost.

  First brick of the BEAM MCP server.
  Repo is source of truth. Ghost gets drafts. Alex publishes.
  """

  alias Reed.Content.Piece
  alias Reed.Ghost.Client

  def sync(paths, opts \\ []) do
    dry_run = Keyword.get(opts, :dry_run, false)

    paths
    |> Enum.map(&Piece.from_file/1)
    |> Enum.reject(&is_nil/1)
    |> Enum.each(fn piece ->
      case piece.slug do
        nil ->
          IO.puts("  SKIP (no slug): #{piece.path}")

        slug ->
          IO.puts("  #{piece.path} -> /#{slug}/")

          unless dry_run do
            sync_piece(piece)
          else
            IO.puts("    DRY RUN: would sync '#{piece.title}'")
          end
      end
    end)
  end

  def sync_all(opts \\ []) do
    "Pieces/*.md"
    |> Path.wildcard()
    |> sync(opts)
  end

  defp sync_piece(piece) do
    html = Piece.to_html(piece)

    case Client.find_by_slug(piece.slug) do
      {:ok, %{"id" => id, "updated_at" => updated_at, "title" => title}} ->
        IO.puts("    UPDATE: #{id} ('#{title}')")
        Client.update_post(id, piece.title, html, updated_at)

      {:ok, nil} ->
        IO.puts("    CREATE: new draft")
        Client.create_post(piece.title, html, piece.slug)

      {:error, reason} ->
        IO.puts("    ERROR: #{inspect(reason)}")
    end
  end
end
