defmodule Backoffice.MixProject do
  use Mix.Project

  def project do
    [
      app: :backoffice,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:db, in_umbrella: true},
      # {:banking, in_umbrella: true, only: :test},
      # {:auth, in_umbrella: true, only: :test},
      {:money, "~> 1.4"}
    ]
  end
end
