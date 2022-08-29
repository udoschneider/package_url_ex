defmodule PackageUrl.GithubPackage do
  @moduledoc """
  Github-based packages:

  See https://github.com/package-url/purl-spec/blob/master/PURL-TYPES.rst#github

  Examples:
  ```
  pkg:github/package-url/purl-spec@244fd47e07d1004
  pkg:github/package-url/purl-spec@244fd47e07d1004#everybody/loves/dogs
  ```
  """

  use PackageUrl.CustomPackage

  @impl PackageUrl.CustomPackage
  def sanitize_namespace(namespace) when is_binary(namespace) do
    case super(namespace) do
      {:ok, namespace} -> {:ok, String.downcase(namespace)}
      {:error, reason} -> {:error, reason}
    end
  end

  def sanitize_namespace(namespace), do: super(namespace)

  @impl PackageUrl.CustomPackage
  def sanitize_name(name) when is_binary(name) do
    case super(name) do
      {:ok, name} -> {:ok, String.downcase(name)}
      {:error, reason} -> {:error, reason}
    end
  end

  def sanitize_name(name), do: super(name)
end
