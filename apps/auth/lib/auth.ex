defmodule Auth do
  alias Auth.{Repo, User}
  
  def register(user_attrs) do
    %User{}
    |> User.changeset(user_attrs)
    |> Repo.insert()
  end
end
