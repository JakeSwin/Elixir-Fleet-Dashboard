defmodule FleetDashboardWeb.SubmitTaskLive do
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
      <.simple_form
        for={@form}
        id="task-request-form"
        phx-target={@myself}
        phx-submit="save"
        phx-change="validate">
        <.input field={@form[:start]} type="select" options={@locations} label="Start location" />
        <.input field={@form[:finish]} type="select" options={@locations} label="Finish location" />
        <:actions>
          <.button phx-disable-with="Sending...">Send Task Request</.button>
        </:actions>
      </.simple_form>
    </div>
    """
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
end
