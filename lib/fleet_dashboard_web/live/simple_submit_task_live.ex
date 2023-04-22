defmodule FleetDashboardWeb.SimpleSubmitTaskLive do
  use FleetDashboardWeb, :live_component

  alias FleetDashboard.TaskRequest

  def mount(socket) do
    {:ok, 
      socket
      |> assign_task_request()
      |> assign_changeset()
      |> assign_form()}
  end

  def render(assigns) do
    ~H"""
    <div>
      <%= if @available_robots do %>
      <.simple_form
        for={@form}
        id="task-request-form"
        phx-target={@myself}
        phx-submit="save"
        phx-change="validate">
        <.input field={@form[:start]} type="select" options={@locations} label="Go to" />
        <:actions>
          <.button phx-disable-with="Sending...">Send Task Request</.button>
        </:actions>
      </.simple_form>
      <% else %>
        <div class="mt-5 text-xl text-red-500">Connecting to fleet... Please wait</div>
      <% end %>
      <ul :if={@available_robots}>
        <li :for={name <- @available_robots}><%= name %></li>
      </ul>
    </div>
    """
  end

  def handle_event("save", %{"task_request" => task_request_params}, %{assigns: %{task_request: task_request, available_robots: robots, locations: locations}} = socket) do
    task_request_params =
      task_request_params
      |> Map.put("finish", random_finish(robots, locations))

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

  def handle_event("validate", %{"task_request" => task_request_params}, %{assigns: %{task_request: task_request, available_robots: robots, locations: locations}} = socket) do
    task_request_params =
      task_request_params
      |> Map.put("finish", random_finish(robots, locations))

    changeset =
      task_request
      |> TaskRequest.changeset(task_request_params)
      |> Map.put(:action, :validate)

    {:noreply,
      socket
      |> assign(changeset: changeset)
      |> assign_form()}
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

  def random_finish(nil, locations), do: Enum.random(locations)
  def random_finish([], locations), do: Enum.random(locations)
  def random_finish(robots, _locations) do
    Enum.random(robots) <> "_charger"
  end
end
