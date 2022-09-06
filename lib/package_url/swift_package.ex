defmodule PackageUrl.SwiftPackage do
  @moduledoc """
  Swift packages.

  See https://github.com/package-url/purl-spec/blob/master/PURL-TYPES.rst#swift

  Examples:
  ```
  pkg:swift/github.com/Alamofire/Alamofire@5.4.3
  pkg:swift/github.com/RxSwiftCommunity/RxFlow@2.12.4
  ```
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
