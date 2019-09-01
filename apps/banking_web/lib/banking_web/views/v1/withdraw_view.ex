defmodule BankingWeb.V1.WithdrawView do
  use BankingWeb, :view

  def render("withdraw.json", withdraw) do
    %{
      id: withdraw.id,
      amount: Money.to_string(withdraw.amount, symbol: true),
      withdrawn_at: withdraw.inserted_at
    }
  end

  def render("insufficient_funds.json", _) do
    %{error: "insufficient funds"}
  end
end