defmodule PackageUrl.HexPackage do
  @moduledoc """
  Elixir Hex packages

  See https://github.com/package-url/purl-spec/blob/master/PURL-TYPES.rst#hex

  Examples:
  ```
  pkg:hex/jason@1.1.2
  pkg:hex/acme/foo@2.3.
  pkg:hex/phoenix_html@2.13.3#priv/static/phoenix_html.js
  pkg:hex/bar@1.2.3?repository_url=https://myrepo.example.com
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
