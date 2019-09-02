defmodule BankingWeb.V1.TransferController do
  use BankingWeb, :controller

  def create(conn, transfer) do
    transfer = Map.put(transfer, "source_user_id", conn.assigns.user_id)

    case Banking.transfer(transfer) do
      {:ok, transfer} ->
        conn
        |> put_status(:created)
        |> render("transfer.json", transfer)
    end
  end
end