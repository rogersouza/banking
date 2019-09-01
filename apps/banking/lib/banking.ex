defmodule Banking do
  @moduledoc false

  import Ecto.Query

  alias Banking.Repo
  alias Banking.Transaction

  def credit(user_id, amount) do
    %Transaction{}
    |> Transaction.changeset(%{amount: amount, user_id: user_id, type: "credit"})
    |> Repo.insert()
  end

  def balance(user_id) do
    Transaction
    |> where([t], t.user_id == ^user_id)
    |> group_by([t], t.type)
    |> select([t], {t.type, sum(t.amount)})
    |> Repo.all()
    |> compute_balance()
  end

  defp compute_balance([{"credit", credit}, {"debit", debit}]) do
    Money.new(credit - debit)
  end

  defp compute_balance(_), do: Money.new(0)
end
