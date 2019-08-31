defmodule BankingWeb.V1.AuthenticationPlugTest do
  use BankingWeb.ConnCase

  import BankingWeb.Factory

  @user_fixture build(:user)

  setup do
    {:ok, user} = Auth.register(@user_fixture)

    {:ok, token} =
      Auth.sign_in(%{
        "email" => @user_fixture.email,
        "password" => @user_fixture.password
      })

    [user: user, token: token]
  end

  test "returns status 401 for requests without a token", %{conn: conn} do
    conn = BankingWeb.V1.AuthenticationPlug.call(conn, %{})
    assert conn.status == 401
  end

  test "puts the user_id on assigns", %{conn: conn, user: user, token: token} do
    conn =
      conn
      |> put_req_header("authorization", "Bearer #{token}")
      |> BankingWeb.V1.AuthenticationPlug.call(%{})

    assert conn.assigns.user_id == user.id
  end
end
