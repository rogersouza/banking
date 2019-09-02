defmodule BankingWeb.V1.AuthController do
  use BankingWeb, :controller

  def authenticate(conn, credentials) do
    case Auth.sign_in(credentials) do
      {:ok, token} ->
        conn
        |> put_status(:ok)
        |> render("token.json", %{token: token})

      {:error, :unauthorized} ->
        conn
        |> put_status(:unauthorized)
        |> put_view(BankingWeb.ErrorView)
        |> render("401.json")

      {:error, changeset} ->
        conn
        |> put_status(:bad_request)
        |> put_view(BankingWeb.ErrorView)
        |> render("400.json", changeset)
    end
  end
end
