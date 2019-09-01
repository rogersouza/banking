defmodule Banking do
  @moduledoc """
  The banking system

  This module holds functions for withdraws, transfers and directly credit or debit
  of an especific user's wallet
  """

  import Ecto.Query

  alias Db.Repo
  alias Banking.Transaction

  @type amount() :: String.t() | Money.t()

  @doc """
  This can be used to directly credit a user's wallet

  ## Usage
  ```
  # User has balance of 0,00
  iex> {:ok, _} = Banking.credit(user_id, "500,00")
  iex> {:ok, balance} = Banking.balance(user_id)
  {:ok, %Money{amount: 50000}}
  ```
  """
  @spec credit(integer(), amount()) :: {:ok, Transaction.t()} | {:error, Money.t()}
  def credit(user_id, amount) do
    %Transaction{}
    |> Transaction.changeset(%{amount: amount, user_id: user_id, type: "credit"})
    |> Repo.insert()
  end

  @doc """
  Returns the user's current balance
  """
  @spec balance(integer()) :: Money.t()
  def balance(user_id) do
    Transaction
    |> where([t], t.user_id == ^user_id)
    |> group_by([t], t.type)
    |> select([t], {t.type, sum(t.amount)})
    |> Repo.all()
    |> compute_balance()
  end

  defp compute_balance(results) do
    Enum.reduce(results, Money.new(0), fn
      {"credit", amount}, total -> Money.add(total, amount)
      {"debit", amount}, total -> Money.subtract(total, amount)
      _, total -> total
    end)
  end
end
