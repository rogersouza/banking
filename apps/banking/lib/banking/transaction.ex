defmodule Banking.Transaction do
  @moduledoc """
  An entry representing a debit or credit for a user
  """

  use Ecto.Schema

  import Ecto.Changeset

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
end
