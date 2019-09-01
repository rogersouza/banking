defmodule BankingWeb.V1.WalletController do
  use BankingWeb, :controller

  def show(conn, _params) do
    user_id = conn.assigns.user_id

    conn
    |> put_status(:ok)
    |> render("wallet.json", %{balance: Banking.balance(user_id)})
  end
end