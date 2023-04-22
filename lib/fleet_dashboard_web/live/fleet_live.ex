defmodule FleetDashboardWeb.FleetLive do
  use FleetDashboardWeb, :live_view

  alias FleetDashboardWeb.SubmitTaskLive

  import FleetDashboard.Utils

  on_mount {FleetDashboardWeb.UserAuth, :ensure_admin}

  def mount(_params, _session, socket) do
    Phoenix.PubSub.subscribe(FleetMonitor.PubSub, "fleet_state")

    {:ok,
      socket
      |> assign(map_info: FleetMonitor.get_map_info())
      |> assign(image_topics: FleetMonitor.get_image_topics())
      |> assign_edges_and_verticies(FleetMonitor.get_nav_graph())
      |> assign(locations: FleetMonitor.get_locations())
      |> assign(fleet_state: nil)}
  end

  def handle_info({:fleet_state, fleet_state}, socket) do
    {:noreply, assign(socket, fleet_state: fleet_state)}
  end

  def assign_edges_and_verticies(socket, nav_graph) do
    assign(socket, verticies: nav_graph["verticies"], edges: nav_graph["edges"])
  end

  def get_map_image(%{"data" => map_file}) do
    case File.read(map_file) do
      {:ok, base64map } ->
        base64map
      {:error, _reason} ->
        nil
    end
  end

  def x_rel(%{"width" => width, "scale" => scale}, x_meter) do
    Float.round(abs((x_meter / (width * scale)) * 100), 3)
  end

  def y_rel(%{"height" => height, "scale" => scale}, y_meter) do
    Float.round(abs((y_meter / (height * scale)) * 100), 3)
  end

  def is_same_place?(%{"x" => x1, "y" => y1}, %{"x" => x2, "y" => y2}) do
    x_diff = abs(abs(x1) - abs(x2))
    y_diff = abs(abs(y1) - abs(y2))
    x_diff < 0.3 and y_diff < 0.3
  end

  def shift_list([head | tail], new_val) do
    [ new_val | shift_list(tail, head) ]
  end
  def shift_list([], _), do: []

  def get_paths(robot_path, robot_location) do
    Enum.zip(shift_list(robot_path, robot_location), robot_path)
  end

  def mode_colour(2), do: "bg-lime-400"
  def mode_colour(_), do: "bg-[#E0E2DB]"
end
