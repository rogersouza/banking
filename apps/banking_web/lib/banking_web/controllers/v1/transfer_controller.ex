defmodule BankingWeb.V1.TransferController do
  use BankingWeb, :controller

  def create(conn, transfer) do
    transfer = Map.put(transfer, "source_user_id", conn.assigns.user_id)

    case Banking.transfer(transfer) do
      {:ok, transfer} ->
        conn
        |> put_status(:created)
        |> render("transfer.json", transfer)

      {:error, :insufficient_funds} ->
        conn
        |> put_status(:bad_request)
        |> put_view(BankingWeb.ErrorView)
        |> render("insufficient_funds.json")

      {:error, changeset} ->
        conn
        |> put_status(:bad_request)
        |> put_view(BankingWeb.ErrorView)
        |> render("400.json", changeset)
    end
  end
end