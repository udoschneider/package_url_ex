defmodule PackageUrl.GolangPackage do
  @moduledoc """
  Go packages

  See https://github.com/package-url/purl-spec/blob/master/PURL-TYPES.rst#golang

  Examples:
  ```
  pkg:golang/github.com/gorilla/context@234fd47e07d1004f0aed9c
  pkg:golang/google.golang.org/genproto#googleapis/api/annotations
  pkg:golang/github.com/gorilla/context@234fd47e07d1004f0aed9c#api
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
