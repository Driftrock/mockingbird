defmodule Mockingbird.Mixfile do
  use Mix.Project

  @version "0.2.0"
  @url "https://github.com/Driftrock/mockingbird"
  @maintainers [
    "Alessandro Mencarini",
    "Lukáš Doležal",
    "Dan Watts"
  ]

  def project do
    [
      name: "Mockingbird",
      app: :mockingbird,
      version: @version,
      elixir: "~> 1.4",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps()
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [
      {:httpoison, "~> 1.0"},

      # Dev and test deps
      {:mock, "~> 0.3.1", only: :test},
      {:credo, "~> 0.9", only: [:dev, :test]},
      {:dialyxir, "~> 0.5", only: [:dev], runtime: false},
      {:ex_doc, "~> 0.18", only: :dev, runtime: false},
      {:inch_ex, ">= 0.0.0", only: :docs}
    ]
  end

  defp description do
    "Mockingbird helps you create API consumers that are easy to test."
  end

  defp package do
    [
      name: :mockingbird,
      files: ["lib", "mix.exs", "README.md", "LICENSE"],
      maintainers: @maintainers,
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => @url, "Docs" => "https://hexdocs.pm/mockingbird/"}
    ]
  end
end
