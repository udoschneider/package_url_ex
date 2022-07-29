defmodule PackageUrl do
  @moduledoc """
  Documentation for `PackageUrl`.
  """

  defstruct scheme: "pkg",
            type: nil,
            namespace: nil,
            name: nil,
            version: nil,
            qualifiers: nil,
            subpath: nil,
            remainder: nil

  def new!(purl) do
    case new(purl) do
      {:ok, purl} -> purl
      {:error, reason} -> raise reason
    end
  end

  # TODO Remove
  def new(nil), do: {:error, "No PackageURL provided"}

  def new(purl) when is_binary(purl) do
    parse_purl(purl)
  end

  def new(options) when is_list(options), do: {:ok, PackageUrl.__struct__(options)}

  def canonical_url(purl) do
    with {:ok, acc} <- build_scheme(purl, ""),
         {:ok, acc} <- build_type(purl, acc),
         {:ok, acc} <- build_name(purl, acc),
         {:ok, acc} <- build_version(purl, acc),
         {:ok, acc} <- build_qualifiers(purl, acc),
         {:ok, acc} <- build_subpath(purl, acc) do
      acc
    else
      e -> e
    end
  end

  defp parse_purl(purl) do
    with {:ok, {purl, remainder}} <- parse_subpath(PackageUrl, purl),
         {:ok, {purl, remainder}} <- parse_qualifiers(purl, remainder),
         {:ok, {purl, remainder}} <- parse_scheme(purl, remainder),
         {:ok, {purl, remainder}} <- parse_type(purl, remainder),
         {:ok, {purl, remainder}} <- parse_version(purl, remainder),
         {:ok, {purl, remainder}} <- parse_name(purl, remainder),
         {:ok, {purl, ""}} <- parse_namespace(purl, remainder) do
      {:ok, purl}
    else
      {:error, _message} -> nil
    end
  end

  defp parse_subpath(purl, remainder) do
    # Split the purl string once from right on '#'
    # The left side is the remainder
    # Strip the right side from leading and trailing '/'
    # Split this on '/'
    # Discard any empty string segment from that split
    # Discard any '.' or '..' segment from that split
    # Percent-decode each segment
    # UTF-8-decode each segment if needed in your programming language
    # Join segments back with a '/'
    # This is the subpath
    {remainder, subpath} =
      case String.split(remainder, "#", parts: 2) do
        [remainder] ->
          {remainder, nil}

        [remainder, right] ->
          {remainder,
           right
           |> String.trim("/")
           |> String.split("/")
           |> Enum.reject(&(&1 in ["", ".", ".."]))
           |> Enum.map(&URI.decode(&1))
           |> Enum.join("/")}
      end

    {:ok,
     {
       struct(purl, subpath: non_empty_or_nil(subpath)),
       remainder
     }}
  end

  defp parse_qualifiers(purl, remainder) do
    # Split the remainder once from right on '?'
    # The left side is the remainder
    # The right side is the qualifiers string
    # Split the qualifiers on '&'. Each part is a key=value pair
    # For each pair, split the key=value once from left on '=':
    # The key is the lowercase left side
    # The value is the percent-decoded right side
    # UTF-8-decode the value if needed in your programming language
    # Discard any key/value pairs where the value is empty
    # If the key is checksums, split the value on ',' to create a list of checksums
    # This list of key/value is the qualifiers object

    {remainder, qualifiers} =
      case String.split(remainder, "?", parts: 2) do
        [remainder] ->
          {remainder, nil}

        [remainder, right] ->
          {remainder,
           right
           |> String.split("&")
           |> Enum.map(&String.split(&1, "=", parts: 2))
           |> Enum.map(fn [key, value] -> {String.downcase(key), URI.decode(value)} end)
           |> Enum.reject(fn
             {_, ""} -> true
             {"", _} -> true
             _ -> false
           end)
           # A key cannot start with a number
           # The key must be composed only of ASCII letters and numbers, '.', '-' and '_' (period, dash and underscore)
           |> Enum.filter(fn {key, _value} -> key =~ ~r/[[:alpha:]\.-_][[:alnum:]\.-_]*/ end)
           # A key must NOT be percent-encoded
           |> Enum.filter(fn {key, _value} -> key == URI.decode(key) end)
           |> Enum.map(fn
             {"checksums", value} -> {"checksums", String.split(value, ",")}
             pair -> pair
           end)
           |> Enum.into(%{})}
      end

    {:ok, {struct(purl, qualifiers: qualifiers), remainder}}
  end

  defp parse_scheme(purl, remainder) do
    # Split the remainder once from left on ':'
    # The left side lowercased is the scheme
    # The right side is the remainder

    {scheme, remainder} =
      case String.split(remainder, ":", parts: 2) do
        [remainder] -> {"pkg", remainder}
        [scheme, remainder] -> {String.downcase(scheme), remainder}
      end

    if scheme == "pkg" do
      {:ok, {struct(purl, scheme: "pkg"), remainder}}
    else
      {:error, "Invalid scheme \"#{scheme}\""}
    end
  end

  defp parse_type(purl, remainder) do
    # Strip the remainder from leading and trailing '/'
    # Split this once from left on '/'
    # The left side lowercased is the type
    # The right side is the remainder

    {type, remainder} =
      case remainder
           |> String.trim("/")
           |> String.split("/", parts: 2) do
        [left] -> {"pkg", left}
        [left, remainder] -> {String.downcase(left), remainder}
      end

    # The package type is composed only of ASCII letters and numbers, '.', '+' and '-' (period, plus, and dash)
    # The type cannot start with a number
    # The type cannot contains spaces
    # The type must NOT be percent-encoded

    with true <- type =~ ~r/[[:alpha:]\.+-][[:alnum:]\.+.]*/,
         true <- type == URI.decode(type) do
      {:ok, {struct(purl, type: non_empty_or_nil(type)), remainder}}
    else
      _ -> {:error, "Invalid type \"#{type}\""}
    end
  end

  defp parse_version(purl, remainder) do
    # Split the remainder once from right on '@'
    # The left side is the remainder
    # Percent-decode the right side. This is the version.
    # UTF-8-decode the version if needed in your programming language
    # This is the version

    {remainder, version} =
      case remainder
           |> String.reverse()
           |> String.split("@", parts: 2)
           |> Enum.map(&String.reverse/1)
           |> Enum.reverse() do
        [remainder] -> {"", remainder}
        [remainder, right] -> {remainder, URI.decode(right)}
      end

    {:ok, {struct(purl, version: non_empty_or_nil(version)), remainder}}
  end

  defp parse_name(purl, remainder) do
    # Split the remainder once from right on '/'
    # The left side is the remainder
    # Percent-decode the right side. This is the name
    # UTF-8-decode this name if needed in your programming language
    # Apply type-specific normalization to the name if needed
    # This is the name

    {remainder, right} =
      case remainder
           |> String.reverse()
           |> String.split("/", parts: 2)
           |> Enum.map(&String.reverse/1)
           |> Enum.reverse() do
        [remainder] -> {"", remainder}
        [remainder, right] -> {remainder, right}
      end

    name =
      right
      |> URI.decode()
      |> normalize_name(purl.type)

    {:ok, {struct(purl, name: non_empty_or_nil(name)), remainder}}
  end

  defp parse_namespace(purl, remainder) do
    # Split the remainder on '/'
    # Discard any empty segment from that split
    # Percent-decode each segment
    # UTF-8-decode the each segment if needed in your programming language
    # Apply type-specific normalization to each segment if needed
    # Join segments back with a '/'
    # This is the namespace

    namespace =
      remainder
      |> String.split("/")
      |> Enum.reject(&(&1 == ""))
      |> Enum.map(&URI.decode/1)
      |> Enum.map(&normalize_namespace(&1, purl.type))
      |> Enum.join("/")

    namespace = if namespace != "", do: namespace, else: nil

    {:ok, {struct(purl, namespace: non_empty_or_nil(namespace)), ""}}
  end

  # The name is the repository name. It is not case sensitive and must be lowercased.
  defp normalize_name(name, "bitbucket"), do: String.downcase(name)
  # The name is the repository name. It is not case sensitive and must be lowercased.
  defp normalize_name(name, "github"), do: String.downcase(name)

  # PyPi treats - and _ as the same character and is not case sensitive. Therefore a Pypi package name must be lowercased and underscore _ replaced with a dash -
  defp normalize_name(name, "pypi"), do: name |> String.downcase() |> String.replace("_", "-")

  defp normalize_name(name, _type), do: name

  # The namespace is the user or organization. It is not case sensitive and must be lowercased.
  defp normalize_namespace(namespace, "bitbucket"), do: String.downcase(namespace)
  # The namespace is the user or organization. It is not case sensitive and must be lowercased.
  defp normalize_namespace(namespace, "github"), do: String.downcase(namespace)

  defp normalize_namespace(namespace, _type), do: namespace

  defp build_scheme(%PackageUrl{}, _acc) do
    # Start a purl string with the "pkg:" scheme as a lowercase ASCII string
    {:ok, "pkg:"}
  end

  defp build_type(%PackageUrl{type: nil}, _acc), do: {:error, "type required"}

  defp build_type(%PackageUrl{type: type}, acc) do
    # Append the type string to the purl as a lowercase ASCII string
    # Append '/' to the purl
    {:ok, acc <> String.downcase(type) <> "/"}
  end

  defp build_name(%PackageUrl{name: nil}, _acc), do: {:error, "name required"}

  defp build_name(%PackageUrl{namespace: nil, name: name, type: type}, acc) do
    # If the namespace is empty:
    # Apply type-specific normalization to the name if needed
    # UTF-8-encode the name if needed in your programming language
    # Append the percent-encoded name to the purl
    {:ok, acc <> (name |> normalize_name(type) |> URI.encode())}
  end

  defp build_name(%PackageUrl{namespace: namespace, name: name, type: type}, acc) do
    # If the namespace is not empty:
    # Strip the namespace from leading and trailing '/'
    # Split on '/' as segments
    # Apply type-specific normalization to each segment if needed
    # UTF-8-encode each segment if needed in your programming language
    # Percent-encode each segment
    # Join the segments with '/'
    # Append this to the purl
    # Append '/' to the purl
    # Strip the name from leading and trailing '/'
    # Apply type-specific normalization to the name if needed
    # UTF-8-encode the name if needed in your programming language
    # Append the percent-encoded name to the purl
    namespace =
      namespace
      |> String.trim("/")
      |> String.split("/")
      |> Enum.map(&normalize_namespace(&1, type))
      |> Enum.map(&URI.encode/1)
      |> Enum.join("/")

    name =
      name
      |> String.trim("/")
      |> normalize_name(type)

    {:ok, acc <> namespace <> "/" <> name}
  end

  defp build_version(%PackageUrl{version: nil}, acc), do: {:ok, acc}

  defp build_version(%PackageUrl{version: version}, acc) do
    # If the version is not empty:
    # Append '@' to the purl
    # UTF-8-encode the version if needed in your programming language
    # Append the percent-encoded version to the purl
    {:ok, acc <> "@" <> URI.encode( version)}
  end

  defp build_qualifiers(%PackageUrl{qualifiers: nil}, acc), do: {:ok, acc}

  defp build_qualifiers(%PackageUrl{qualifiers: qualifiers}, acc) do
    # If the qualifiers are not empty and not composed only of key/value pairs where the value is empty:
    # Append '?' to the purl
    # Build a list from all key/value pair:
    # discard any pair where the value is empty.
    # UTF-8-encode each value if needed in your programming language
    # If the key is checksums and this is a list of checksums join this list with a ',' to create this qualifier value
    # create a string by joining the lowercased key, the equal '=' sign and the percent-encoded value to create a qualifier
    # sort this list of qualifier strings lexicographically
    # join this list of qualifier strings with a '&' ampersand
    # Append this string to the purl
    qualifiers =
      qualifiers
      |> Enum.reject(fn {_key, value} -> value == "" end)
      |> Enum.map(fn
        {"checksums", checksums} -> {"checksums", Enum.join(checksums, ",")}
        pair -> pair
      end)
      |> Enum.map(fn {key, value} -> String.downcase(key) <> "=" <> URI.encode(value) end)
      |> Enum.sort(:asc)
      |> Enum.join("&")

    {:ok, acc <> "?" <> qualifiers}
  end

  defp build_subpath(%PackageUrl{subpath: nil}, acc), do: {:ok, acc}

  defp build_subpath(%PackageUrl{subpath: subpath}, acc) do
    # If the subpath is not empty and not composed only of empty, '.' and '..' segments:
    # Append '#' to the purl
    # Strip the subpath from leading and trailing '/'
    # Split this on '/' as segments
    # Discard empty, '.' and '..' segments
    # Percent-encode each segment
    # UTF-8-encode each segment if needed in your programming language
    # Join the segments with '/'
    # Append this to the purl
    subpath =
      subpath
      |> String.trim("/")
      |> String.split("/")
      |> Enum.reject(&(&1 in ["", ".", ".."]))
      |> Enum.map(&URI.encode/1)
      |> Enum.join("/")

    if subpath == "" do
      {:ok, acc}
    else
      {:ok, acc <> "#" <> subpath}
    end
  end

  defp non_empty_or_nil(nil), do: nil
  defp non_empty_or_nil(""), do: nil
  defp non_empty_or_nil(value) when is_binary(value), do: value
end
