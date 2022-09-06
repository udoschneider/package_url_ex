defmodule PackageUrl.DebPackage do
  @moduledoc """
  Debian, Debian derivatives, and Ubuntu packages.

  See https://github.com/package-url/purl-spec/blob/master/PURL-TYPES.rst#deb

  Examples:
  ```
  pkg:deb/debian/curl@7.50.3-1?arch=i386&distro=jessie
  pkg:deb/debian/dpkg@1.19.0.4?arch=amd64&distro=stretch
  pkg:deb/ubuntu/dpkg@1.19.0.4?arch=amd64
  pkg:deb/debian/attr@1:2.4.47-2?arch=source
  pkg:deb/debian/attr@1:2.4.47-2%2Bb1?arch=amd64
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
