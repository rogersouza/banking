defmodule Db.Repo.Migrations.AddTransactions do
  use Ecto.Migration

  def change do
    create table(:transactions) do
      add :user_id, references(:users), null: false
      add :amount, :integer, null: false
      add :type, :string, null: false
      add :description, :string, null: false

      timestamps()
    end

    create constraint(:transactions, :amount_cannot_be_negative, check: "amount >= 0")
  end
end
