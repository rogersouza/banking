defmodule BankingWeb.V1.UserController do
  use BankingWeb, :controller

  def create(conn, user) do
    case Auth.register(user) do
      {:ok, user} ->
        conn
        |> put_status(:created)
        |> json(user)

      {:error, %{errors: [email: {"has already been taken", _}]} = changeset} ->
        conn
        |> put_status(:conflict)
        |> put_view(BankingWeb.ErrorView)
        |> render("409.json", changeset)

      {:error, changeset} ->
        conn
        |> put_status(:bad_request)
        |> put_view(BankingWeb.ErrorView)
        |> render("400.json", changeset)
    end
  end
end
