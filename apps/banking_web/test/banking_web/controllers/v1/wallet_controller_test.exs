defmodule BankingWeb.V1.WalletControllerTest do
  use BankingWeb.ConnCase

  import BankingWeb.Factory

  @user_fixture build(:user)
  @credentials Map.take(@user_fixture, [:email, :password])
  @wallet_url Routes.api_v1_wallet_path(BankingWeb.Endpoint, :show)

  describe "show/2" do
    setup %{conn: conn} do
      {:ok, _user} = Auth.register(@user_fixture)
      {:ok, token} = Auth.sign_in(@credentials)
      %{conn: put_req_header(conn, "authorization", "Bearer #{token}")}
    end

    test "return user's balance", %{conn: conn} do
      conn = get(conn, @wallet_url)
      
      assert json_response(conn, 200)
      response = json_response(conn, 200)
      assert Map.has_key?(response, "balance"), message: "the balance dit not return"
    end
  end
end