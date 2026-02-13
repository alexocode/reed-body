defmodule Reed.Ghost.ClientTest do
  use ExUnit.Case

  alias Reed.Ghost.Client

  setup do
    bypass = Bypass.open()
    # Override the ghost_url for tests
    Application.put_env(:body, :ghost_url, "http://localhost:#{bypass.port}")

    {:ok, bypass: bypass}
  end

  describe "find_by_slug/1" do
    test "returns post when found", %{bypass: bypass} do
      post = %{
        "id" => "123",
        "slug" => "test-post",
        "title" => "Test Post",
        "updated_at" => "2024-01-01T00:00:00.000Z"
      }

      Bypass.expect_once(bypass, "GET", "/ghost/api/admin/posts/slug/test-post/", fn conn ->
        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.resp(200, Jason.encode!(%{"posts" => [post]}))
      end)

      assert {:ok, ^post} = Client.find_by_slug("test-post")
    end

    test "returns nil when not found", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/ghost/api/admin/posts/slug/nonexistent/", fn conn ->
        conn
        |> Plug.Conn.resp(404, "")
      end)

      assert {:ok, nil} = Client.find_by_slug("nonexistent")
    end

    test "returns error on non-200/404 status", %{bypass: bypass} do
      error_body = Jason.encode!(%{"errors" => ["Internal error"]})

      Bypass.expect(bypass, "GET", "/ghost/api/admin/posts/slug/error-post/", fn conn ->
        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.resp(500, error_body)
      end)

      assert {:error, {500, body}} = Client.find_by_slug("error-post")
      # Req may parse JSON or return raw string depending on content-type handling
      assert body == %{"errors" => ["Internal error"]} or body == error_body
    end

    test "returns error on connection failure", %{bypass: bypass} do
      Bypass.down(bypass)

      assert {:error, %Req.TransportError{reason: :econnrefused}} =
               Client.find_by_slug("test")
    end
  end

  describe "create_post/3" do
    test "creates a new draft post", %{bypass: bypass} do
      Bypass.expect_once(bypass, "POST", "/ghost/api/admin/posts/", fn conn ->
        {:ok, body, conn} = Plug.Conn.read_body(conn)
        payload = Jason.decode!(body)

        assert %{"posts" => [post_data]} = payload
        assert post_data["title"] == "New Post"
        assert post_data["html"] == "<p>Content</p>"
        assert post_data["slug"] == "new-post"
        assert post_data["status"] == "draft"

        response = %{"posts" => [Map.put(post_data, "id", "456")]}

        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.resp(201, Jason.encode!(response))
      end)

      assert {:ok, %{"posts" => [%{"id" => "456"}]}} =
               Client.create_post("New Post", "<p>Content</p>", "new-post")
    end

    test "returns error on failure", %{bypass: bypass} do
      Bypass.expect_once(bypass, "POST", "/ghost/api/admin/posts/", fn conn ->
        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.resp(422, Jason.encode!(%{"errors" => ["Validation failed"]}))
      end)

      assert {:error, {422, %{"errors" => ["Validation failed"]}}} =
               Client.create_post("Bad Post", "<p>Bad</p>", "bad-post")
    end

    test "returns error on connection failure", %{bypass: bypass} do
      Bypass.down(bypass)

      assert {:error, %Req.TransportError{}} = Client.create_post("Title", "<p>Content</p>", "slug")
    end
  end

  describe "update_post/4" do
    test "updates existing post", %{bypass: bypass} do
      updated_at = "2024-01-01T00:00:00.000Z"

      Bypass.expect_once(bypass, "PUT", "/ghost/api/admin/posts/789/", fn conn ->
        {:ok, body, conn} = Plug.Conn.read_body(conn)
        payload = Jason.decode!(body)

        assert %{"posts" => [post_data]} = payload
        assert post_data["title"] == "Updated Title"
        assert post_data["html"] == "<p>Updated content</p>"
        assert post_data["updated_at"] == updated_at

        response = %{"posts" => [Map.put(post_data, "id", "789")]}

        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.resp(200, Jason.encode!(response))
      end)

      assert {:ok, %{"posts" => [%{"id" => "789"}]}} =
               Client.update_post("789", "Updated Title", "<p>Updated content</p>", updated_at)
    end

    test "returns error on conflict", %{bypass: bypass} do
      Bypass.expect_once(bypass, "PUT", "/ghost/api/admin/posts/999/", fn conn ->
        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.resp(409, Jason.encode!(%{"errors" => ["Version mismatch"]}))
      end)

      assert {:error, {409, %{"errors" => ["Version mismatch"]}}} =
               Client.update_post("999", "Title", "<p>Content</p>", "2024-01-01T00:00:00.000Z")
    end

    test "returns error on connection failure", %{bypass: bypass} do
      Bypass.down(bypass)

      assert {:error, %Req.TransportError{}} =
               Client.update_post("123", "Title", "<p>Content</p>", "2024-01-01T00:00:00.000Z")
    end
  end

  describe "find_page_by_slug/1" do
    test "returns page when found", %{bypass: bypass} do
      page = %{
        "id" => "abc",
        "slug" => "work-with-me",
        "title" => "Work with me",
        "updated_at" => "2024-01-01T00:00:00.000Z"
      }

      Bypass.expect_once(bypass, "GET", "/ghost/api/admin/pages/slug/work-with-me/", fn conn ->
        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.resp(200, Jason.encode!(%{"pages" => [page]}))
      end)

      assert {:ok, ^page} = Client.find_page_by_slug("work-with-me")
    end

    test "returns nil when not found", %{bypass: bypass} do
      Bypass.expect_once(bypass, "GET", "/ghost/api/admin/pages/slug/nonexistent/", fn conn ->
        conn
        |> Plug.Conn.resp(404, "")
      end)

      assert {:ok, nil} = Client.find_page_by_slug("nonexistent")
    end

    test "returns error on non-200/404 status", %{bypass: bypass} do
      Bypass.expect(bypass, "GET", "/ghost/api/admin/pages/slug/error-page/", fn conn ->
        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.resp(500, Jason.encode!(%{"errors" => ["Internal error"]}))
      end)

      assert {:error, {500, _}} = Client.find_page_by_slug("error-page")
    end

    test "returns error on connection failure", %{bypass: bypass} do
      Bypass.down(bypass)

      assert {:error, %Req.TransportError{reason: :econnrefused}} =
               Client.find_page_by_slug("test")
    end
  end

  describe "create_page/3" do
    test "creates a new draft page", %{bypass: bypass} do
      Bypass.expect_once(bypass, "POST", "/ghost/api/admin/pages/", fn conn ->
        {:ok, body, conn} = Plug.Conn.read_body(conn)
        payload = Jason.decode!(body)

        assert %{"pages" => [page_data]} = payload
        assert page_data["title"] == "New Page"
        assert page_data["html"] == "<p>Content</p>"
        assert page_data["slug"] == "new-page"
        assert page_data["status"] == "draft"

        response = %{"pages" => [Map.put(page_data, "id", "xyz")]}

        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.resp(201, Jason.encode!(response))
      end)

      assert {:ok, %{"pages" => [%{"id" => "xyz"}]}} =
               Client.create_page("New Page", "<p>Content</p>", "new-page")
    end

    test "returns error on failure", %{bypass: bypass} do
      Bypass.expect_once(bypass, "POST", "/ghost/api/admin/pages/", fn conn ->
        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.resp(422, Jason.encode!(%{"errors" => ["Validation failed"]}))
      end)

      assert {:error, {422, %{"errors" => ["Validation failed"]}}} =
               Client.create_page("Bad Page", "<p>Bad</p>", "bad-page")
    end

    test "returns error on connection failure", %{bypass: bypass} do
      Bypass.down(bypass)

      assert {:error, %Req.TransportError{}} =
               Client.create_page("Title", "<p>Content</p>", "slug")
    end
  end

  describe "update_page/4" do
    test "updates existing page", %{bypass: bypass} do
      updated_at = "2024-01-01T00:00:00.000Z"

      Bypass.expect_once(bypass, "PUT", "/ghost/api/admin/pages/def/", fn conn ->
        {:ok, body, conn} = Plug.Conn.read_body(conn)
        payload = Jason.decode!(body)

        assert %{"pages" => [page_data]} = payload
        assert page_data["title"] == "Updated Page"
        assert page_data["html"] == "<p>Updated content</p>"
        assert page_data["updated_at"] == updated_at

        response = %{"pages" => [Map.put(page_data, "id", "def")]}

        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.resp(200, Jason.encode!(response))
      end)

      assert {:ok, %{"pages" => [%{"id" => "def"}]}} =
               Client.update_page("def", "Updated Page", "<p>Updated content</p>", updated_at)
    end

    test "returns error on conflict", %{bypass: bypass} do
      Bypass.expect_once(bypass, "PUT", "/ghost/api/admin/pages/ghi/", fn conn ->
        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.resp(409, Jason.encode!(%{"errors" => ["Version mismatch"]}))
      end)

      assert {:error, {409, %{"errors" => ["Version mismatch"]}}} =
               Client.update_page("ghi", "Title", "<p>Content</p>", "2024-01-01T00:00:00.000Z")
    end

    test "returns error on connection failure", %{bypass: bypass} do
      Bypass.down(bypass)

      assert {:error, %Req.TransportError{}} =
               Client.update_page("123", "Title", "<p>Content</p>", "2024-01-01T00:00:00.000Z")
    end
  end
end
