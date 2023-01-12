defmodule BitURL.Repo.Migrations.CreateLinks do
  use Ecto.Migration

  def change do
    create table(:links) do
      add :bit, :string
      add :url, :string

      index :links, :bit, unique: true

      timestamps()
    end

    create index(:links, :bit, unique: true)
  end
end
