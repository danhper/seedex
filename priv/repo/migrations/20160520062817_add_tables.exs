defmodule Seedex.Repo.Migrations.AddTables do
  use Ecto.Migration

  def change do
    create table(:groups) do
      add :name, :string
    end

    create table(:users) do
      add :name, :string
      add :age,  :integer
      add :group_id, references(:groups)
    end
  end
end
