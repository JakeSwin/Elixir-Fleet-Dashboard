defmodule FleetDashboard.Repo do
  use Ecto.Repo,
    otp_app: :fleet_dashboard,
    adapter: Ecto.Adapters.Postgres
end
