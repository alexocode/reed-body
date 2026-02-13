defmodule Reed.MixProject do
  use Mix.Project

  def project do
    [
      app: :body,
      version: "0.1.0",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:req, "~> 0.5"},
      {:jose, "~> 1.11"},
      {:earmark, "~> 1.4"},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false}
    ]
  end
end
