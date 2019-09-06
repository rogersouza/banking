defmodule Banking.Umbrella.MixProject do
  use Mix.Project

  def project do
    [
      version: "0.0.1",
      apps_path: "apps",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      releases: releases()
    ]
  end

  defp releases do
    [
      api: [
        include_erts: true,
        include_executables_for: [:unix],
        applications: [
          banking_web: :permanent
        ]
      ]
    ]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options.
  #
  # Dependencies listed here are available only for this project
  # and cannot be accessed from applications inside the apps folder
  defp deps do
    [
      {:credo, "~> 1.1.0", only: [:dev, :test], runtime: false}
    ]
  end
end
