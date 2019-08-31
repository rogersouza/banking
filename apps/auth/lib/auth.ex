defmodule Auth do
  alias Auth.{Repo, User}

  @doc """
  Register a new user

  ## Example
  ```
  user = %{"name" => "User Name", "email" => email}
  {:ok, _new_user} = Auth.register(user)
  ```
  """
  @spec register(map()) :: {:ok, User.t()} | {:error, Ecto.Chageset.t()}
  def register(user_attrs) do
    %User{}
    |> User.changeset(user_attrs)
    |> Repo.insert()
  end
end
