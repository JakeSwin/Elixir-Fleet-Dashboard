defmodule FleetDashboardWeb.FleetLive do
  use FleetDashboardWeb, :live_view

  alias FleetDashboard.TaskRequest

  def mount(_params, _session, socket) do
    Phoenix.PubSub.subscribe(FleetMonitor.PubSub, "fleet_state")
    {:ok,
      socket
      |> assign(map_info: FleetMonitor.get_map_info())
      |> assign(image_topics: FleetMonitor.get_image_topics())
      |> assign_edges_and_verticies(FleetMonitor.get_nav_graph())
      |> assign(locations: FleetMonitor.get_locations())
      |> assign(locations_list: get_locations_list(FleetMonitor.get_locations()))
      |> assign(fleet_state: nil)
      |> assign_task_request()
      |> assign_changeset()
      |> assign_form()}
  end

  def handle_info({:fleet_state, fleet_state}, socket) do
    {:noreply, assign(socket, fleet_state: fleet_state)}
  end

  def handle_event("save", %{"task_request" => task_request_params}, %{assigns: %{task_request: task_request}} = socket) do
    changeset =
      task_request
      |> TaskRequest.changeset(task_request_params)
      |> Map.put(:action, :validate)

    if changeset.valid? do
      FleetMonitor.submit_task(task_request_params["start"], task_request_params["finish"])
    end

    {:noreply,
      socket
      |> assign(changeset: changeset)
      |> assign_form()}
  end

  def handle_event("validate", %{"task_request" => task_request_params}, %{assigns: %{task_request: task_request}} = socket) do
    changeset =
      task_request
      |> TaskRequest.changeset(task_request_params)
      |> Map.put(:action, :validate)

    {:noreply,
      socket
      |> assign(changeset: changeset)
      |> assign_form()}
  end

  def assign_edges_and_verticies(socket, nav_graph) do
    assign(socket, verticies: nav_graph["verticies"], edges: nav_graph["edges"])
  end

  def assign_task_request(socket) do
    socket
    |> assign(task_request: %TaskRequest{})
  end

  def assign_changeset(%{assigns: %{task_request: task_request}} = socket) do
    socket
    |> assign(changeset: TaskRequest.changeset(task_request))
  end

  def assign_form(%{assigns: %{changeset: changeset}} = socket) do
    socket
    |> assign(form: to_form(changeset))
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

  def get_locations_list(locations) do
    locations
    |> Enum.map(&Enum.at(&1, 0))
    |> Enum.map(fn x -> {_, loc} = x; loc end)
  end

  def mode_colour(2), do: "bg-lime-400"
  def mode_colour(_), do: "bg-[#E0E2DB]"
end
