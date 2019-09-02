defmodule BankingWeb.V1.TransferControllerTest do
  use BankingWeb.ConnCase

  import BankingWeb.Factory

  @source_user_attrs build(:user)
  @dest_user_attrs build(:user)
  @initial_balance Application.get_env(:banking, :initial_balance)

  @create_transfer_url Routes.api_v1_transfer_path(BankingWeb.Endpoint, :create)

  describe "create/2" do
    setup %{conn: conn} do
      {:ok, source_user} = Auth.register(@source_user_attrs)
      {:ok, _} = Banking.credit(source_user.id, @initial_balance)
      {:ok, token} = Auth.sign_in(@source_user_attrs)

      %{
        conn: put_req_header(conn, "authorization", "Bearer #{token}"),
        source_user: source_user
      }
    end

    test "retuns 201 for successfully transfers", %{conn: conn} do
      {:ok, destination_user} = Auth.register(@dest_user_attrs)

      transfer = %{
        "destination_user_id" => destination_user.id,
        "amount" => @initial_balance
      }

      conn = post(conn, @create_transfer_url, transfer)
      assert json_response(conn, 201)
    end

    test "returns 400 if the destination user doesn't exist", %{conn: conn} do
      transfer = %{
        "destination_user_id" => 0,
        "amount" => @initial_balance
      }

      conn = post(conn, @create_transfer_url, transfer)
      assert json_response(conn, 400)

      assert %{"errors" => %{"destination_user_id" => ["doesn't exist"]}} =
               json_response(conn, 400)
    end

    test "returns 400 if the source user hasn't enough money", %{conn: conn} do
      {:ok, destination_user} = Auth.register(@dest_user_attrs)

      transfer = %{
        "destination_user_id" => destination_user.id,
        "amount" => @initial_balance + 1000
      }

      conn = post(conn, @create_transfer_url, transfer)

      assert json_response(conn, 400)
      assert %{"errors" => "insufficient funds"} = json_response(conn, 400)
    end

    test "returns 400 if the user is trying to transfer to themselves", %{
      conn: conn,
      source_user: source_user
    } do
      transfer = %{
        "destination_user_id" => source_user.id,
        "amount" => @initial_balance
      }

      conn = post(conn, @create_transfer_url, transfer)

      assert %{
               "errors" => %{
                 "destination_user_id" => ["can't be the same as the source user"]
               }
             } = json_response(conn, 400)
    end
  end
end
