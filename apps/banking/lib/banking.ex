defmodule Banking do
  @moduledoc """
  The banking system

  This module holds functions for withdraws, transfers and directly credit or debit
  of an especific user's wallet
  """
  
  import Ecto.Query
  import Banking.TransactionManager, only: [has_sufficient_funds?: 2]
  
  alias Banking.Transaction
  alias Banking.TransactionManager
  alias Banking.Transfer
  alias Banking.Withdraw
  alias Db.Repo

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
    %Transaction{description: "initial_amount"}
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

  @doc """
  Withdraws from the user's wallet

  It creates a transaction of type debit with "withdraw" as the description.
  Check Banking.Withdraw docs for further information

  ## Usage

  The happy case when the user has sufficient funds
  ```elixir
  # The user has $1000,00 in their wallet and tries to withdraw $500,00
  iex> {:ok, withdraw} = Banking.withdraw(user_id, "500,00")
  # Now, if you use Banking.balance/2 you can confirm that the wallet
  # has only $500,00
  ```

  When the wallet's balance is insufficient
  ```elixir
  # The user has $1000,00 in their wallet and tries to withdraw $2000,00
  iex> {:error, :insufficient_funds} = Banking.withdraw(user_id, "2000,00")
  ```

  Other than that, if the amount is invalid or the given user is inexistent, an
  changeset containing the error will be returned
  """
  @spec withdraw(integer(), amount()) ::
          {:ok, Withdraw.t()} | {:error, Ecto.Changeset.t()} | {:error, :insufficient_funds}
  def withdraw(user_id, amount) do
    attrs = %{amount: amount, user_id: user_id}
    changeset = Withdraw.changeset(%Withdraw{}, attrs)

    with %{valid?: true} <- changeset,
         true <- has_sufficient_funds?(user_id, changeset.changes.amount) do
      Repo.insert(changeset)
    else
      %{valid?: false} -> {:error, changeset}
      false -> {:error, :insufficient_funds}
    end
  end

  @doc """
  A transfer has three steps:

  1 - Debits from source
  2 - Credit destination's wallet
  3 - Creates a new transfer

  ## Usage

  When the source user has enough money
  ```
  transfer_attrs = %{
    amount: Money.new(1000),
    source_user_id: source_id,
    destination_user_id: destination_id
  }

  {:ok, transfer} = Banking.transfer(transfer_attrs)
  ```

  When the source user hasn't enough money
  ```
  transfer_attrs = %{
    amount: Money.new(1000),
    source_user_id: source_id,
    destination_user_id: destination_id
  }

  {:error, :insufficient_funds} = Banking.transfer(transfer_attrs)
  ```

  Problems related to data casting or not existing users will be returned within
  the changeset
  ```
  {:error, changeset} = Banking.transfer(invalid_transfer_attrs)
  ```

  """
  @spec transfer(map) :: {:ok, Transfer.t()} | {:error, Ecto.Changeset.t()}
  def transfer(attrs) do
    changeset = Transfer.changeset(%Transfer{}, attrs)

    if changeset.valid? do
      changeset
      |> TransactionManager.transfer()
      |> Repo.transaction()
      |> case do
        {:ok, %{transfer: transfer}} ->
          {:ok, transfer}

        {:error, :has_sufficient_funds?, false, _} ->
          {:error, :insufficient_funds}
      end
    else
      {:error, changeset}
    end
  end
end
