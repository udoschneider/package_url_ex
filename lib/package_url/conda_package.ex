defmodule PackageUrl.CondaPackage do
  @moduledoc """
  Conda packages

  https://github.com/package-url/purl-spec/blob/master/PURL-TYPES.rst#conda

  Examples:
  ```
  pkg:conda/absl-py@0.4.1?build=py36h06a4308_0&channel=main&subdir=linux-64&type=tar.bz2
  ```
  """

  use PackageUrl.CustomPackage
end
