defmodule PackageUrl.PubPackage do
  @moduledoc """
  Dart and Flutter packages

  See https://github.com/package-url/purl-spec/blob/master/PURL-TYPES.rst#pub

  Examples:
  ```
  pkg:pub/characters@1.2.0
  pkg:pub/flutter@0.0.0
  ```
  """

  use PackageUrl.CustomPackage

  @impl PackageUrl.CustomPackage
  def sanitize_name(name) when is_binary(name) do
    case super(name) do
      {:ok, name} ->
        downcase = String.downcase(name)

        if downcase =~ ~r/^[a-z0-9_]+$/,
          do: {:ok, downcase},
          else: {:error, "Invalid purl: name can only contain `[a-z0-9_]`"}

      {:error, reason} ->
        {:error, reason}
    end
  end

  def sanitize_name(name), do: super(name)
end
