defmodule FleetDashboardWeb.RequestLive do
  use FleetDashboardWeb, :live_view

  alias FleetDashboardWeb.SimpleSubmitTaskLive
  alias FleetDashboard.Fleet

  import FleetDashboard.Utils

  def mount(_params, _session, socket) do
    Phoenix.PubSub.subscribe(FleetMonitor.PubSub, "fleet_state")
    Phoenix.PubSub.subscribe(FleetMonitor.PubSub, "new_request")

    socket =
      socket
      |> assign(locations: FleetMonitor.get_locations())
      |> assign(fleet_state: nil)
      |> add_stream_requests()

    {:ok, socket}
  end

  def handle_info({:fleet_state, fleet_state}, socket) do
    {:noreply, assign(socket, fleet_state: fleet_state)}
  end

  def handle_info({:new_request, request}, %{assigns: %{current_user: user}} = socket) do
    if request.user_id == user.id do
      {:noreply, stream_insert(socket, :requests, convert_request_time(request), at: 0)}
    else
      {:noreply, socket}
    end
  end

  def add_stream_requests(%{assigns: %{current_user: user}} = socket) do
    requests = 
      Fleet.list_requests()
      |> Enum.sort(& &1.id >= &2.id)
      |> Enum.filter(& &1.user_id == user.id)
      |> Enum.map(&convert_request_time/1)

    stream(socket, :requests, requests)
  end

  def convert_request_time(request) do
    %{ request | inserted_at: convert_native(request.inserted_at) }
  end

  def convert_native(time) do
    {:ok, utc_time} = DateTime.from_naive(time, "Etc/UTC")
    utc_time
    |> DateTime.add(1, :hour)
    |> DateTime.to_string()
    |> String.replace("Z", "")
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