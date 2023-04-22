defmodule FleetDashboard.Utils do

  def get_locations_list(locations) do
    locations
    |> Enum.map(&Enum.at(&1, 0))
    |> Enum.map(fn x -> {_, loc} = x; loc end)
  end
end
