defmodule Auth do
  @moduledoc """
  Authentication conveniences

  You can use register/1 to create new users and sign_in/1 to authenticate them
  """
  alias Auth.{Repo, User, Encryption}

  import Ecto.Changeset

  @doc """
  Register a new user

  ## Example
  ```
  user = %{"name" => "User Name", "email" => email, "password" => "pwd123"}
  {:ok, _new_user} = Auth.register(user)
  ```
  """
  @spec register(map()) :: {:ok, User.t()} | {:error, Ecto.Chageset.t()}
  def register(user_attrs) do
    %User{}
    |> User.changeset(user_attrs)
    |> Repo.insert()
  end

  @doc """
  Returns an authentication token if the credentials are valid

  ## Usage
  credentials = %{"email" => "mail@mail.com", "password" => "123456"}
  case Auth.sign_in(credentials) do
    {:ok, token} -> # Credentials are valid
    {:error, :unauthorized} -> # Invalid password/email
    {:error, changeset} -> # Malformed credentials
  end
  """
  @spec sign_in(map()) ::
          {:ok, String.t()} | {:error, Ecto.Changeset.t()} | {:error, :unauthorized}
  def sign_in(credentials) do
    changeset = User.credentials_changeset(%User{}, credentials)
    email = get_field(changeset, :email)
    password = get_field(changeset, :password)

    with %{valid?: true} <- changeset,
         user when user != nil <- Repo.get_by(User, email: email),
         true <- Encryption.valid_password?(password, user.password) do
      {:ok, token, _claims} = Auth.Guardian.encode_and_sign(user, %{})
      {:ok, token}
    else
      %{valid?: false} -> {:error, changeset}
      _any_other_case -> {:error, :unauthorized}
    end
  end
end
