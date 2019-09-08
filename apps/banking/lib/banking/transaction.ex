defmodule Banking.Transaction do
  @moduledoc """
  An entry representing a debit or credit for a user
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias __MODULE__

  @fields [:user_id, :amount, :type]

  schema "transactions" do
    field :user_id, :integer
    field :amount, Banking.Money.Type
    field :type, :string
    field :description, :string

    timestamps()
  end

  def changeset(transaction, params) do
    transaction
    |> cast(params, @fields)
    |> validate_required(@fields)
  end

  def build_credit(user_id, %Money{} = amount, description \\ "transfer") do
    %Transaction{
      user_id: user_id,
      amount: amount,
      type: "credit",
      description: description,
    }
  end

  def build_debit(user_id, %Money{} = amount, description \\ "transfer") do
    %Transaction{
      user_id: user_id,
      amount: amount,
      type: "debit",
      description: description,
    }
  end
end
