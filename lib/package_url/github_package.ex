defmodule PackageUrl.GithubPackage do
  use PackageUrl.CustomPackage

  @moduledoc """
  Github-based packages:

  - The default repository is `https://github.com`
  - The `namespace` is the user or organization. It is not case sensitive and
    must be lowercased.
  - The `name` is the repository name. It is not case sensitive and must be
    lowercased.
  - The version is a commit or tag
  - Examples:
  ```
  pkg:github/package-url/purl-spec@244fd47e07d1004
  pkg:github/package-url/purl-spec@244fd47e07d1004#everybody/loves/dogs
  ```
  """

  @impl PackageUrl.CustomPackage
  def sanitize_namespace(namespace) when is_binary(namespace) do
    with {:ok, namespace} <- super(namespace) do
      {:ok, String.downcase(namespace)}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  def sanitize_namespace(namespace), do: super(namespace)

  @impl PackageUrl.CustomPackage
  def sanitize_name(name) when is_binary(name) do
    with {:ok, name} <- super(name) do
      {:ok, String.downcase(name)}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  def sanitize_name(name), do: super(name)
end
