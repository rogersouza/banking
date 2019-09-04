defmodule Backoffice do
  @moduledoc false

  alias Backoffice.Filter
  alias Backoffice.Report
  alias Db.Repo

  @doc """
  Generates a report with the transaction values.

  A Report gives the total of
  - cashout
  - transferred value
  - credits that were given by the banking system (i.e the initial credit)
  - the total transacted (the sum of all previous)

  It can be filtered by day, month and year

  ## Scenarios

  ### Generating a report for a specific day
  For that case, the `day`, `month` and `year` must be given

  Valid filters example:

  ```
  filters = %{day: 10, month: 12, year: 2019}
  {:ok, report} = Backoffice.report(filters)
  ```

  ### Generating a report for an entire month
  For that, one can pass just the year and month

  ```
  filters = %{month: 12, year: 2019}
  {:ok, report} = Backoffice.report(filters)
  ```

  ### Genating a report for an entire year
  Just needs the year

  ```
  filters = %{year: 2019}
  {:ok, report} = Backoffice.report(filters)
  ```

  Besides that, any other filter combination will make
  report/1 return `{:error, :invalid_filter_combination}`

  """
  @spec report(map()) ::
          {:ok, Report.t()} | {:error, :invalid_filter_cobination} | {:error, Ecto.Changeset.t()}
  def report(filters) do
    changeset = Filter.changeset(%Filter{}, filters)

    case changeset do
      %{valid?: true} ->
        report = do_report(changeset)
        {:ok, report}

      %{errors: [valid_filter_combination?: {"invalid filter combination", _}]} ->
        {:error, :invalid_filter_combination}

      changeset ->
        {:error, changeset}
    end
  end

  defp do_report(changeset) do
    changeset
    |> Filter.date()
    |> Report.build()
    |> Repo.all()
    |> Report.into_report_struct()
  end
end
