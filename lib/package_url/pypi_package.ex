defmodule PackageUrl.PypiPackage do
  @moduledoc """
  Python-based packages:

  See https://github.com/package-url/purl-spec/blob/master/PURL-TYPES.rst#pypi

  Examples:
    ```
    pkg:pypi/django@1.11.1
    pkg:pypi/django-allauth@12.23
    ```
  """

  use PackageUrl.CustomPackage

  @impl PackageUrl.CustomPackage
  def sanitize_name(name) when is_binary(name) do
    case super(name) do
      {:ok, name} -> {:ok, name |> String.downcase() |> String.replace("_", "-")}
      {:error, reason} -> {:error, reason}
    end
  end

  def sanitize_name(name), do: super(name)
end
