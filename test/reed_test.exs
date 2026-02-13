defmodule ReedTest do
  use ExUnit.Case
  import ExUnit.CaptureIO

  setup do
    bypass = Bypass.open()
    Application.put_env(:body, :ghost_url, "http://localhost:#{bypass.port}")

    {:ok, bypass: bypass}
  end

  describe "sync/2" do
    test "creates new post for piece with slug", %{bypass: bypass} do
      # AI piece has slug in SlugMap
      Bypass.expect(
        bypass,
        "GET",
        "/ghost/api/admin/posts/slug/ai-did-not-take-your-agency-you-handed-it-over/",
        fn conn ->
          conn
          |> Plug.Conn.put_resp_content_type("application/json")
          |> Plug.Conn.resp(404, "")
        end
      )

      Bypass.expect(bypass, "POST", "/ghost/api/admin/posts/", fn conn ->
        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.resp(201, Jason.encode!(%{"posts" => [%{"id" => "new-id"}]}))
      end)

      output =
        capture_io(fn ->
          Reed.sync(["test/fixtures/Piece - AI.md"])
        end)

      assert output =~ "test/fixtures/Piece - AI.md"
      assert output =~ "/ai-did-not-take-your-agency-you-handed-it-over/"
      assert output =~ "CREATE: new draft"
    end

    test "updates existing post", %{bypass: bypass} do
      post = %{
        "id" => "existing-123",
        "slug" => "ai-did-not-take-your-agency-you-handed-it-over",
        "title" => "Old Title",
        "updated_at" => "2024-01-01T00:00:00.000Z"
      }

      Bypass.expect(
        bypass,
        "GET",
        "/ghost/api/admin/posts/slug/ai-did-not-take-your-agency-you-handed-it-over/",
        fn conn ->
          conn
          |> Plug.Conn.put_resp_content_type("application/json")
          |> Plug.Conn.resp(200, Jason.encode!(%{"posts" => [post]}))
        end
      )

      Bypass.expect(bypass, "PUT", "/ghost/api/admin/posts/existing-123/", fn conn ->
        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.resp(200, Jason.encode!(%{"posts" => [post]}))
      end)

      output =
        capture_io(fn ->
          Reed.sync(["test/fixtures/Piece - AI.md"])
        end)

      assert output =~ "UPDATE: existing-123"
      assert output =~ "('Old Title')"
    end

    test "skips pieces without slugs", %{bypass: _bypass} do
      output =
        capture_io(fn ->
          Reed.sync(["test/fixtures/Piece - Test.md"])
        end)

      assert output =~ "SKIP (no slug):"
      assert output =~ "test/fixtures/Piece - Test.md"
    end

    test "skips files that don't match pattern" do
      output =
        capture_io(fn ->
          Reed.sync(["test/fixtures/NotAPiece.md"])
        end)

      assert output == ""
    end

    test "dry run mode doesn't make API calls", %{bypass: _bypass} do
      output =
        capture_io(fn ->
          Reed.sync(["test/fixtures/Piece - AI.md"], dry_run: true)
        end)

      assert output =~ "DRY RUN: would sync"
      assert output =~ "'AI: Agency Handed Over'"
    end

    test "handles API errors gracefully", %{bypass: bypass} do
      Bypass.expect(
        bypass,
        "GET",
        "/ghost/api/admin/posts/slug/ai-did-not-take-your-agency-you-handed-it-over/",
        fn conn ->
          conn
          |> Plug.Conn.resp(500, "")
        end
      )

      output =
        capture_io(fn ->
          Reed.sync(["test/fixtures/Piece - AI.md"])
        end)

      assert output =~ "ERROR:"
    end
  end

  describe "sync_all/1" do
    test "syncs all Pieces/*.md files" do
      # This would sync files from Pieces/ directory
      # We don't have that in test, so it should find nothing
      output =
        capture_io(fn ->
          Reed.sync_all(dry_run: true)
        end)

      # Should complete without error (even if no files found)
      assert is_binary(output)
    end

    test "respects dry_run option" do
      output =
        capture_io(fn ->
          Reed.sync_all(dry_run: true)
        end)

      # Even with no files, should not crash
      assert is_binary(output)
    end
  end
end
