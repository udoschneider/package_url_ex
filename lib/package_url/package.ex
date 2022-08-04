defmodule PackageUrl.CustomPackage do
  @moduledoc """
  A behaviour module for implementing the type-specific sanitization/rules for
  `PackageUrl`.

  Except for `c:sanitize_aggregate/1` all callbacks only handle a specific
  value. If you need to implement sanitization/rules which affect/rely on
  multiple keys you need to implement the logic in `c:sanitize_aggregate/1`.

  ## Sanitizing values

  Unless you return an error please use the value returned by `super()` to do
  your checks on. This ensures generic type sanitization takes place before
  custom sanitization. If the implementation does some kind of pattern matching
  (e.g. with a guard clause) you'll also need to call then generic `super`
  implementation later.

  Example:
  ```elixir
  @impl PackageUrl.CustomPackage
  def sanitize_name(name) when is_binary(name) do
    with {:ok, name} <- super(name) do
      {:ok, String.downcase(name)}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  def sanitize_name(name), do: super(name)
  ```

  ## Filtering values

  If you need to return errors please remember to call `super()` as last match
  to ensure further processing.

  Example:
  ```elixir
  @impl PackageUrl.CustomPackage
  def sanitize_version(nil),
    do: {:error, "Invalid purl: :version is a required field."}

  def sanitize_version(map), do: super(map)
  ```
  """

  @doc "Sanitize/filter the `type` attribute of a `PackageUrl`."
  @callback sanitize_type(type :: binary() | nil) ::
              {:ok, result :: binary()} | {:error, reason :: term()}

  @doc "Sanitize/filter the `namespace` attribute of a `PackageUrl`."
  @callback sanitize_namespace(namespace :: binary() | nil) ::
              {:ok, result :: binary() | nil} | {:error, reason :: term()}

  @doc "Sanitize/filter the `name` attribute of a `PackageUrl`."
  @callback sanitize_name(name :: binary() | nil) ::
              {:ok, result :: binary()} | {:error, reason :: term()}

  @doc "Sanitize/filter the `version` attribute of a `PackageUrl`."
  @callback sanitize_version(version :: binary() | nil) ::
              {:ok, result :: binary() | nil} | {:error, reason :: term()}

  @doc "Sanitize/filter the `qualifiers` attribute of a `PackageUrl`."
  @callback sanitize_qualifiers(
              qualifiers :: %{optional(binary()) => binary() | map() | nil} | nil
            ) ::
              {:ok, result :: %{optional(binary()) => binary() | map() | nil} | nil}
              | {:error, reason :: term()}

  @doc "Sanitize/filter the `subpath` attribute of a `PackageUrl`."
  @callback sanitize_subpath(subpath :: binary() | nil) ::
              {:ok, result :: binary() | nil} | {:error, reason :: term()}

  @doc "Sanitize/filter complete `PackageUrl`."
  @callback sanitize_aggregate(purl :: PackageUrl.t()) ::
              {:ok, result :: PackageUrl.t()} | {:error, reason :: term()}

  defmacro __using__(_opts) do
    quote do
      @behaviour PackageUrl.CustomPackage

      @doc false

      def sanitize(%PackageUrl{} = purl) do
        with {:ok, purl} <- sanitize_empty_values(purl),
             scheme <- purl.scheme,
             {:ok, type} <- sanitize_type(purl.type),
             {:ok, namespace} <- sanitize_namespace(purl.namespace),
             {:ok, name} <- sanitize_name(purl.name),
             {:ok, version} <- sanitize_version(purl.version),
             {:ok, qualifiers} <- sanitize_qualifiers(purl.qualifiers),
             {:ok, subpath} <- sanitize_subpath(purl.subpath),
             purl <-
               struct(PackageUrl, %{
                 scheme: scheme,
                 type: type,
                 name: name,
                 namespace: namespace,
                 version: version,
                 qualifiers: qualifiers,
                 subpath: subpath
               }),
             {:ok, purl} <- sanitize_aggregate(purl) do
          {:ok, purl}
        else
          {:error, reason} -> {:error, reason}
        end
      end

      defp sanitize_empty_values(%PackageUrl{} = purl) do
        sanitized =
          purl
          |> Map.from_struct()
          |> Enum.map(fn
            {key, ""} -> {key, nil}
            p -> p
          end)

        {:ok, struct(PackageUrl, sanitized)}
      end

      @impl PackageUrl.CustomPackage
      def sanitize_type(nil),
        do: {:error, "Invalid purl: :type is a required field."}

      def sanitize_type(type) do
        with {:allowed_characters, true} <- {:allowed_characters, valid_type?(type)},
             {:not_percent_encoded, true} <- {:not_percent_encoded, type == URI.decode(type)},
             sanitized <- String.downcase(type) do
          {:ok, sanitized}
        else
          {:allowed_characters, _} ->
            {:error, "Invalid purl: :type contains forbidden characters"}

          {:not_percent_encoded, _} ->
            {:error, "Invalid purl: :type is percent encoded"}
        end
      end

      defp valid_type?(type), do: type =~ ~r/^[[:alpha:]\.+-][[:alnum:]\.+-]*$/

      @impl PackageUrl.CustomPackage
      def sanitize_namespace(namespace), do: {:ok, namespace}

      @impl PackageUrl.CustomPackage
      def sanitize_name(nil),
        do: {:error, "Invalid purl: :name is a required field."}

      def sanitize_name(name) when is_binary(name), do: {:ok, name}

      @impl PackageUrl.CustomPackage
      def sanitize_version(version), do: {:ok, version}

      @impl PackageUrl.CustomPackage
      def sanitize_qualifiers(nil), do: {:ok, nil}

      def sanitize_qualifiers(%{} = qualifiers) do
        sanitized =
          qualifiers
          |> Enum.map(fn
            {_key, nil} -> nil
            {_key, ""} -> nil
            p -> p
          end)
          |> Enum.reject(&(&1 == nil))
          |> Enum.map(fn
            {:error, reason} ->
              {:error, reason}

            {key, value} ->
              if key == URI.decode(key),
                do: {key, value},
                else: {:error, "Invalid purl: qualifier #{inspect(key)} is percent encoded."}
          end)
          |> Enum.map(fn
            {:error, reason} ->
              {:error, reason}

            {key, value} ->
              if valid_qualifier_key?(key),
                do: {key, value},
                else:
                  {:error,
                   "Invalid purl: qualifier #{inspect(key)} contains an illegal character."}
          end)
          |> Enum.map(fn
            {:error, reason} ->
              {:error, reason}

            {key, value} ->
              {String.downcase(key), value}
          end)

        case Enum.find(sanitized, sanitized, fn
               {:error, reason} -> true
               p -> false
             end) do
          {:error, reason} -> {:error, reason}
          sanitized -> {:ok, Enum.into(sanitized, %{})}
        end
      end

      defp valid_qualifier_key?(key), do: key =~ ~r/^[[:alpha:]\.-_][[:alnum:]\.-_]*$/

      @impl PackageUrl.CustomPackage
      def sanitize_subpath(nil), do: {:ok, nil}

      def sanitize_subpath(subpath) when is_binary(subpath),
        do: {:ok, String.trim(subpath, "/")}

      @impl PackageUrl.CustomPackage
      def sanitize_aggregate(%PackageUrl{} = purl), do: {:ok, purl}

      defoverridable sanitize_type: 1,
                     sanitize_namespace: 1,
                     sanitize_name: 1,
                     sanitize_version: 1,
                     sanitize_qualifiers: 1,
                     sanitize_subpath: 1,
                     sanitize_aggregate: 1
    end
  end
end
