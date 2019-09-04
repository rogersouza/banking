defmodule BankingWeb.V1.ReportController do
  use BankingWeb, :controller

  def show(conn, filters) do
    case Backoffice.report(filters) do
      {:ok, report} ->
        conn
        |> put_status(:ok)
        |> render("report.json", report)

      {:error, :invalid_filter_combination} ->
        conn
        |> put_status(:not_found)
        |> put_view(BankingWeb.ErrorView)
        |> render("404.json")
    end
  end
end
