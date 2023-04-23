defmodule FleetDashboard.FleetTest do
  use FleetDashboard.DataCase

  alias FleetDashboard.Fleet

  describe "requests" do
    alias FleetDashboard.Fleet.Request

    import FleetDashboard.FleetFixtures

    @invalid_attrs %{finish: nil, start: nil, timestamp: nil}

    test "list_requests/0 returns all requests" do
      request = request_fixture()
      assert Fleet.list_requests() == [request]
    end

    test "get_request!/1 returns the request with given id" do
      request = request_fixture()
      assert Fleet.get_request!(request.id) == request
    end

    test "create_request/1 with valid data creates a request" do
      valid_attrs = %{finish: "some finish", start: "some start", timestamp: ~U[2023-04-21 12:07:00Z]}

      assert {:ok, %Request{} = request} = Fleet.create_request(valid_attrs)
      assert request.finish == "some finish"
      assert request.start == "some start"
      assert request.timestamp == ~U[2023-04-21 12:07:00Z]
    end

    test "create_request/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Fleet.create_request(@invalid_attrs)
    end

    test "update_request/2 with valid data updates the request" do
      request = request_fixture()
      update_attrs = %{finish: "some updated finish", start: "some updated start", timestamp: ~U[2023-04-22 12:07:00Z]}

      assert {:ok, %Request{} = request} = Fleet.update_request(request, update_attrs)
      assert request.finish == "some updated finish"
      assert request.start == "some updated start"
      assert request.timestamp == ~U[2023-04-22 12:07:00Z]
    end

    test "update_request/2 with invalid data returns error changeset" do
      request = request_fixture()
      assert {:error, %Ecto.Changeset{}} = Fleet.update_request(request, @invalid_attrs)
      assert request == Fleet.get_request!(request.id)
    end

    test "delete_request/1 deletes the request" do
      request = request_fixture()
      assert {:ok, %Request{}} = Fleet.delete_request(request)
      assert_raise Ecto.NoResultsError, fn -> Fleet.get_request!(request.id) end
    end

    test "change_request/1 returns a request changeset" do
      request = request_fixture()
      assert %Ecto.Changeset{} = Fleet.change_request(request)
    end
  end
end
