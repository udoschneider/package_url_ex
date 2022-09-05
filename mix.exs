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
      package: package(),
      elixirc_paths: compiler_paths(Mix.env())
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
      {:jason, "~> 1.3"},
      {:ex_check, "~> 0.14.0", only: [:dev], runtime: false},
      {:credo, ">= 0.0.0", only: [:dev], runtime: false},
      {:dialyxir, ">= 0.0.0", only: [:dev], runtime: false},
      {:doctor, ">= 0.0.0", only: [:dev], runtime: false},
      {:ex_doc, ">= 0.0.0", only: [:dev], runtime: false}
      # {:sobelow, ">= 0.0.0", only: [:dev], runtime: false}
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

  def compiler_paths(:test), do: ["test/helpers"] ++ compiler_paths(:prod)
  def compiler_paths(_), do: ["lib"]
end
