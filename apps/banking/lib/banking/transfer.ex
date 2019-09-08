defmodule Banking.Transfer do
  @moduledoc """
  A transfer entry.

  It holds all the information about transfers, from the transferee to the recipient.

  """

  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query

  @fields ~w(
    source_user_id
    destination_user_id
    amount
  )a

  schema "transfers" do
    field :source_user_id, :integer
    field :destination_user_id, :integer
    field :amount, Banking.Money.Type, virtual: true
    field :debit_id, :integer
    field :credit_id, :integer
  end

  def changeset(transfer, params) do
    transfer
    |> cast(params, @fields)
    |> validate_required(@fields)
    |> validate_destination_user_exist()
    |> validate_source_and_destination_are_different()
    |> validate_amount_is_greater_or_equal_zero()
  end

  defp validate_destination_user_exist(changeset) do
    id = get_field(changeset, :destination_user_id)

    if Db.Repo.exists?(user(id)) do
      changeset
    else
      add_error(changeset, :destination_user_id, "doesn't exist")
    end
  end

  defp user(id) do
    from u in "users",
      where: [id: ^id],
      select: [:id]
  end

  defp validate_amount_is_greater_or_equal_zero(changeset) do
    with %{valid?: true, changes: %{amount: amount}} <- changeset,
         false <- Money.negative?(amount) or Money.zero?(amount) do
      changeset
    else
      true -> add_error(changeset, :amount, "must be positive")
      _invalid_changeset -> changeset
    end
  end

  defp validate_source_and_destination_are_different(%{valid?: true} = changeset) do
    destination_user_id = get_field(changeset, :destination_user_id)
    source_user_id = get_field(changeset, :source_user_id)

    if destination_user_id == source_user_id do
      add_error(changeset, :destination_user_id, "can't be the same as the source user")
    else
      changeset
    end
  end

  defp validate_source_and_destination_are_different(changeset), do: changeset
end
