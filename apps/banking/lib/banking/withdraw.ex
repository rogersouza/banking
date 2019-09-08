defmodule Banking.Withdraw do
  @moduledoc """
  An abstraction of a transaction.

  The following fields should always be fixed as:

  type => "debit"
  description => "withdraw"

  """
  @derive {Jason.Encoder, only: [:id, :user_id, :amount, :inserted_at]}

  use Ecto.Schema

  import Ecto.Changeset

  @fields [:user_id, :amount, :type]

  schema "transactions" do
    field :user_id, :integer
    field :amount, Money.Ecto.Amount.Type
    field :type, :string, default: "debit"
    field :description, :string, default: "withdraw"

    timestamps()
  end

  def changeset(withdraw, params) do
    withdraw
    |> cast(params, @fields)
    |> validate_required(@fields)
    |> check_constraint(:amount, name: :amount_cannot_be_negative, message: "must be positive")
  end
end
