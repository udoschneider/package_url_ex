defmodule PackageUrl.SwiftPackage do
  use PackageUrl.Package

  @moduledoc """
  Swift packages:

  - There is no default package repository: this should be implied from `:namespace`
  - The `:namespace` is source host and user/organization.
  - The `:name` is the repository name.
  - The `:version is the package version.`
  - Examples:
  ```
  pkg:swift/github.com/Alamofire/Alamofire@5.4.3
  pkg:swift/github.com/RxSwiftCommunity/RxFlow@2.12.4
  ```

  > #### Note {: .neutral}
  >
  > Although not documented in https://github.com/package-url/purl-spec/blob/master/PURL-TYPES.rst#swift
  > it seems that `:namespace` and `:version are required attributes!
  """

  @impl PackageUrl.Package
  def sanitize_namespace(%{namespace: nil}),
    do: {:error, "Invalid purl: :namespace is a required field for Swift packages."}

  def sanitize_namespace(map), do: super(map)

  @impl PackageUrl.Package
  def sanitize_version(%{version: nil}),
    do: {:error, "Invalid purl: :version is a required field for Swift packages."}

  def sanitize_version(map), do: super(map)
end
