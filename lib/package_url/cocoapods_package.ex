defmodule PackageUrl.CocoapodsPackage do
  @moduledoc """
  Cocoapods packages:

  See https://github.com/package-url/purl-spec/blob/master/PURL-TYPES.rst#cocoapods

  Examples:
    ```
  pkg:cocoapods/AFNetworking@4.0.1
  pkg:cocoapods/MapsIndoors@3.24.0
  pkg:cocoapods/ShareKit@2.0#Twitter
  pkg:cocoapods/GoogleUtilities@7.5.2#NSData+zlib
    ```
  """

  use PackageUrl.CustomPackage

  @impl PackageUrl.CustomPackage
  def sanitize_name(name) when is_binary(name) do
    case super(name) do
      {:ok, name} ->
        cond do
          name =~ ~r/\..*/ ->
            {:error, "Invalid purl: name cannot cannot begin with a period"}

          name =~ ~r/[\s\+]/ ->
            {:error, "Invalid purl: cannot contain whitespace, a plus (+) character"}

          true ->
            {:ok, name}
        end

      {:error, reason} ->
        {:error, reason}
    end
  end

  def sanitize_name(name), do: super(name)
end
