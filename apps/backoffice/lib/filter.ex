defmodule Backoffice.Filter do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset

  alias Backoffice.FilterValidator

  @fields [:day, :month, :year]

  embedded_schema do
    field :day, :integer
    field :month, :integer
    field :year, :integer
    field :valid_filter_combination?, :boolean
  end

  def changeset(filter, params) do
    filter
    |> cast(params, @fields)
    |> validate_filter_combination()
    |> validate_number(:day, less_than_or_equal_to: 31)
    |> validate_number(:day, greater_than_or_equal_to: 1)
    |> validate_number(:month, less_than_or_equal_to: 12)
    |> validate_number(:month, greater_than_or_equal_to: 1)
    |> validate_number(:year, greater_than_or_equal_to: 1)
  end

  defp validate_filter_combination(changeset) do
    {year, month, day} = date(changeset)

    if FilterValidator.valid_filter_combination?(year, month, day) do
      put_change(changeset, :valid_filter_combination?, true)
    else
      add_error(changeset, :valid_filter_combination?, "invalid filter combination")
    end
  end

  def date(changeset) do
    year = get_field(changeset, :year)
    month = get_field(changeset, :month)
    day = get_field(changeset, :day)

    {year, month, day}
  end
end
