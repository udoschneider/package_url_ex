defmodule PackageUrl.CargoPackage do
  @moduledoc """
  Rust packages

  https://github.com/package-url/purl-spec/blob/master/PURL-TYPES.rst#cargo

  Examples:
  ```
  pkg:cargo/rand@0.7.2
  pkg:cargo/clap@2.33.0
  pkg:cargo/structopt@0.3.11
  ```
  """

  use PackageUrl.CustomPackage
end
