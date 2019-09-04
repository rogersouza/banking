defmodule Backoffice.Report do
  @moduledoc false

  defstruct withdrawals: Money.new(0),
            transfers: Money.new(0),
            system_credit: Money.new(0),
            total: Money.new(0)

  import Ecto.Query

  @type t() :: %__MODULE__{}

  @type day() :: integer()
  @type month() :: integer()
  @type year() :: integer()

  @spec build({year(), month(), day()}) :: Ecto.Query.t()
  @doc """
  Builds the report query
  """
  def build({year, month, day}) do
    from(t in "transactions")
    |> filter("year", year)
    |> filter("month", month)
    |> filter("day", day)
    |> group_by([t], [t.type, t.description])
    |> select([t], {sum(t.amount), t.type, t.description})
  end

  defp filter(query, field, value) do
    if value == nil do
      query
    else
      where(query, [t], fragment("date_part(?, ?)", ^field, t.inserted_at) == ^value)
    end
  end

  @spec mount(list(tuple())) :: t()
  def mount(results) when results == [], do: %__MODULE__{}

  def mount(results) do
    results
    |> Enum.reduce(%__MODULE__{}, fn
      {amount, "debit", "withdraw"}, report -> add(report, amount, :withdrawals)
      {amount, "credit", "transfer"}, report -> add(report, amount, :transfers)
      {amount, "credit", "initial_amount"}, report -> add(report, amount, :system_credit)
      _, report -> report
    end)
    |> compute_total()
  end

  defp add(report, amount, field) do
    amount = Money.new(amount)
    Map.update(report, field, Money.new(0), fn v -> Money.add(amount, v) end)
  end

  defp compute_total(report) do
    [_ | values] = Map.values(report)
    total = Enum.reduce(values, 0, fn value, total -> total + value.amount end)
    %{report | total: Money.new(total)}
  end
end
