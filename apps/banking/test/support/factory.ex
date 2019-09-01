defmodule Banking.Factory do
  @moduledoc false

  use ExMachina.Ecto, repo: Db.Repo

  def user_factory do
    %Auth.User{
      name: "Jane Doe",
      email: sequence(:email, &"jane-#{&1}@mail.com"),
      password: "somepassword"
    }
  end

  def transaction_factory do
    %Banking.Transaction{}
  end
end
