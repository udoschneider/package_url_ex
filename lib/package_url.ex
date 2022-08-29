defmodule PackageUrl do
  @moduledoc File.read!("README.md")
             |> String.split("<!-- MODULEDOC -->")
             |> Enum.fetch!(1)

  import Kernel, except: [to_string: 1]

  alias PackageUrl.{
    BitbucketPackage,
    ConanPackage,
    CranPackage,
    GenericPackage,
    GithubPackage,
    HexPackage,
    PypiPackage,
    SwiftPackage
  }

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
  iex> PackageUrl.new(type: "maven", namespace: "org.apache.commons", name: "io", version: "1.3.4")
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
  iex> PackageUrl.new(%{type: "maven", namespace: "org.apache.commons", name: "io", version: "1.3.4"})
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
  ```

  ```elixir
  iex> PackageUrl.new("pkg:maven/@1.3.4")
  {:error, "Invalid purl: :name is a required field."}
  ```
  """

  def new(string) when is_binary(string) do
    case parse(string) do
      {:ok, map} -> new(map)
      {:error, reason} -> {:error, reason}
    end
  end

  def new(list) when is_list(list) do
    list
    |> Enum.into(%{})
    |> new()
  end

  def new(map) when is_map(map) do
    with {:ok, merged} <- merge_defaults(map),
         {:ok, sanitized} <- sanitize(merged) do
      {:ok, sanitized}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Parses a PackageUrl into its components.

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
  iex> PackageUrl.new!(type: "maven", namespace: "org.apache.commons", name: "io", version: "1.3.4")
  %PackageUrl{
    name: "io",
    namespace: "org.apache.commons",
    qualifiers: nil,
    scheme: "pkg",
    subpath: nil,
    type: "maven",
    version: "1.3.4"
  }
  iex> PackageUrl.new!(%{type: "maven", namespace: "org.apache.commons", name: "io", version: "1.3.4"})
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

  def to_string!(%__MODULE__{} = purl) do
    case to_string(purl) do
      {:ok, purl} -> purl
      {:error, reason} -> raise(ArgumentError, reason)
    end
  end

  ################################################################
  # Parsing functions
  ################################################################

  defp parse(purl) when is_binary(purl) do
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

  defp sanitize(%__MODULE__{type: type} = map) when is_binary(type),
    # We're duplicating Package behaviour/GenericPackage functions here to ensure pattern matching on `type` below
    do: sanitize_package(%{map | type: String.downcase(type)})

  defp sanitize(map) when is_map(map), do: sanitize_package(map)

  defp sanitize_package(%{type: "bitbucket"} = map), do: BitbucketPackage.sanitize(map)

  defp sanitize_package(%{type: "conan"} = map), do: ConanPackage.sanitize(map)

  defp sanitize_package(%{type: "cran"} = map), do: CranPackage.sanitize(map)

  defp sanitize_package(%{type: "github"} = map), do: GithubPackage.sanitize(map)

  defp sanitize_package(%{type: "hex"} = map), do: HexPackage.sanitize(map)

  defp sanitize_package(%{type: "pypi"} = map), do: PypiPackage.sanitize(map)

  defp sanitize_package(%{type: "swift"} = map), do: SwiftPackage.sanitize(map)

  defp sanitize_package(map), do: GenericPackage.sanitize(map)

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
