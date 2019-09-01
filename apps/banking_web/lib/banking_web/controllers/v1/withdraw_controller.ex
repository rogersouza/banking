defmodule BankingWeb.V1.WithdrawController do
  use BankingWeb, :controller

  def create(conn, %{"amount" => amount}) do
    case Banking.withdraw(conn.assigns.user_id, amount) do
      {:ok, withdraw} ->
        conn
        |> put_status(:created)
        |> render("withdraw.json", withdraw)

      {:error, :insufficient_funds} ->
        conn
        |> put_status(:bad_request)
        |> render("insufficient_funds.json")

      {:error, changeset} ->
        conn
        |> put_status(:bad_request)
        |> put_view(BankingWeb.ErrorView)
        |> render("400.json", changeset)
    end
  end
end