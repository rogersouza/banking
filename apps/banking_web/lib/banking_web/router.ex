defmodule BankingWeb.Router do
  use BankingWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api/v1", BankingWeb, as: :api_v1 do
    pipe_through :api

    resources("/users", V1.UserController, only: [:create])
  end

  scope "/api/v1", BankingWeb, as: :api_v1 do
    pipe_through :api
    
    post("/auth-token", V1.AuthController, :authenticate)
  end
end
