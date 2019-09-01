defmodule Db.Repo.Migrations.AddUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :string, null: false
      add :password, :string, null: false
      add :name, :string, null: false
    end

    create unique_index(:users, :email)
  end
end
