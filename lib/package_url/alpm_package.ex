defmodule PackageUrl.AlpmPackage do
  @moduledoc """
  Arch Linux packages:

  See https://github.com/package-url/purl-spec/blob/master/PURL-TYPES.rst#alpm

  Examples:
  ```elixir
  iex> PackageUrl.new!("pkg:alpm/arch/pacman@6.0.1-1?arch=x86_64")
  %PackageUrl{
    name: "pacman",
    namespace: "arch",
    qualifiers: %{"arch" => "x86_64"},
    scheme: "pkg",
    subpath: nil,
    type: "alpm",
    version: "6.0.1-1"
  }
  iex> PackageUrl.new!("pkg:alpm/arch/python-pip@21.0-1?arch=any")
  %PackageUrl{
    name: "python-pip",
    namespace: "arch",
    qualifiers: %{"arch" => "any"},
    scheme: "pkg",
    subpath: nil,
    type: "alpm",
    version: "21.0-1"
  }
  iex> PackageUrl.new!("pkg:alpm/arch/containers-common@1:0.47.4-4?arch=x86_64")
  %PackageUrl{
    name: "containers-common",
    namespace: "arch",
    qualifiers: %{"arch" => "x86_64"},
    scheme: "pkg",
    subpath: nil,
    type: "alpm",
    version: "1:0.47.4-4"
  }
  ```
  """

  use PackageUrl.CustomPackage

  @impl PackageUrl.CustomPackage
  def sanitize_namespace(namespace) when is_binary(namespace) do
    case super(namespace) do
      {:ok, namespace} -> {:ok, String.downcase(namespace)}
      {:error, reason} -> {:error, reason}
    end
  end

  def sanitize_namespace(namespace), do: super(namespace)

  @impl PackageUrl.CustomPackage
  def sanitize_name(name) when is_binary(name) do
    case super(name) do
      {:ok, name} -> {:ok, String.downcase(name)}
      {:error, reason} -> {:error, reason}
    end
  end

  def sanitize_name(name), do: super(name)
end
