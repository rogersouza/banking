defmodule Banking.Transaction do
  @moduledoc """
  An entry representing a debit or credit for a user
  """

  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query

  alias __MODULE__

  @fields [:user_id, :amount, :type]

  schema "transactions" do
    field :user_id, :integer
    field :amount, Money.Ecto.Amount.Type
    field :type, :string
  end

  def changeset(transaction, params) do
    transaction
    |> cast(params, @fields)
    |> validate_required(@fields)
  end

  def credits(user_id) do
    from t in Transaction,
      where:
        t.user_id == ^user_id and
          t.type == ^"credit"
  end

  def debits(user_id) do
    from t in Transaction,
      where:
        t.user_id == ^user_id and
          t.type == ^"credit"
  end
end
