defmodule BankingWeb.V1.UserControllerTest do
  use BankingWeb.ConnCase

  import BankingWeb.Factory

  @create_user_url Routes.api_v1_user_path(BankingWeb.Endpoint, :create)
  @initial_balance Application.get_env(:banking, :initial_balance) |> Money.new()

  describe "create/2" do
    test "creates a new user and returns 201", %{conn: conn} do
      user = build(:user)
      conn = post(conn, @create_user_url, user)

      email = user.email
      name = user.name

      assert json_response(conn, 201)
      assert %{"email" => ^email, "name" => ^name} = json_response(conn, 201)
    end

    test "returns 400 if some field is invalid or blank", %{conn: conn} do
      user = build(:user, email: "")
      conn = post(conn, @create_user_url, user)

      assert json_response(conn, 400)

      response = json_response(conn, 400)
      assert Map.has_key?(response, "errors")
      assert Map.has_key?(response["errors"], "email")
    end

    test "returns 409 user's email is already taken", %{conn: conn} do
      user = build(:user)
      {:ok, _user} = Auth.register(user)

      conn = post(conn, @create_user_url, user)
      assert json_response(conn, 409)
    end

    test "doesn't return the password", %{conn: conn} do
      user = build(:user)
      conn = post(conn, @create_user_url, user)
      response = json_response(conn, 201)

      refute Map.has_key?(response, "password"), message: "the password hash is private and should not be returned"
    end

    test "gives @initial_amount to the user", %{conn: conn} do
      user = build(:user)
      conn = post(conn, @create_user_url, user)
      %{"id" => user_id} = json_response(conn, 201)

      assert Banking.balance(user_id) == @initial_balance
    end
  end
end
