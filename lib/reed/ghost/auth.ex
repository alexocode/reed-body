defmodule Reed.Ghost.Auth do
  @moduledoc """
  JWT authentication for Ghost Admin API.

  Ghost uses short-lived JWTs signed with the secret half
  of an Admin API key. Format: "key_id:secret_hex".
  """

  def token do
    [key_id, secret_hex] =
      Application.fetch_env!(:body, :ghost_admin_key)
      |> String.split(":")

    secret = Base.decode16!(secret_hex, case: :mixed)
    now = System.system_time(:second)

    payload = %{
      "iat" => now,
      "exp" => now + 300,
      "aud" => "/admin/"
    }

    jwk = JOSE.JWK.from_oct(secret)
    jws = %{"alg" => "HS256", "kid" => key_id, "typ" => "JWT"}

    {_, token} =
      JOSE.JWT.sign(jwk, jws, payload)
      |> JOSE.JWS.compact()

    token
  end

  def headers do
    [
      {"authorization", "Ghost #{token()}"},
      {"content-type", "application/json"}
    ]
  end
end
