defmodule Banking.Money.Type do
  @moduledoc """
  An ecto type to extend Money.Ecto.Amount.Type to cast
  float values
  """

  @behaviour Ecto.Type

  alias Money.Ecto.Amount.Type

  def cast(float) when is_float(float) do
    Money.parse(float)
  end

  def cast(value), do: Type.cast(value)

  def load(value), do: Type.load(value)

  def dump(value), do: Type.dump(value)

  def type, do: :integer
end
