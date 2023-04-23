defmodule FleetDashboard.FleetFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `FleetDashboard.Fleet` context.
  """

  @doc """
  Generate a request.
  """
  def request_fixture(attrs \\ %{}) do
    {:ok, request} =
      attrs
      |> Enum.into(%{
        finish: "some finish",
        start: "some start",
        timestamp: ~U[2023-04-21 12:07:00Z]
      })
      |> FleetDashboard.Fleet.create_request()

    request
  end
end
