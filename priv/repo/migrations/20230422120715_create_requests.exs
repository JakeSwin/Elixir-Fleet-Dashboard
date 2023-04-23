defmodule FleetDashboard.Repo.Migrations.CreateRequests do
  use Ecto.Migration

  def change do
    create table(:requests) do
      add :start, :string
      add :finish, :string
      add :timestamp, :utc_datetime
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:requests, [:user_id])
  end
end
