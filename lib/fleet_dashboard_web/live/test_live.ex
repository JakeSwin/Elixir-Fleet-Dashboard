defmodule FleetDashboardWeb.TestLive do
  use FleetDashboardWeb, :live_view

  def mount(_params, _session, socket) do
    FleetMonitor.subscribe(self())
    {:ok, assign(socket, message: "Hello", test_num: nil, image: nil)}
  end

  @spec render(any) :: Phoenix.LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <h1><%= @message %></h1>
    <h2 :if={@test_num}><%= @test_num %></h2>
    <img :if={@image} src={"data:image/jpeg;base64," <> @image}/>
    """
  end

  def handle_info({:test, num}, socket) do
    {:noreply, assign(socket, test_num: num )}
  end

  def handle_info({:new_image, image_data}, socket) do
    {:noreply, assign(socket, image: image_data)}
  end
end