defmodule PackageUrl.GenericPackage do
  @moduledoc """
  Generic packages

  `generic` for plain, generic packages that do not fit anywhere else such as for "upstream-from-distro" packages. In particular this is handy for a plain version control repository such as a bare git repo.
  * There is no default repository. A `download_url` and `checksum` may be provided in qualifiers or as separate attributes outside of a `purl` for proper identification and location.
  * When possible another or a new `purl` type should be used instead of using the `generic` type and eventually contributed back to this specification
  * as for other `type`, the name component is mandatory. In the worst case it can be a file or directory name.

  Examples (truncated for brevity):
  ```
  pkg:generic/openssl@1.1.10g
  pkg:generic/openssl@1.1.10g?download_url=https://openssl.org/source/openssl-1.1.0g.tar.gz&checksum=sha256:de4d501267da
  pkg:generic/bitwarderl?vcs_url=git%2Bhttps://git.fsfe.org/dxtr/bitwarderl%40cc55108da32
  ```
  """

  use PackageUrl.CustomPackage
end
