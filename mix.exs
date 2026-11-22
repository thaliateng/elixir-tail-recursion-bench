defmodule ElixirTailRecursionBench.MixProject do
  use Mix.Project

  def project do
    [
      app: :elixir_tail_recursion_bench,
      version: "0.1.0",
      # Benchee measures memory incorrectly on Elixir 1.14 up to 1.16.0-rc.0.
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases()
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [
      {:benchee, "~> 1.3", only: [:dev, :bench]},
      {:benchee_csv, "~> 1.0", only: [:dev, :bench]},
      {:benchee_json, "~> 1.0", only: [:dev, :bench]}
    ]
  end

  defp aliases do
    [
      bench: ["run bench/run_all.exs"]
    ]
  end
end
