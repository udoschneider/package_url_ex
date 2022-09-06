defmodule PackageUrl.RpmPackage do
  @moduledoc """
  RPMs

  See https://github.com/package-url/purl-spec/blob/master/PURL-TYPES.rst#rpm

  Examples:
  ```
  pkg:rpm/fedora/curl@7.50.3-1.fc25?arch=i386&distro=fedora-25
  pkg:rpm/centerim@4.22.10-1.el6?arch=i686&epoch=1&distro=fedora-25
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
end
