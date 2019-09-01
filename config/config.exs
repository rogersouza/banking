# This file is responsible for configuring your umbrella
# and **all applications** and their dependencies with the
# help of Mix.Config.
#
# Note that all applications in your umbrella share the
# same configuration and dependencies, which is why they
# all use the same configuration file. If you want different
# configurations or dependencies per app, it is best to
# move said applications out of the umbrella.
import Config

# Configure Mix tasks and generators
config :auth,
  ecto_repos: [Auth.Repo]

# Configure Mix tasks and generators
config :banking,
  ecto_repos: [Banking.Repo]

config :banking_web,
  ecto_repos: [Banking.Repo],
  generators: [context_app: :banking]

# Configures the endpoint
config :banking_web, BankingWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "PY3IzudNRWBoyTOD6v/xJvJjKHUwe3OPHYQJLzGHo25vS81m4awJUJKrUX+MtxRO",
  render_errors: [view: BankingWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: BankingWeb.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :comeonin, :bcrypt_log_rounds, 4

config :auth, Auth.Guardian,
  issuer: "auth",
  secret_key: "Wbt2v7c7NEAKZ2PPHkzFJdX8HTi+JpOLE90Pvo2zFSlTe7ZmwV+j6IuAzP59Tp7A"

config :money,
  default_currency: :BRL,
  separator: ".",
  delimeter: ",",
  symbol: false,
  symbol_on_right: false,
  symbol_space: false

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
