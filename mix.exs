defmodule Analyzer.MixProject do
  use Mix.Project

  def project do
    [
      app: :analyzer,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.29", only: :docs},
      {:nimble_options, "~> 0.5"},
      {:ecto, "~> 3.0", optional: true},
      {:explorer, "~> 0.3", optional: true}
    ]
  end

  defp docs do
    [
      main: "Analyzer"
    ]
  end
end
