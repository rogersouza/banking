defmodule Auth.Encryption do
  @moduledoc """
  Conveniences to encrypt passwords
  """

  alias Comeonin.Bcrypt

  def put_hash(password) do
    Bcrypt.hashpwsalt(password)
  end

  def valid_password?(password, hash) do
    Bcrypt.checkpw(password, hash)
  end
end
