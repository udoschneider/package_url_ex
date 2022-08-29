defmodule PackageUrl.PypiPackage do
  @moduledoc """
  Python-based packages:

  - The default repository is `https://pypi.python.org`
  - PyPi treats `-` and `_` as the same character and is not case sensitive.
    Therefore a Pypi package `name` must be lowercased and underscore `_`
    replaced with a dash `-`
  - Examples:
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
