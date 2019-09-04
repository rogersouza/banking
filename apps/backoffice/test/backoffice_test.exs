defmodule BackofficeTest do
  use Backoffice.DataCase

  describe "report/1 filter validation using" do
    test "day, month and year as filter is a valid combination and will filter by day" do
      filters = %{
        "day" => 1,
        "month" => 1,
        "year" => 2019
      }

      assert {:ok, _report} = Backoffice.report(filters)
    end

    test "day and month as filters is a invalid filter combination" do
      filters = %{
        "day" => 1,
        "month" => 12
      }

      assert {:error, :invalid_filter_combination} = Backoffice.report(filters)
    end

    test "month and year as filters is a valid filter combination and will filter by month" do
      filters = %{
        "year" => 2019,
        "month" => 1
      }

      assert {:ok, _report} = Backoffice.report(filters)
    end

    test "month and day as filters is a invalid filter combination" do
      filters = %{
        "month" => 12,
        "day" => 1
      }

      assert {:error, :invalid_filter_combination} = Backoffice.report(filters)
    end
  end
end
