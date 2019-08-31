defmodule Auth.Factory do
  use ExMachina.Ecto, repo: Auth.Repo

  def user_factory do
    %{
      name: "Jane Doe",
      email: sequence(:email, &"jane-#{&1}@mail.com"),
      password: sequence(:password, &"#{&1}#{&1+1}#{&1+2}")
    }
  end
end
