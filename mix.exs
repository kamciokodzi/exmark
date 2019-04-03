defmodule ExMark.MixProject do
  use Mix.Project

  def project do
    [
      app: :exmark,
      config_path: "config/config.exs",
      deps: deps(),
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      version: "0.1.0"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {ExMark.Application, []},
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:hackney, "~> 1.14.0"},
      {:jason, "~> 1.1"},
      {:tesla, "~> 1.2.1"}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
    ]
  end
end
