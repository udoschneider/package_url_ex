defmodule PackageUrl.PypiPackage do
  use PackageUrl.Package

  @moduledoc """
  Python-based packages:

  - The default repository is `https://pypi.python.org`
  - PyPi treats `-` and `_` as the same character and is not case sensitive.
    Therefore a Pypi package `:name` must be lowercased and underscore `_` replaced with a dash `-`
  - Examples:
    ```
    pkg:pypi/django@1.11.1
    pkg:pypi/django-allauth@12.23
    ```
  """

  @impl PackageUrl.Package
  def sanitize_name(%{name: name} = map) when is_binary(name) do
    sanitized_name = name |> String.downcase() |> String.replace("_", "-")
    {:ok, %{map | name: sanitized_name}}
  end

  def sanitize_name(map), do: super(map)
end
