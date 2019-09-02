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
      {:ok, destination_user} = Auth.register(@dest_user_attrs)

      {:ok, token} = Auth.sign_in(@source_user_attrs)

      {:ok, _} = Banking.credit(source_user.id, @initial_balance)

      %{
        destination_user: destination_user,
        conn: put_req_header(conn, "authorization", "Bearer #{token}")
      }
    end

    test "retuns 201 for successfully transfers", %{
      conn: conn,
      destination_user: destination_user
    } do
      transfer = %{
        "destination_user_id" => destination_user.id,
        "amount" => @initial_balance
      }

      conn = post(conn, @create_transfer_url, transfer)
      assert json_response(conn, 201)
    end
  end
end
