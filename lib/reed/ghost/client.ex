defmodule Reed.Ghost.Client do
  @moduledoc """
  Ghost Admin API client.

  Thin wrapper around Req. No retries, no caching.
  If it fails, you see it. Fix it. Ship it.
  """

  alias Reed.Ghost.Auth

  defp base_url do
    Application.fetch_env!(:body, :ghost_url)
  end

  defp api(method, path, opts \\ []) do
    url = "#{base_url()}/ghost/api/admin#{path}"

    Req.request(
      [{:method, method}, {:url, url}, {:headers, Auth.headers()} | opts]
    )
  end

  def find_by_slug(slug) do
    case api(:get, "/posts/slug/#{slug}/") do
      {:ok, %{status: 200, body: %{"posts" => [post | _]}}} ->
        {:ok, post}

      {:ok, %{status: 404}} ->
        {:ok, nil}

      {:ok, %{status: status, body: body}} ->
        {:error, {status, body}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  def create_post(title, html, slug) do
    body = %{
      "posts" => [
        %{
          "title" => title,
          "html" => html,
          "slug" => slug,
          "status" => "draft"
        }
      ]
    }

    case api(:post, "/posts/", json: body) do
      {:ok, %{status: 201, body: resp}} -> {:ok, resp}
      {:ok, %{status: status, body: body}} -> {:error, {status, body}}
      {:error, reason} -> {:error, reason}
    end
  end

  def update_post(id, title, html, updated_at) do
    body = %{
      "posts" => [
        %{
          "title" => title,
          "html" => html,
          "updated_at" => updated_at
        }
      ]
    }

    case api(:put, "/posts/#{id}/", json: body) do
      {:ok, %{status: 200, body: resp}} -> {:ok, resp}
      {:ok, %{status: status, body: body}} -> {:error, {status, body}}
      {:error, reason} -> {:error, reason}
    end
  end
end
