defmodule PackageUrl.BitbucketPackage do
  @moduledoc """
  Bitbucket-based packages.

  See https://github.com/package-url/purl-spec/blob/master/PURL-TYPES.rst#bitbucket

  Examples:
  ```
  pkg:bitbucket/birkenfeld/pygments-main@244fd47e07d1014f0aed9c
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
