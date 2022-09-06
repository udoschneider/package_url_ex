defmodule PackageUrl.CranPackage do
  @moduledoc """
  CRAN R packages

  See https://github.com/package-url/purl-spec/blob/master/PURL-TYPES.rst#cran

  Examples:
  ```
  pkg:cran/A3@1.0.0
  pkg:cran/rJava@1.0-4
  pkg:cran/caret@6.0-88
  ```

  > #### Note {: .neutral}
  >
  > Although not documented in
  > https://github.com/package-url/purl-spec/blob/master/PURL-TYPES.rst#cran it
  > seems that `version` is a requiredattributes!
  """

  use PackageUrl.CustomPackage

  @impl PackageUrl.CustomPackage
  def sanitize_version(nil),
    do: {:error, "Invalid purl: :version is a required field for CRAN packages."}

  def sanitize_version(version), do: super(version)
end
