defmodule PackageUrl.HackagePackage do
  @moduledoc """
  Haskell packages

  See https://github.com/package-url/purl-spec/blob/master/PURL-TYPES.rst#hackage

  Examples:
  ```
  pkg:hackage/a50@0.5
  pkg:hackage/AC-HalfInteger@1.2.1
  pkg:hackage/3d-graphics-examples@0.0.0.2
  ```
  """

  use PackageUrl.CustomPackage
end
