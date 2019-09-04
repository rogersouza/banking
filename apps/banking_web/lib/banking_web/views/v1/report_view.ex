defmodule BankingWeb.V1.ReportView do
  use BankingWeb, :controller

  def render("report.json", report) do
    %{
      transfers: money(report.transfers),
      system_credit: money(report.system_credit),
      withdrawals: money(report.withdrawals),
      total: money(report.total)
    }
  end

  defp money(m) do
    Money.to_string(m, symbol: true)
  end
end
