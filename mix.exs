defmodule Mockingbird.Mixfile do
  use Mix.Project

  @version "0.0.1"
  @url "https://github.com/Driftrock/mockingbird"
  @maintainers [
    "Alessandro Mencarini"
  ]

  def project do
    [
      name: "Mockingbird",
      app: :mockingbird,
      version: @version,
      elixir: "~> 1.4",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      maintainers: @maintainers,
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
      {:httpoison, "~> 0.10.0"},

      # Dev and test deps
      {:mock, "~> 0.2.0", only: :test},
      {:credo, "~> 0.7", only: [:dev, :test]},
      {:dialyxir, "~> 0.5", only: [:dev], runtime: false},
      {:ex_doc, "~> 0.14", only: :dev, runtime: false}
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
      links: %{"GitHub" => @url,
               "Docs" => "http://ericmj.github.io/postgrex/"}
    ]
  end
end
