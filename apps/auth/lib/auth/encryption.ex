defmodule Auth.Encryption do
  @moduledoc """
  Conveniences to encrypt passwords
  """

  alias Comeonin.Bcrypt

  def put_hash(password) do
    Bcrypt.hashpwsalt(password)
  end
end
