defmodule Backoffice.FilterValidator do
  @moduledoc false

  def valid_filter_combination?(year, month, day) do
    do_valid_filter_combination?(year, month, day)
  end

  # just the year is given
  defp do_valid_filter_combination?(year, nil, nil) when year != nil do
    true
  end

  # day, month and year are given
  defp do_valid_filter_combination?(year, month, day)
       when year != nil and month != nil and day != nil do
    true
  end

  # year and month are given
  defp do_valid_filter_combination?(year, month, nil) when year != nil and month != nil do
    true
  end

  # other cases like day-month and day-year are invalid
  defp do_valid_filter_combination?(_, _, _), do: false
end
