defmodule Papelillo.MixProject do
  use Mix.Project

  def project do
    [
      app: :papelillo,
      version: "0.1.1-beta.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      name: "Papelillo",
      description: description(),
      package: package(),
      test_coverage: [tool: ExCoveralls],
      docs: [
        main: "readme",
        extras: ["README.md", "CHANGELOG.md", "LICENSE", "docs/*"]
      ],
      source_url: "https://github.com/wois-org/papelillo"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp description() do
    "Mailing Lists managment"
  end

  defp package() do
    [
      name: "papelillo",
      files: ~w(lib .formatter.exs mix.exs README* LICENSE CHANGELOG*),
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/wois-org/papelillo"}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:httpoison, "~> 1.8"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:credo, "~> 1.4", only: [:dev, :test], runtime: false},
      {:excoveralls, "0.14.4", only: :test},
      {:version_release, "0.2.0", only: [:test, :dev], runtime: false},
      {:mox, "~> 1.0", only: :test}
    ]
  end
end
