defmodule PackageUrl.OciPackage do
  @moduledoc """
  Artifacts stored in registries that conform to the [OCI Distribution Specification](https://github.com/opencontainers/distribution-spec)

  See https://github.com/package-url/purl-spec/blob/master/PURL-TYPES.rst#oci

  Examples:
  ```
  pkg:oci/debian@sha256%3A244fd47e07d10?repository_url=docker.io/library/debian&arch=amd64&tag=latest
  pkg:oci/debian@sha256%3A244fd47e07d10?repository_url=ghcr.io/debian&tag=bullseye
  pkg:oci/static@sha256%3A244fd47e07d10?repository_url=gcr.io/distroless/static&tag=latest
  pkg:oci/hello-wasm@sha256%3A244fd47e07d10?tag=v1
  ```
  """

  use PackageUrl.CustomPackage

  @impl PackageUrl.CustomPackage
  def sanitize_name(name) when is_binary(name) do
    case super(name) do
      {:ok, name} -> {:ok, downcase_name(name)}
      {:error, reason} -> {:error, reason}
    end
  end

  def sanitize_name(name), do: super(name)

  @impl PackageUrl.CustomPackage
  def sanitize_qualifiers(%{} = qualifiers) do
    case super(qualifiers) do
      {:ok, qualifiers} when qualifiers != nil -> {:ok, downcase_qualifiers(qualifiers)}
      o -> o
    end
  end

  def sanitize_qualifiers(qualifiers), do: super(qualifiers)

  defp downcase_name(repository_path) do
    [name | path] = repository_path |> String.split("/") |> Enum.reverse()
    [String.downcase(name) | path] |> Enum.reverse() |> Enum.join("/")
  end

  defp downcase_qualifiers(qualifiers) do
    qualifiers
    |> Enum.map(fn
      {"repository_url", path} -> {"repository_url", downcase_name(path)}
      o -> o
    end)
    |> Enum.into(%{})
  end
end
