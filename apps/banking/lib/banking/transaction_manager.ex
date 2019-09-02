defmodule Banking.TransactionManager do
  @moduledoc """
  Holds all logic related to withdrawals and transfers
  """

  import Ecto.Changeset
  import Banking.Transaction

  alias Ecto.Multi

  @doc """
  Builds an Ecto.Multi that holds all steps of a transfer process
  """
  @spec transfer(Ecto.Changeset.t()) :: Ecto.Multi.t()
  def transfer(changeset) do
    transferred_amount = get_field(changeset, :amount)
    source_user_id = get_field(changeset, :source_user_id)
    destination_user_id = get_field(changeset, :destination_user_id)

    debit = build_debit(source_user_id, transferred_amount)
    credit = build_credit(destination_user_id, transferred_amount)

    Multi.new()
    |> Multi.run(:has_sufficient_funds?, fn _repo, _ ->
      if has_sufficient_funds?(source_user_id, transferred_amount) do
        {:ok, true}
      else
        {:error, false}
      end
    end)
    |> Multi.insert(:debit, debit)
    |> Multi.insert(:credit, credit)
    |> Multi.run(:transfer, fn repo, %{debit: debit, credit: credit} ->
      changeset
      |> put_change(:debit_id, debit.id)
      |> put_change(:credit_id, credit.id)
      |> repo.insert()
    end)
  end

  @doc """
  The balance must always be greater than zero, so this function should
  be called before trying to create a new withdraw or transfer
  """
  @spec has_sufficient_funds?(integer(), Money.t()) :: boolean
  def has_sufficient_funds?(user_id, amount) do
    Banking.balance(user_id) >= amount
  end
end