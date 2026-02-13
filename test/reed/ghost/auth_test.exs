defmodule Reed.Ghost.AuthTest do
  use ExUnit.Case, async: true

  alias Reed.Ghost.Auth

  describe "token/0" do
    test "generates valid JWT token" do
      token = Auth.token()

      assert is_binary(token)
      # JWT has 3 parts separated by dots
      assert String.split(token, ".") |> length() == 3
    end

    test "token contains expected structure" do
      token = Auth.token()

      # Decode the header to verify structure
      [header_b64, _payload_b64, _signature_b64] = String.split(token, ".")

      # Add padding if needed for base64
      header_json =
        header_b64
        |> String.replace("-", "+")
        |> String.replace("_", "/")
        |> Base.decode64!(padding: false)

      header = Jason.decode!(header_json)

      assert header["alg"] == "HS256"
      assert header["kid"] == "test_key_id"
      assert header["typ"] == "JWT"
    end

    test "token payload has required claims" do
      token = Auth.token()

      # Decode payload
      [_header_b64, payload_b64, _signature_b64] = String.split(token, ".")

      payload_json =
        payload_b64
        |> String.replace("-", "+")
        |> String.replace("_", "/")
        |> Base.decode64!(padding: false)

      payload = Jason.decode!(payload_json)

      assert is_integer(payload["iat"])
      assert is_integer(payload["exp"])
      assert payload["aud"] == "/admin/"
      # Expiry should be ~5 minutes from now
      assert payload["exp"] - payload["iat"] == 300
    end
  end

  describe "headers/0" do
    test "returns authorization header with Ghost token" do
      headers = Auth.headers()

      assert is_list(headers)
      assert {"content-type", "application/json"} in headers

      auth_header = Enum.find(headers, fn {k, _v} -> k == "authorization" end)
      assert {"authorization", "Ghost " <> _token} = auth_header
    end
  end
end
