defmodule BankingWeb.V1.TransferView do
  use BankingWeb, :view

  def render("transfer.json", transfer) do
    %{
      id: transfer.id,
      destination_user_id: transfer.destination_user_id,
      amount: Money.to_string(transfer.amount, symbol: true)
    }
  end
end