defmodule Db.Repo.Migrations.AddTransactions do
  use Ecto.Migration

  def change do
    create table(:transactions) do
      add :user_id, references(:users), null: false
      add :amount, :integer, null: false
      add :type, :string, null: false
    end
  end
end
