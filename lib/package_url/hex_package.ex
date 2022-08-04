defmodule PackageUrl.HexPackage do
  use PackageUrl.CustomPackage

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
