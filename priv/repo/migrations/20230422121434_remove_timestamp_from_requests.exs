defmodule FleetDashboard.Repo.Migrations.RemoveTimestampFromRequests do
  use Ecto.Migration

  def change do
    alter table(:requests) do
      remove :timestamp
    end
  end
end
