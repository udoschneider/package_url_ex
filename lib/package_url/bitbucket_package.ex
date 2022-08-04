defmodule PackageUrl.BitbucketPackage do
  use PackageUrl.CustomPackage

  @moduledoc """
  Bitbucket-based packages:

  - The default repository is https://bitbucket.org
  - The `namespace` is the user or organization. It is not case sensitive and
    must be lowercased.
  - The `name` is the repository name. It is not case sensitive and must be
    lowercased.
  - The version is a commit or tag
  - Examples:
  ```
  pkg:bitbucket/birkenfeld/pygments-main@244fd47e07d1014f0aed9c
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
