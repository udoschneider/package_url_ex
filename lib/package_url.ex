defmodule PackageUrl do
  @moduledoc File.read!("README.md")
             |> String.split("<!-- MODULEDOC -->")
             |> Enum.fetch!(1)

  import Kernel, except: [to_string: 1]

  defstruct scheme: "pkg",
            type: nil,
            namespace: nil,
            name: nil,
            version: nil,
            qualifiers: nil,
            subpath: nil

  @type t :: %__MODULE__{
          scheme: binary() | nil,
          type: binary() | nil,
          namespace: binary() | nil,
          name: binary() | nil,
          version: binary() | nil,
          qualifiers: %{optional(binary()) => binary() | map() | nil} | nil,
          subpath: binary() | nil
        }

  @doc """
  Parses a PackageUrl into its components.

  This function accepts binaries as well as keyword lists and maps. Returns an
  `{:ok, result}` tuple on success. Returns an `{:error, reason}` tuple if
  parsing fails. Please note that this does not validate components and allows
  you to parse "invalid" purls.

  ## Examples

  ```elixir
  iex> PackageUrl.parse("pkg:maven/org.apache.commons/io@1.3.4")
  {:ok,
  %PackageUrl{
    name: "io",
    namespace: "org.apache.commons",
    qualifiers: nil,
    scheme: "pkg",
    subpath: nil,
    type: "maven",
    version: "1.3.4"
  }}
  iex> PackageUrl.parse("pkg:maven/@1.3.4")
  {:ok,
  %PackageUrl{
    name: nil,
    namespace: nil,
    qualifiers: nil,
    scheme: "pkg",
    subpath: nil,
    type: "maven",
    version: "1.3.4"
  }}
  ```
  """
  @spec parse(binary | maybe_improper_list | map) :: {:ok, t()} | {:error, any}
  def parse(purl) when is_binary(purl) do
    case parse_purl(purl) do
      {:ok, map} -> parse(map)
      {:error, reason} -> {:error, reason}
    end
  end

  def parse(purl) when is_list(purl) do
    purl
    |> Enum.into(%{})
    |> parse()
  end

  def parse(purl) when is_map(purl) do
    with {:ok, merged} <- merge_defaults(purl),
         map <- Map.from_struct(merged),
         purl <- struct(PackageUrl, map) do
      {:ok, purl}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Parses and validates a PackageUrl into its components.

  This function accepts binaries as well as keyword lists and maps. Please note
  that this does not validate components and allows you to parse "invalid"
  purls.

  ## Examples

  ```elixir
  iex> PackageUrl.parse!("pkg:maven/org.apache.commons/io@1.3.4")
  %PackageUrl{
    name: "io",
    namespace: "org.apache.commons",
    qualifiers: nil,
    scheme: "pkg",
    subpath: nil,
    type: "maven",
    version: "1.3.4"
  }
  iex> PackageUrl.parse!("pkg:maven/@1.3.4")
  %PackageUrl{
    name: nil,
    namespace: nil,
    qualifiers: nil,
    scheme: "pkg",
    subpath: nil,
    type: "maven",
    version: "1.3.4"
  }
  ```
  """
  @spec parse!(binary | maybe_improper_list | map) :: t()
  def parse!(purl) do
    case parse(purl) do
      {:ok, purl} -> purl
      {:error, reason} -> raise(ArgumentError, reason)
    end
  end

  @doc """
  Parses and validates a PackageUrl into its components.

  This function accepts binaries as well as keyword lists and maps. Returns an
  `{:ok, result}` tuple on success. Returns an `{:error, reason}` tuple if the
  (type-specific) validation fails.

  ## Examples

  ```elixir
  iex> PackageUrl.new("pkg:maven/org.apache.commons/io@1.3.4")
  {:ok,
  %PackageUrl{
    name: "io",
    namespace: "org.apache.commons",
    qualifiers: nil,
    scheme: "pkg",
    subpath: nil,
    type: "maven",
    version: "1.3.4"
  }}
  iex> PackageUrl.new("pkg:maven/@1.3.4")
  {:error, "Invalid purl: :name is a required field."}
  ```
  """
  @spec new(binary | maybe_improper_list | map) :: {:ok, t()} | {:error, any}
  def new(purl) do
    with {:ok, parsed} <- parse(purl),
         {:ok, sanitized} <- sanitize(parsed) do
      {:ok, sanitized}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Parses and validates a PackageUrl into its components.

  This function accepts binaries as well as keyword lists and maps. Raises an
  exception if the (type-specific) validation fails.

  ## Examples

  ```elixir
  iex> PackageUrl.new!("pkg:maven/org.apache.commons/io@1.3.4")
  %PackageUrl{
    name: "io",
    namespace: "org.apache.commons",
    qualifiers: nil,
    scheme: "pkg",
    subpath: nil,
    type: "maven",
    version: "1.3.4"
  }
  ```
  """
  @spec new!(binary | maybe_improper_list | map) :: t()
  def new!(purl) do
    case new(purl) do
      {:ok, purl} -> purl
      {:error, reason} -> raise(ArgumentError, reason)
    end
  end

  @doc """
  Returns the string representation of the given `PackageUrl` struct.

  Return `{:ok,string}` on success. If the (type-specific) validation fails
  return a `{:error, reason}` tuple.

  ## Examples
  ```elixir
  iex> purl = PackageUrl.new!("pkg:maven/org.apache.commons/io@1.3.4")
  iex> PackageUrl.to_string(purl)
  {:ok, "pkg:maven/org.apache.commons/io@1.3.4"}
  ```

  ```elixir
  iex> invalid_purl = %PackageUrl{}
  iex> PackageUrl.to_string(invalid_purl)
  {:error, "Invalid purl: :type is a required field."}
  ```
  """
  @spec to_string(t()) :: {:ok, binary} | {:error, any}
  def to_string(%__MODULE__{} = purl) do
    case sanitize(purl) do
      {:ok, sanitized} -> build_purl(sanitized)
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Returns the string representation of the given `PackageUrl` struct.

  Raises an exception if the (type-specific) validation fails.

  ## Examples
  ```elixir
  iex> purl = PackageUrl.new!("pkg:maven/org.apache.commons/io@1.3.4")
  iex> PackageUrl.to_string!(purl)
  "pkg:maven/org.apache.commons/io@1.3.4"
  ```
  """
  @spec to_string!(t()) :: binary
  def to_string!(%__MODULE__{} = purl) do
    case to_string(purl) do
      {:ok, purl} -> purl
      {:error, reason} -> raise(ArgumentError, reason)
    end
  end

  ################################################################
  # Parsing functions
  ################################################################

  defp parse_purl(purl) when is_binary(purl) do
    with {:ok, scheme, remainder} <- parse_scheme(purl),
         {:ok, type, remainder} <- parse_type(remainder),
         url <- URI.parse(remainder),
         {:ok, qualifiers} <- parse_qualifiers(url),
         {:ok, subpath} <- parse_subpath(url),
         :ok <- reject_userinfo(url),
         path <- trim_leading_slashes(url.path),
         {:ok, version, remainder} <- parse_version(path),
         {:ok, namespace, name} <- parse_namespace_name(remainder) do
      {:ok,
       %{
         scheme: scheme,
         type: type,
         namespace: namespace,
         name: name,
         subpath: subpath,
         qualifiers: qualifiers,
         version: version
       }}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  defp parse_scheme(purl) do
    case String.split(purl, ":", parts: 2) do
      ["pkg"] -> {:ok, "pkg", ""}
      ["pkg", remainder] -> {:ok, "pkg", trim_leading_slashes(remainder)}
      _ -> {:error, "purl is missing the required \"pkg\" scheme component."}
    end
  end

  defp parse_type(remainder) do
    case String.split(remainder, "/", parts: 2) do
      [_] -> {:error, "purl is missing the required \"type\" component"}
      [_, ""] -> {:error, "purl is missing the required \"type\" component"}
      [type, remainder] -> {:ok, type, remainder}
    end
  end

  defp parse_qualifiers(url) do
    case url.query do
      nil -> {:ok, nil}
      query -> {:ok, URI.decode_query(query)}
    end
  end

  defp parse_subpath(url), do: {:ok, url.fragment}

  defp reject_userinfo(%URI{userinfo: nil}), do: :ok
  defp reject_userinfo(_), do: {:error, "Invalid purl: cannot contain a \"user:pass@host:port\""}

  defp parse_version(path) do
    case String.split(path, "@", parts: 2) do
      [remainder] -> {:ok, nil, remainder}
      [remainder, version] -> {:ok, PackageUrl.URI.decode_uri_component(version), remainder}
    end
  end

  defp parse_namespace_name(remainder) do
    case remainder |> String.split("/") |> Enum.reverse() do
      [""] ->
        {:ok, nil, nil}

      [name] ->
        {:ok, nil, PackageUrl.URI.decode_uri_component(name)}

      ["" | namespace] ->
        {:ok,
         namespace |> Enum.reverse() |> Enum.join("/") |> PackageUrl.URI.decode_uri_component(),
         nil}

      [name | namespace] ->
        {:ok,
         namespace |> Enum.reverse() |> Enum.join("/") |> PackageUrl.URI.decode_uri_component(),
         PackageUrl.URI.decode_uri_component(name)}
    end
  end

  ################################################################
  # Sanitizing functions
  ################################################################

  @doc """
  Sanitize `PackageUrl` according to `CustomPackage` `type`.
  """
  @spec sanitize(PackageUrl.t()) :: {:ok, PackageUrl.t()} | {:error, any}
  def sanitize(%PackageUrl{type: type} = purl) when is_binary(type),
    # We're duplicating Package behaviour/GenericPackage functions here to ensure pattern matching on `type` below
    do: sanitize_package(String.downcase(type), purl)

  def sanitize(%PackageUrl{type: _type} = purl), do: sanitize_package(nil, purl)

  defp sanitize_package("alpm", purl), do: PackageUrl.AlpmPackage.sanitize(purl)

  defp sanitize_package("bitbucket", purl), do: PackageUrl.BitbucketPackage.sanitize(purl)

  defp sanitize_package("cocoapods", purl), do: PackageUrl.CocoapodsPackage.sanitize(purl)

  defp sanitize_package("cargo", purl), do: PackageUrl.CargoPackage.sanitize(purl)

  defp sanitize_package("composer", purl), do: PackageUrl.ComposerPackage.sanitize(purl)

  defp sanitize_package("conan", purl), do: PackageUrl.ConanPackage.sanitize(purl)

  defp sanitize_package("conda", purl), do: PackageUrl.CondaPackage.sanitize(purl)

  defp sanitize_package("cran", purl), do: PackageUrl.CranPackage.sanitize(purl)

  defp sanitize_package("deb", purl), do: PackageUrl.DebPackage.sanitize(purl)

  defp sanitize_package("docker", purl), do: PackageUrl.DockerPackage.sanitize(purl)

  defp sanitize_package("gem", purl), do: PackageUrl.GemPackage.sanitize(purl)

  defp sanitize_package("github", purl), do: PackageUrl.GithubPackage.sanitize(purl)

  defp sanitize_package("golang", purl), do: PackageUrl.GolangPackage.sanitize(purl)

  defp sanitize_package("hackage", purl), do: PackageUrl.HackagePackage.sanitize(purl)

  defp sanitize_package("hex", purl), do: PackageUrl.HexPackage.sanitize(purl)

  defp sanitize_package("maven", purl), do: PackageUrl.MavenPackage.sanitize(purl)

  defp sanitize_package("npm", purl), do: PackageUrl.NpmPackage.sanitize(purl)

  defp sanitize_package("nuget", purl), do: PackageUrl.NugetPackage.sanitize(purl)

  defp sanitize_package("oci", purl), do: PackageUrl.OciPackage.sanitize(purl)

  defp sanitize_package("pub", purl), do: PackageUrl.PubPackage.sanitize(purl)

  defp sanitize_package("rpm", purl), do: PackageUrl.RpmPackage.sanitize(purl)

  defp sanitize_package("pypi", purl), do: PackageUrl.PypiPackage.sanitize(purl)

  defp sanitize_package("swid", purl), do: PackageUrl.SwidPackage.sanitize(purl)

  defp sanitize_package("swift", purl), do: PackageUrl.SwiftPackage.sanitize(purl)

  defp sanitize_package(_, purl), do: PackageUrl.GenericPackage.sanitize(purl)

  ################################################################
  # String building functions
  ################################################################

  defp build_purl(%__MODULE__{} = purl) do
    with {:ok, iolist} <- build_scheme(purl, []),
         {:ok, iolist} <- build_type(purl, iolist),
         {:ok, iolist} <- build_namespace(purl, iolist),
         {:ok, iolist} <- build_name(purl, iolist),
         {:ok, iolist} <- build_version(purl, iolist),
         {:ok, iolist} <- build_qualifiers(purl, iolist),
         {:ok, iolist} <- build_subpath(purl, iolist) do
      {:ok, :erlang.iolist_to_binary(iolist)}
    end
  end

  defp build_scheme(%__MODULE__{}, iolist) when is_list(iolist), do: {:ok, ["pkg:"]}

  defp build_type(%__MODULE__{type: type}, iolist) when is_list(iolist),
    do: {:ok, [iolist, type, "/"]}

  defp build_namespace(%__MODULE__{namespace: nil}, iolist) when is_list(iolist),
    do: {:ok, iolist}

  defp build_namespace(%__MODULE__{namespace: namespace}, iolist) when is_list(iolist) do
    {:ok,
     [
       iolist,
       namespace
       |> PackageUrl.URI.encode_uri_component()
       |> String.replace("%3A", ":")
       |> String.replace("%2F", "/"),
       "/"
     ]}
  end

  defp build_name(%__MODULE__{name: name}, iolist) when is_list(iolist) do
    {:ok,
     [
       iolist,
       name
       |> PackageUrl.URI.encode_uri_component()
       |> String.replace("%3A", ":")
     ]}
  end

  defp build_version(%__MODULE__{version: nil}, iolist) when is_list(iolist), do: {:ok, iolist}

  defp build_version(%__MODULE__{version: version}, iolist) when is_list(iolist) do
    {:ok,
     [
       iolist,
       "@",
       version
       |> PackageUrl.URI.encode_uri_component()
       |> String.replace("%3A", ":")
     ]}
  end

  defp build_qualifiers(%__MODULE__{qualifiers: nil}, iolist) when is_list(iolist),
    do: {:ok, iolist}

  defp build_qualifiers(%__MODULE__{qualifiers: qualifiers}, iolist) when is_list(iolist) do
    {:ok,
     [
       iolist,
       "?",
       qualifiers
       |> Map.keys()
       |> Enum.sort()
       |> Enum.map(fn key ->
         {key
          |> PackageUrl.URI.encode_uri_component()
          |> String.replace("%3A", ":"),
          Map.get(qualifiers, key)
          |> PackageUrl.URI.encode_uri()
          |> String.replace("%3A", ":")}
       end)
       |> Enum.map(fn {key, value} -> [key, "=", value] end)
       |> Enum.intersperse("&")
     ]}
  end

  defp build_subpath(%__MODULE__{subpath: nil}, iolist) when is_list(iolist), do: {:ok, iolist}

  defp build_subpath(%__MODULE__{subpath: subpath}, iolist) when is_list(iolist),
    do: {:ok, [iolist, "#", PackageUrl.URI.encode_uri(subpath)]}

  ################################################################
  # Helper functions
  ################################################################

  defp merge_defaults(map) do
    merged = %__MODULE__{} |> Map.from_struct() |> Map.merge(map)
    {:ok, struct(__MODULE__, merged)}
  end

  defp trim_leading_slashes(string) do
    string
    |> String.trim()
    |> String.trim_leading("/")
  end
end
