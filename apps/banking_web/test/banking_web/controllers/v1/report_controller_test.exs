defmodule BankingWeb.V1.ReportControllerTest do
  use BankingWeb.ConnCase

  import BankingWeb.Factory

  @user_fixture build(:user)
  @money_amount Application.get_env(:banking, :initial_balance)

  describe "show/2" do
    setup %{conn: conn} do
      {:ok, user} = Auth.register(@user_fixture)
      {:ok, _} = Banking.credit(user.id, @money_amount)

      {:ok, token} = Auth.sign_in(@user_fixture)
      conn = put_req_header(conn, "authorization", "Bearer #{token}")

      %{user: user, conn: conn}
    end

    test "returns 404 for invalid filters", %{conn: conn} do
      filters = [year: 2019, day: 20]
      report_url = Routes.api_v1_report_path(conn, :show, filters)

      conn = get(conn, report_url)
      assert json_response(conn, 404)
    end

    test "returns 200 for valid filters", %{conn: conn} do
      filters = [year: 2019, month: 12, day: 1]
      report_url = Routes.api_v1_report_path(conn, :show, filters)

      conn = get(conn, report_url)
      assert json_response(conn, 200)
    end

    test "returns 400 for invalid date", %{conn: conn} do
      filters = [year: 2019, month: 13, day: 1]
      report_url = Routes.api_v1_report_path(conn, :show, filters)

      conn = get(conn, report_url)
      assert json_response(conn, 404)
    end
  end
end
