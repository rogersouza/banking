defmodule Auth.User do
  use Ecto.Schema

  import Ecto.Changeset

  alias Auth.Encryption

  @fields [:email, :password, :name]

  schema "users" do
    field :email, :string
    field :password, :string
    field :name, :string
  end

  def changeset(user, params) do
    user
    |> cast(params, @fields)
    |> validate_required(@fields)
    |> unique_constraint(:email)
    |> validate_format(:email, ~r/@/)
    |> hash_password()
  end

  defp hash_password(%{changes: %{password: password}} = changeset) do
    if changeset.valid? do
      put_change(changeset, :password, Encryption.put_hash(password))
    else
      changeset
    end
  end
end