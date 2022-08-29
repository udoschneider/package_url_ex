defmodule PackageUrl.SwiftPackage do
  @moduledoc """
  PackageUrl sanitization for Swift packages.

  > #### Note {: .neutral}
  >
  > Although not documented in
  > https://github.com/package-url/purl-spec/blob/master/PURL-TYPES.rst#swift it
  > seems that `namespace` and `version` are required attributes!
  """

  use PackageUrl.CustomPackage

  @impl PackageUrl.CustomPackage
  def sanitize_namespace(nil),
    do: {:error, "Invalid purl: :namespace is a required field for Swift packages."}

  def sanitize_namespace(namespace), do: super(namespace)

  @impl PackageUrl.CustomPackage
  def sanitize_version(nil),
    do: {:error, "Invalid purl: :version is a required field for Swift packages."}

  def sanitize_version(version), do: super(version)
end
