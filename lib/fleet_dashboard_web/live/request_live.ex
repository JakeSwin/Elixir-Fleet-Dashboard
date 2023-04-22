defmodule FleetDashboardWeb.RequestLive do
  use FleetDashboardWeb, :live_view

  alias FleetDashboardWeb.SubmitTaskLive

  import FleetDashboard.Utils

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(locations: FleetMonitor.get_locations())

    {:ok, socket}
  end
end