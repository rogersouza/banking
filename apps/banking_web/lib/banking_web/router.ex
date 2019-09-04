defmodule BankingWeb.Router do
  use BankingWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :authenticated do
    plug BankingWeb.V1.AuthenticationPlug
  end

  scope "/api/v1", BankingWeb, as: :api_v1 do
    pipe_through :api

    resources("/users", V1.UserController, only: [:create])
    post("/auth-token", V1.AuthController, :authenticate)
  end

  scope "/api/v1", BankingWeb, as: :api_v1 do
    pipe_through :api
    pipe_through :authenticated

    get("/wallet", V1.WalletController, :show)
    resources("/withdrawals", V1.WithdrawController, only: [:create])
    resources("/transfers", V1.TransferController, only: [:create])
  end

  scope "/api/backoffice/v1/", BankingWeb, as: :api_v1 do
    pipe_through :api
    pipe_through :authenticated

    get("/reports", V1.ReportController, :show)
  end
end
