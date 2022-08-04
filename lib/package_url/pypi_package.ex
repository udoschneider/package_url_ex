defmodule PackageUrl.PypiPackage do
  use PackageUrl.CustomPackage

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

  @impl PackageUrl.CustomPackage
  def sanitize_name(name) when is_binary(name) do
    with {:ok, name} <- super(name) do
      {:ok, name |> String.downcase() |> String.replace("_", "-")}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  def sanitize_name(name), do: super(name)
end
