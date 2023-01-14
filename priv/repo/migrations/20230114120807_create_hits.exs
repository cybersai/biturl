defmodule BitURL.Repo.Migrations.CreateHits do
  use Ecto.Migration

  def change do
    create table(:hits) do
      add :device, :string
      add :os, :string
      add :browser, :string
      add :link_id, references(:links, on_delete: :nothing)

      timestamps()
    end

    create index(:hits, [:link_id])
  end
end
