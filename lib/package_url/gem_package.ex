defmodule PackageUrl.GemPackage do
  @moduledoc """
  Rubygems

  See https://github.com/package-url/purl-spec/blob/master/PURL-TYPES.rst#docker

  Examples:
  ```
  pkg:gem/ruby-advisory-db-check@0.12.4
  pkg:gem/jruby-launcher@1.1.2?platform=java
  ```
  """

  use PackageUrl.CustomPackage
end
