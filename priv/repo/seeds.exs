# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     FleetDashboard.Repo.insert!(%FleetDashboard.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias FleetDashboard.Accounts

Accounts.register_user(%{
  email: "admin@example.com",
  password: "admin_password123",
  roles: ~w(admin)
}) |> IO.inspect()
