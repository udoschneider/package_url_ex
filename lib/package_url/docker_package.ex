defmodule PackageUrl.DockerPackage do
  @moduledoc """
   Docker images.

  See https://github.com/package-url/purl-spec/blob/master/PURL-TYPES.rst#docker

  Examples:
  ```
  pkg:docker/cassandra@latest
  pkg:docker/smartentry/debian@dc437cc87d10
  pkg:docker/customer/dockerimage@sha256%3A244fd47e07d10?repository_url=gcr.io
  ```
  """

  use PackageUrl.CustomPackage
end
