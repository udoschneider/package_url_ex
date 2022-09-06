defmodule PackageUrl.MavenPackage do
  @moduledoc """
  Maven JARs and related artifacts

  https://github.com/package-url/purl-spec/blob/master/PURL-TYPES.rst#maven

  Examples:
  ```
  pkg:maven/org.apache.xmlgraphics/batik-anim@1.9.1
  pkg:maven/org.apache.xmlgraphics/batik-anim@1.9.1?type=pom
  pkg:maven/org.apache.xmlgraphics/batik-anim@1.9.1?classifier=sources
  pkg:maven/org.apache.xmlgraphics/batik-anim@1.9.1?type=zip&classifier=dist
  pkg:maven/net.sf.jacob-projec/jacob@1.14.3?classifier=x86&type=dll
  pkg:maven/net.sf.jacob-projec/jacob@1.14.3?classifier=x64&type=dll
  ```
  """

  use PackageUrl.CustomPackage
end
