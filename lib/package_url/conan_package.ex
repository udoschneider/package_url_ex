defmodule PackageUrl.ConanPackage do
  @moduledoc """
  Conan C/C++ packages.

  See https://github.com/package-url/purl-spec/blob/master/PURL-TYPES.rst#conan

  Examples:
  ```
  pkg:conan/openssl@3.0.3
  pkg:conan/openssl.org/openssl@3.0.3?user=bincrafters&channel=stable
  pkg:conan/openssl.org/openssl@3.0.3?arch=x86_64&build_type=Debug&compiler=Visual%20Studio&compiler.runtime=MDd&compiler.version=16&os=Windows&shared=True&rrev=93a82349c31917d2d674d22065c7a9ef9f380c8e&prev=b429db8a0e324114c25ec387bfd8281f330d7c5c
  ```

  > #### Note {: .neutral}
  >
  > Although not documented in
  > https://github.com/package-url/purl-spec/blob/master/PURL-TYPES.rst#conan it
  > seems that `version`is a required attribute! Also if `namespace` is present
  > `qualifiers.channel` is required and vice versa!
  """

  use PackageUrl.CustomPackage

  @impl PackageUrl.CustomPackage
  def sanitize_version(%{version: nil}),
    do: {:error, "Invalid purl: :version is a required field for Conan packages."}

  def sanitize_version(version), do: super(version)

  @impl PackageUrl.CustomPackage

  def sanitize_aggregate(%PackageUrl{} = purl) do
    with {:ok, %{namespace: namespace, qualifiers: qualifiers} = sanitized} <- super(purl) do
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
           "Invalid purl: `namespace` is a required field for Conan packages with `qualifiers.channel`."}

        {_, nil} ->
          {:error,
           "Invalid purl: `qualifiers.channel` is a required field for Conan packages with `namespace`."}

        {_namespace, _channel} ->
          {:ok, sanitized}
      end
    end
  end
end
