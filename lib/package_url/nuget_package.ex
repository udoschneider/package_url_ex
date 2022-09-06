defmodule PackageUrl.NugetPackage do
  @moduledoc """
  NuGet .NET packages

  See https://github.com/package-url/purl-spec/blob/master/PURL-TYPES.rst#nuget

  Examples:
  ```
  pkg:nuget/EnterpriseLibrary.Common@6.0.1304
  ```
  """

  use PackageUrl.CustomPackage
end
