defmodule PackageUrl.ComposerPackage do
  @moduledoc """
  Composer PHP packages

  https://github.com/package-url/purl-spec/blob/master/PURL-TYPES.rst#composer

  Examples:
  ```
  pkg:composer/laravel/laravel@5.5.0
  ```
  """

  use PackageUrl.CustomPackage
end
