defmodule PackageUrl.MixProject do
  use Mix.Project

  def project do
    [
      app: :package_url,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      dialyzer: [flags: [:unmatched_returns, :error_handling, :race_conditions, :no_opaque]],
      docs: [
        main: "PackageUrl",
        extras: ["README.md", "LICENSE"]
      ],
      name: "PackageUrl",
      source_url: "https://github.com/udoschneider/package_url_ex",
      homepage_url: "https://github.com/udoschneider/package_url_ex",
      description: description(),
      package: package()
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
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
      {:jason, "~> 1.3", only: :test},
      {:ex_doc, "~> 0.28.4", only: :dev, runtime: false},
      {:dialyxir, "~> 1.2", only: [:dev], runtime: false}
    ]
  end

  defp description() do
    "A [PackageUrl](https://github.com/package-url/purl-spec) library in pure Elixir."
  end

  defp package() do
    [
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/udoschneider/package_url_ex"}
    ]
  end
end
