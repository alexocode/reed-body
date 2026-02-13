defmodule Mix.Tasks.SyncTest do
  use ExUnit.Case
  import ExUnit.CaptureIO

  setup do
    bypass = Bypass.open()
    Application.put_env(:body, :ghost_url, "http://localhost:#{bypass.port}")

    # Ensure app is started for tests
    Mix.Task.clear()

    {:ok, bypass: bypass}
  end

  describe "run/1" do
    test "syncs all pieces when no files specified", %{bypass: _bypass} do
      output =
        capture_io(fn ->
          Mix.Tasks.Sync.run(["--dry-run"])
        end)

      # Should complete without error
      assert is_binary(output)
    end

    test "syncs specific files when provided", %{bypass: bypass} do
      Bypass.expect(bypass, "GET", "/ghost/api/admin/posts/slug/ai-did-not-take-your-agency-you-handed-it-over/", fn conn ->
        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.resp(404, "")
      end)

      Bypass.expect(bypass, "POST", "/ghost/api/admin/posts/", fn conn ->
        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.resp(201, Jason.encode!(%{"posts" => [%{"id" => "new-id"}]}))
      end)

      output =
        capture_io(fn ->
          Mix.Tasks.Sync.run(["test/fixtures/Piece - AI.md"])
        end)

      assert output =~ "test/fixtures/Piece - AI.md"
      assert output =~ "CREATE: new draft"
    end

    test "respects dry-run flag", %{bypass: _bypass} do
      output =
        capture_io(fn ->
          Mix.Tasks.Sync.run(["--dry-run", "test/fixtures/Piece - AI.md"])
        end)

      assert output =~ "DRY RUN"
    end

    test "syncs multiple files", %{bypass: _bypass} do
      output =
        capture_io(fn ->
          Mix.Tasks.Sync.run([
            "--dry-run",
            "test/fixtures/Piece - AI.md",
            "test/fixtures/Piece - Test.md"
          ])
        end)

      assert output =~ "Piece - AI.md"
      assert output =~ "Piece - Test.md"
    end
  end
end
