defmodule Db.Repo.Migrations.AddTransfers do
  use Ecto.Migration

  def change do
    create table(:transfers) do
      add :source_user_id, :integer
      add :destination_user_id, :integer
      add :debit_id, references(:transactions)
      add :credit_id, references(:transactions)
    end
  end
end
