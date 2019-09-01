defmodule BankingWeb.V1.WithdrawControllerTest do
  use BankingWeb.ConnCase

  import BankingWeb.Factory

  @user_fixture build(:user)
  @money_amount Money.new(10_000)
  @create_withdraw_url Routes.api_v1_withdraw_path(BankingWeb.Endpoint, :create)

  describe "create/2" do
    setup %{conn: conn} do
      {:ok, user} = Auth.register(@user_fixture)
      {:ok, _} = Banking.credit(user.id, @money_amount)

      {:ok, token} = Auth.sign_in(@user_fixture)
      conn = put_req_header(conn, "authorization", "Bearer #{token}")

      %{user: user, conn: conn}
    end

    test "returns 201 for successful withdrawals", %{conn: conn} do
      conn = post(conn, @create_withdraw_url, %{amount: @money_amount})
      assert json_response(conn, 201)
    end

    test "returns 400 if the user has insufficient funds, so as a message describing it", %{
      conn: conn
    } do
      amount = Money.add(@money_amount, Money.new(1000))
      conn = post(conn, @create_withdraw_url, %{amount: amount})

      assert json_response(conn, 400)
      assert %{"error" => "insufficient funds"}
    end

    test "returns 400 if the amount is invalid, so as a message describing the error", %{
      conn: conn
    } do
      conn = post(conn, @create_withdraw_url, %{amount: "invalid amount"})
      assert json_response(conn, 400)
      assert %{"errors" => %{"amount" => ["is invalid"]}} = json_response(conn, 400)
    end
  end
end
