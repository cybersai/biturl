defmodule BitURL.Repo.Migrations.AddUserIdToLinks do
  use Ecto.Migration

  def change do
    alter table(:links) do
      add :user_id, :int
    end
  end
end
