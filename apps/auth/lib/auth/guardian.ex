defmodule Auth.Guardian do
  @moduledoc """
  Conveniences for JWT generation and data retrieval from them
  
  Please check https://github.com/ueberauth/guardian for further information
  """
  use Guardian, otp_app: :auth

  def subject_for_token(%Auth.User{id: id}, claims) do
    sub = to_string(id)
    {:ok, sub}
  end

  def subject_for_token(_, _) do
    {:error, :reason_for_error}
  end

  def resource_from_claims(%{"sub" => id}) do
    resource = Auth.Repo.get(Auth.User, id)
    {:ok, resource}
  end

  def resource_from_claims(_claims) do
    {:error, :sub_key_not_found}
  end
end
