defmodule BankingWeb.V1.AuthControllerTest do
  use BankingWeb.ConnCase

  import BankingWeb.Factory

  @auth_token_url Routes.api_v1_auth_path(BankingWeb.Endpoint, :authenticate)

  describe "authenticate/2" do
    test "returns a token for correct credentials", %{conn: conn} do
      user_attrs = build(:user)
      {:ok, _user} = Auth.register(user_attrs)

      credentials = %{"email" => user_attrs.email, "password" => user_attrs.password}
      conn = post(conn, @auth_token_url, credentials)

      assert json_response(conn, 200)
      refute json_response(conn, 200)["token"] == nil, message: "no token was returned"
    end

    test "returns 401 for invalid credentials", %{conn: conn} do
      user_attrs = build(:user)
      {:ok, _user} = Auth.register(user_attrs)

      invalid_credentials = %{"email" => user_attrs.email, "password" => "wrongpassword"}
      conn = post(conn, @auth_token_url, invalid_credentials)

      assert json_response(conn, 401)
    end

    test "returns 400 for malformed credentials", %{conn: conn} do
      malformed_credentials = %{"password" => "1234"}
      conn = post(conn, @auth_token_url, malformed_credentials)

      assert json_response(conn, 400)

      response = json_response(conn, 400)
      assert Map.has_key?(response["errors"], "email")
    end
  end
end
