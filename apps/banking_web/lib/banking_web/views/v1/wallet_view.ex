defmodule BankingWeb.V1.WalletView do
  use BankingWeb, :view

  def render("wallet.json", %{balance: balance}) do
    %{balance: Money.to_string(balance, symbol: true)}
  end
end
