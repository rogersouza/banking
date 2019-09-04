defmodule Backoffice.Report do
  @moduledoc false

  defstruct withdrawals: Money.new(0),
            transfers: Money.new(0),
            system_credit: Money.new(0),
            total: Money.new(0)

  import Ecto.Query

  def build({year, month, day}) do
    from(t in "transactions")
    |> year_filter(year)
    |> month_filter(month)
    |> day_filter(day)
    |> group_by([t], [t.type, t.description])
    |> select([t], {sum(t.amount), t.type, t.description})
  end

  defp year_filter(query, nil), do: query

  defp year_filter(query, year) do
    where(query, [t], fragment("date_part('year', ?)", t.inserted_at) == ^year)
  end

  defp month_filter(query, nil), do: query

  defp month_filter(query, month) do
    where(query, [t], fragment("date_part('month', ?)", t.inserted_at) == ^month)
  end

  defp day_filter(query, nil), do: query

  defp day_filter(query, day) do
    where(query, [t], fragment("date_part('day', ?)", t.inserted_at) == ^day)
  end

  def into_report_struct(results) when results == [], do: %__MODULE__{}

  def into_report_struct(results) do
    Enum.reduce(results, %__MODULE__{}, fn
      {amount, "debit", "withdraw"}, report -> debit(report, amount)
      {amount, "credit", "transfer"}, report -> credit_transfer(report, amount)
      {amount, "credit", "initial_amount"}, report -> system_credit(report, amount)
      _, report -> report
    end)
    |> compute_total()
  end

  defp debit(report, amount) do
    amount = Money.new(amount)
    %{report | withdrawals: Money.subtract(report.withdrawals, amount)}
  end

  defp credit_transfer(report, amount) do
    amount = Money.new(amount)
    %{report | transfers: Money.add(report.transfers, amount)}
  end

  defp system_credit(report, amount) do
    amount = Money.new(amount)
    %{report | system_credit: Money.add(report.system_credit, amount)}
  end

  defp compute_total(report) do
    [_ | values] = Map.values(report)
    total = Enum.reduce(values, 0, fn value, total -> total + value.amount end)

    %{report | total: Money.new(total)}
  end
end
