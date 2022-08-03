defmodule PackageUrl.ConanPackage do
  use PackageUrl.Package

  @moduledoc """
  Conan C/C++ packages.
  The purl is designed to closely resemble the Conan-native <package-name>/<package-version>@<user>/<channel> syntax for package references.

  - `:name`: The Conan `<package-name>`.
  - `:version`: The Conan `<package-version>`.
  - `:namespace`: The vendor of the package.
  - `:qualifier.user`: The Conan `<user>`. Only required if the Conan package was published with `<user>`.
  - `:qualifier.channel`: The Conan `<channel>`. Only required if the Conan package was published with Conan `<channel>`.
  - `:qualifier.rrev`: The Conan recipe revision (optional). If omitted, the purl refers to the latest recipe revision available for the given version.
  - `:ualifier.prev`: The Conan package revision (optional). If omitted, the purl refers to the latest package revision available for the given version and recipe revision.
  - `:qualifier.repository_url`: The Conan repository where the package is available (optional). If ommitted, https://center.conan.io as default repository is assumed.

  Additional qualifiers can be used to distinguish Conan packages with different settings or options, e.g. os=Linux, build_type=Debug or shared=True.

  If no additional qualifiers are used to distinguish Conan packages build with different settings or options, then the purl is ambiguous and it is up to the user to work out which package is being referred to (e.g. with context information).

  Examples:
  ```
  pkg:conan/openssl@3.0.3
  pkg:conan/openssl.org/openssl@3.0.3?user=bincrafters&channel=stable
  pkg:conan/openssl.org/openssl@3.0.3?arch=x86_64&build_type=Debug&compiler=Visual%20Studio&compiler.runtime=MDd&compiler.version=16&os=Win
  ```

  > #### Note {: .neutral}
  >
  > Although not documented in https://github.com/package-url/purl-spec/blob/master/PURL-TYPES.rst#cran
  > it seems that `:namespace`, `:version` and `:qualifiers.channel` are required attributes!
  """

  # @impl PackageUrl.Package
  # def sanitize_namespace(%{namespace: nil}),
  #   do: {:error, "Invalid purl: :namespace is a required field for CRAN packages."}

  # def sanitize_namespace(map), do: super(map)

  @impl PackageUrl.Package
  def sanitize_version(%{version: nil}),
    do: {:error, "Invalid purl: :version is a required field for Conan packages."}

  def sanitize_version(map), do: super(map)

  @impl PackageUrl.Package

  def sanitize_aggregate(map) do
    with {:ok, %{namespace: namespace, qualifiers: qualifiers} = sanitized} <- super(map) do
      channel =
        case qualifiers do
          nil ->
            nil

          qualifiers ->
            case Map.fetch(qualifiers, "channel") do
              {:ok, value} -> value
              :error -> nil
            end
        end

      case {namespace, channel} do
        {nil, nil} ->
          {:ok, sanitized}

        {nil, _channel} ->
          {:error,
           "Invalid purl: `:namespace` is a required field for Conan packages with `:qualifiers.channel`."}

        {_, nil} ->
          {:error,
           "Invalid purl: `:qualifiers.channel` is a required field for Conan packages with `:namespace`."}

        {_namespace, _channel} ->
          {:ok, sanitized}
      end
    else
      {:error, reason} ->
        {:error, reason}
    end
  end
end
