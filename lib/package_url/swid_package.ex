defmodule PackageUrl.SwidPackage do
  @moduledoc """
  ISO-IEC 19770-2 Software Identification (SWID) tags

  See https://github.com/package-url/purl-spec/blob/master/PURL-TYPES.rst#swid

  Examples:
  ```
  pkg:swid/Acme/example.com/Enterprise+Server@1.0.0?tag_id=75b8c285-fa7b-485b-b199-4745e3004d0d
  pkg:swid/Fedora@29?tag_id=org.fedoraproject.Fedora-29
  pkg:swid/Adobe+Systems+Incorporated/Adobe+InDesign@CC?tag_id=CreativeCloud-CS6-Win-GM-MUL
  ```
  """

  use PackageUrl.CustomPackage
end
