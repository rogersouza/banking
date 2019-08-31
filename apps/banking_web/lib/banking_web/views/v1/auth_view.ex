defmodule BankingWeb.V1.AuthView do
  use BankingWeb, :view

  def render("token.json", %{token: token}) do
    %{token: token}
  end
end