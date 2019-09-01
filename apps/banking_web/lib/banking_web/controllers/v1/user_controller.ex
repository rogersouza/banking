defmodule BankingWeb.V1.UserController do
  use BankingWeb, :controller

  @initial_balance Application.get_env(:banking, :initial_balance)

  def create(conn, user) do
    case Auth.register(user) do
      {:ok, user} ->
        {:ok, _} = Banking.credit(user.id, @initial_balance)

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
