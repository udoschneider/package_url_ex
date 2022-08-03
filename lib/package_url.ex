defmodule PackageUrl do
  @moduledoc """
  Documentation for `PackageUrl`.
  """

  import Kernel, except: [to_string: 1]

  alias PackageUrl.{
    BitbucketPackage,
    ConanPackage,
    CranPackage,
    GenericPackage,
    GithubPackage,
    PypiPackage,
    SwiftPackage
  }

  defstruct scheme: "pkg",
            type: nil,
            namespace: nil,
            name: nil,
            version: nil,
            qualifiers: nil,
            subpath: nil,
            remainder: nil

  def new(nil), do: nil

  def new(purl) when is_binary(purl), do: parse_purl(purl)

  def new(options) when is_list(options) do
    options
    |> Enum.into(%{})
    |> new()
  end

  def new(map) when is_map(map) do
    with {:ok, merged} <- merge_defaults(map),
         {:ok, sanitized} <- sanitize(merged) do
      {:ok, struct(__MODULE__, sanitized)}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  def new!(purl) do
    case new(purl) do
      {:ok, purl} -> purl
      {:error, reason} -> raise(ArgumentError, reason)
    end
  end

  def to_string(%__MODULE__{} = purl), do: build_purl(purl)

  def to_string!(%__MODULE__{} = purl) do
    case to_string(purl) do
      {:ok, purl} -> purl
      {:error, reason} -> raise(ArgumentError, reason)
    end
  end

  ################################################################
  # Private Functions
  ################################################################

  defp merge_defaults(map), do: {:ok, %__MODULE__{} |> Map.from_struct() |> Map.merge(map)}

  ################################################################
  # Parsing functions
  ################################################################
  def parse_purl(nil), do: {:error, "A purl string argument is required."}
  def parse_purl(""), do: {:error, "A purl string argument is required."}

  def parse_purl(purl) do
    with {:ok, scheme, remainder} <- parse_scheme(purl),
         {:ok, type, remainder} <- parse_type(remainder),
         url <- URI.parse(remainder),
         {:ok, qualifiers} <- parse_qualifiers(url),
         {:ok, subpath} <- parse_subpath(url),
         :ok <- reject_userinfo(url),
         path <- trim_leading_slashes(url.path),
         {:ok, version, remainder} <- parse_version(path),
         {:ok, namespace, name} <- parse_namespace_name(remainder) do
      new(
        scheme: scheme,
        type: type,
        qualifiers: qualifiers,
        subpath: subpath,
        version: version,
        namespace: namespace,
        name: name
      )
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
      [remainder, version] -> {:ok, decodeURIComponent(version), remainder}
    end
  end

  defp parse_namespace_name(remainder) do
    case remainder |> String.split("/") |> Enum.reverse() do
      [""] ->
        {:ok, nil, nil}

      [name] ->
        {:ok, nil, decodeURIComponent(name)}

      ["" | namespace] ->
        {:ok, namespace |> Enum.reverse() |> Enum.join("/") |> decodeURIComponent(), nil}

      [name | namespace] ->
        {:ok, namespace |> Enum.reverse() |> Enum.join("/") |> decodeURIComponent(),
         decodeURIComponent(name)}
    end
  end

  ################################################################
  # Sanitizing functions
  ################################################################

  defp sanitize(%{type: type} = map) when is_binary(type),
    # We're duplicating Package behaviour/GenericPackage functions here to unsure pattern matching on `type` below
    do: sanitize_package(%{map | type: String.downcase(type)})

  defp sanitize(map), do: sanitize_package(map)

  defp sanitize_package(%{type: "bitbucket"} = map), do: BitbucketPackage.sanitize(map)

  defp sanitize_package(%{type: "conan"} = map), do: ConanPackage.sanitize(map)

  defp sanitize_package(%{type: "cran"} = map), do: CranPackage.sanitize(map)

  defp sanitize_package(%{type: "github"} = map), do: GithubPackage.sanitize(map)

  defp sanitize_package(%{type: "pypi"} = map), do: PypiPackage.sanitize(map)

  defp sanitize_package(%{type: "swift"} = map), do: SwiftPackage.sanitize(map)

  defp sanitize_package(map), do: GenericPackage.sanitize(map)

  ################################################################
  # String building functions
  ################################################################

  defp build_purl(%__MODULE__{} = purl) do
    with {:ok, acc} <- build_scheme(purl, []),
         {:ok, acc} <- build_type(purl, acc),
         {:ok, acc} <- build_namespace(purl, acc),
         {:ok, acc} <- build_name(purl, acc),
         {:ok, acc} <- build_version(purl, acc),
         {:ok, acc} <- build_qualifiers(purl, acc),
         {:ok, acc} <- build_subpath(purl, acc) do
      {:ok, acc |> Enum.reverse() |> :erlang.iolist_to_binary()}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  defp build_scheme(%__MODULE__{}, acc) when is_list(acc), do: {:ok, ["pkg:" | acc]}

  defp build_type(%__MODULE__{type: type}, acc) when is_list(acc),
    do: {:ok, [[type <> "/"] | acc]}

  defp build_namespace(%__MODULE__{namespace: nil}, acc) when is_list(acc), do: {:ok, acc}

  defp build_namespace(%__MODULE__{namespace: namespace}, acc) when is_list(acc) do
    {:ok,
     [
       (namespace
        |> encodeURIComponent()
        |> String.replace("%3A", ":")
        |> String.replace("%2F", "/")) <> "/"
       | acc
     ]}
  end

  defp build_name(%__MODULE__{name: name}, acc) when is_list(acc) do
    {:ok,
     [
       name
       |> encodeURIComponent()
       |> String.replace("%3A", ":")
       | acc
     ]}
  end

  defp build_version(%__MODULE__{version: nil}, acc) when is_list(acc), do: {:ok, acc}

  defp build_version(%__MODULE__{version: version}, acc) when is_list(acc) do
    {:ok,
     [
       [
         "@",
         version
         |> encodeURIComponent()
         |> String.replace("%3A", ":")
       ]
       | acc
     ]}
  end

  defp build_qualifiers(%__MODULE__{qualifiers: nil}, acc) when is_list(acc), do: {:ok, acc}

  defp build_qualifiers(%__MODULE__{qualifiers: qualifiers}, acc) when is_list(acc) do
    {:ok,
     [
       [
         "?",
         qualifiers
         |> Map.keys()
         |> Enum.sort()
         |> Enum.map(fn key ->
           {key
            |> encodeURIComponent()
            |> String.replace("%3A", ":"),
            Map.get(qualifiers, key)
            |> encodeURI()
            |> String.replace("%3A", ":")}
         end)
         |> Enum.map(fn {key, value} -> [key, "=", value] end)
         |> Enum.intersperse("&")
       ]
       | acc
     ]}
  end

  defp build_subpath(%__MODULE__{subpath: nil}, acc) when is_list(acc), do: {:ok, acc}

  defp build_subpath(%__MODULE__{subpath: subpath}, acc) when is_list(acc),
    do: {:ok, [["#" <> encodeURI(subpath)] | acc]}

  ################################################################
  # Helper functions
  ################################################################

  defp trim_leading_slashes(string) do
    # this strip '/, // and /// as possible in :// or :///
    # from https://gist.github.com/refo/47632c8a547f2d9b6517#file-remove-leading-slash
    # string.trim().replace(/^\/+/g, '');

    # Regex.replace(~r/d/, String.trim(string), "")
    string
    |> String.trim()
    |> String.trim_leading("/")
  end

  # uriAlpha ::: one of
  #   a b c d e f g h i j k l m n o p q r s t u v w x y z
  #   A B C D E F G H I J K L M N O P Q R S T U V W X Y Z
  @uriAlpha 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'

  # DecimalDigit :: one of
  #   0 1 2 3 4 5 6 7 8 9
  @decimalDigit '0123456789'

  #   uriMark ::: one of
  #   - _ . ! ~ * ' ( )
  @uriMark '-_.!~*\'()'

  # uriUnescaped :::
  #   uriAlpha
  #   DecimalDigit
  #   uriMark
  @uriUnescaped @uriAlpha ++ @decimalDigit ++ @uriMark

  # uriReserved ::: one of
  #   ; / ? : @ & = + $ ,
  # @uriReserved ';/?:@&=+$,'

  # Let reservedURISet be a String containing one instance of each character valid in uriReserved plus “#”.
  def decodeURI(string) when is_binary(string),
    do: URI.decode(string)

  # Let reservedURIComponentSet be the empty String.
  def decodeURIComponent(string) when is_binary(string),
    do: URI.decode(string)

  # Let unescapedURISet be a String containing one instance of each character valid in uriReserved and uriUnescaped plus “#”.
  def encodeURI(string) when is_binary(string),
    # do: URI.encode(string, &(&1 in (@uriReserved ++ @uriUnescaped ++ '#')))
    do: URI.encode(string)

  # Let unescapedURIComponentSet be a String containing one instance of each character valid in uriUnescaped.
  def encodeURIComponent(string) when is_binary(string),
    # do: URI.encode_www_form(string)
    do: URI.encode(string, &(&1 in @uriUnescaped))
end
