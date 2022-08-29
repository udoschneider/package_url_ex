defmodule PackageUrl.HexPackage do
  @moduledoc """
  Hex packages

  - The default repository is https://repo.hex.pm.
  - The `namespace` is optional; it may be used to specify the organization for private packages on hex.pm. It is not case sensitive and must be lowercased.
  - The `name` is not case sensitive and must be lowercased.

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
