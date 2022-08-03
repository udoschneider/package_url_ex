defmodule PackageUrl.GithubPackage do
  use PackageUrl.Package

  @moduledoc """
  Github-based packages:

  - The default repository is `https://github.com`
  - The `:namespace` is the user or organization. It is not case sensitive and must be lowercased.
  - The `:name` is the repository name. It is not case sensitive and must be lowercased.
  - The version is a commit or tag
  - Examples:
  ```
  pkg:github/package-url/purl-spec@244fd47e07d1004
  pkg:github/package-url/purl-spec@244fd47e07d1004#everybody/loves/dogs
  ```
  """

  @impl PackageUrl.Package
  def sanitize_namespace(%{namespace: namespace} = map) when is_binary(namespace) do
    {:ok, %{map | namespace: String.downcase(namespace)}}
  end

  def sanitize_namespace(map), do: super(map)

  @impl PackageUrl.Package
  def sanitize_name(%{name: name} = map) when is_binary(name) do
    {:ok, %{map | name: String.downcase(name)}}
  end

  def sanitize_name(map), do: super(map)
end
