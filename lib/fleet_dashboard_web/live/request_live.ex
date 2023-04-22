defmodule FleetDashboardWeb.RequestLive do
  use FleetDashboardWeb, :live_view

  alias FleetDashboardWeb.SimpleSubmitTaskLive

  import FleetDashboard.Utils

  def mount(_params, _session, socket) do
    Phoenix.PubSub.subscribe(FleetMonitor.PubSub, "fleet_state")

    socket =
      socket
      |> assign(locations: FleetMonitor.get_locations())
      |> assign(fleet_state: nil)

    {:ok, socket}
  end

  def handle_info({:fleet_state, fleet_state}, socket) do
    {:noreply, assign(socket, fleet_state: fleet_state)}
  end

  def available_robots(nil), do: nil
  def available_robots(fleet_state) do
    Enum.reduce(fleet_state["robots"], [], 
      fn r, acc -> cond do
        r["mode"]["mode"] == 2 -> acc
        true -> [ r["name"] | acc ]
      end
    end)
  end
end