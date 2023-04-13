defmodule FleetDashboardWeb.FleetLive do
  use FleetDashboardWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok,
      socket
      |> assign(map_info: FleetMonitor.get_map_info())
      |> assign(image_topics: FleetMonitor.get_image_topics())
      |> assign_edges_and_verticies(FleetMonitor.get_nav_graph())
      |> assign(locations: FleetMonitor.get_locations())}
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
    abs((x_meter / (width * scale)) * 100)
  end

  def y_rel(%{"height" => height, "scale" => scale}, y_meter) do
    abs((y_meter / (height * scale)) * 100)
  end
end
