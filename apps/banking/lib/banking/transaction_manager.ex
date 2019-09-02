defmodule Banking.TransactionManager do
  @moduledoc """
  Holds all logic related to withdrawals and transfers
  """

  import Ecto.Changeset
  import Banking.Transaction

  alias Banking.Transfer
  alias Ecto.Multi

  @doc """
  If the transfer meets all the requirements, returns an Ecto.Multi with
  all the transfer steps.
  """
  @spec transfer(map()) ::
          {:error, Ecto.Changeset.t()}
          | {:error, :insufficient_funds}
          | Ecto.Multi.t()
  def transfer(attrs) do
    %{changes: changes} = changeset = Transfer.changeset(%Transfer{}, attrs)

    with %{valid?: true} <- changeset,
         true <- has_sufficient_funds?(changes.source_user_id, changes.amount) do
      build_transfer_multi(changeset)
    else
      false -> {:error, :insufficient_funds}
      %{valid?: false} -> {:error, changeset}
    end
  end

  defp build_transfer_multi(
         %{
           changes: %{
             source_user_id: source_user_id,
             destination_user_id: destination_user_id,
             amount: amount
           }
         } = changeset
       ) do
    debit = build_debit(source_user_id, amount)
    credit = build_credit(destination_user_id, amount)

    Multi.new()
    |> Multi.insert(:debit, debit)
    |> Multi.insert(:credit, credit)
    |> Multi.run(:transfer, &insert_transfer(&1, &2, changeset))
  end

  defp insert_transfer(repo, %{debit: debit, credit: credit}, changeset) do
    changeset
    |> put_change(:debit_id, debit.id)
    |> put_change(:credit_id, credit.id)
    |> repo.insert()
  end

  # @doc """
  # The balance must always be greater than zero, so this function should
  # be called before trying to create a new withdraw or transfer
  # """
  @spec has_sufficient_funds?(integer(), Money.t()) :: boolean
  def has_sufficient_funds?(user_id, amount) do
    Banking.balance(user_id) >= amount
  end
end
