defmodule PackageUrl.GenericPackage do
  @moduledoc """
  Generic packages

  See https://github.com/package-url/purl-spec/blob/master/PURL-TYPES.rst#generic

  Examples (truncated for brevity):
  ```
  pkg:generic/openssl@1.1.10g
  pkg:generic/openssl@1.1.10g?download_url=https://openssl.org/source/openssl-1.1.0g.tar.gz&checksum=sha256:de4d501267da
  pkg:generic/bitwarderl?vcs_url=git%2Bhttps://git.fsfe.org/dxtr/bitwarderl%40cc55108da32
  ```
  """

  use PackageUrl.CustomPackage
end
