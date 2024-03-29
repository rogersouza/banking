defmodule AuthTest do
  use Auth.DataCase

  alias Auth.Guardian

  import Auth.Factory

  @user_fixture build(:user)
  @invalid_email_user_fixture build(:user, email: "invalid.com")

  describe "register/1" do
    test "creates a new user" do
      assert {:ok, user} = Auth.register(@user_fixture)
    end

    test "rejects duplicated emails" do
      {:ok, _user} = Auth.register(@user_fixture)
      {:error, changeset} = Auth.register(@user_fixture)
      assert "has already been taken" in errors_on(changeset).email
    end

    test "hashs the password" do
      {:ok, user} = Auth.register(@user_fixture)
      plain_text_password = @user_fixture["password"]
      refute user.password == plain_text_password
    end

    test "rejects invalid emails" do
      {:error, changeset} = Auth.register(@invalid_email_user_fixture)
      assert "has invalid format" in errors_on(changeset).email
    end
  end

  describe "sign_in/1" do
    setup do
      {:ok, _user} = Auth.register(@user_fixture)
      :ok
    end

    test "returns a token" do
      credentials = %{
        "email" => @user_fixture.email,
        "password" => @user_fixture.password
      }

      assert {:ok, token} = Auth.sign_in(credentials)
      assert {:ok, _claims} = Guardian.decode_and_verify(token)
    end

    test "returns {:error, :unauthorized} when the credentials are invalid" do
      credentials = %{
        "email" => @user_fixture.email,
        "password" => "wrongpassword"
      }

      assert {:error, :unauthorized} = Auth.sign_in(credentials)
    end
  end
end
