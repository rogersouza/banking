use Mix.Config

database_url =
  System.get_env("DATABASE_URL") ||
  "ecto://postgres:postgres@localhost/banking_dev"

# Configure your database
config :db, Db.Repo,
  url: database_url,
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :banking_web, BankingWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn
