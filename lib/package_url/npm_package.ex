defmodule PackageUrl.NpmPackage do
  @moduledoc """
  Node NPM packages

  See https://github.com/package-url/purl-spec/blob/master/PURL-TYPES.rst#npm

  Examples:
  ```
  pkg:npm/foobar@12.3.1
  pkg:npm/%40angular/animation@12.3.1
  pkg:npm/mypackage@12.4.5?vcs_url=git://host.com/path/to/repo.git%404345abcd34343
  ```
  """

  use PackageUrl.CustomPackage
end
