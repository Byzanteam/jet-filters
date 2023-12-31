defmodule JetFilters.MixProject do
  use Mix.Project

  def project do
    [
      app: :jet_filters,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      dialyzer: [
        plt_file: {:no_warn, "priv/plts/project.plt"}
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:jet_credo, [github: "Byzanteam/jet_credo", only: [:dev, :test], runtime: false]},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:ecto, "~> 3.10"}
    ]
  end
end
