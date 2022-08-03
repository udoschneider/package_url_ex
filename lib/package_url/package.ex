defmodule PackageUrl.Package do
  @callback sanitize(purl :: map) :: {:ok, result :: map} | {:error, reason :: term}
  @callback sanitize_type(purl :: map) :: {:ok, result :: map} | {:error, reason :: term}
  @callback sanitize_namespace(purl :: map) :: {:ok, result :: map} | {:error, reason :: term}
  @callback sanitize_name(purl :: map) :: {:ok, result :: map} | {:error, reason :: term}
  @callback sanitize_version(purl :: map) :: {:ok, result :: map} | {:error, reason :: term}
  @callback sanitize_qualifiers(purl :: map) :: {:ok, result :: map} | {:error, reason :: term}
  @callback sanitize_subpath(purl :: map) :: {:ok, result :: map} | {:error, reason :: term}
  @callback sanitize_aggregate(purl :: map) :: {:ok, result :: map} | {:error, reason :: term}

  defmacro __using__(_opts) do
    quote do
      @behaviour PackageUrl.Package

      @impl PackageUrl.Package
      def sanitize(map) do
        with {:ok, map} <- sanitize_empty_values(map),
             {:ok, map} <- sanitize_type(map),
             {:ok, map} <- sanitize_namespace(map),
             {:ok, map} <- sanitize_name(map),
             {:ok, map} <- sanitize_version(map),
             {:ok, map} <- sanitize_qualifiers(map),
             {:ok, map} <- sanitize_subpath(map),
             {:ok, map} <- sanitize_aggregate(map) do
          {:ok, map}
        else
          {:error, reason} -> {:error, reason}
        end
      end

      defp sanitize_empty_values(map) do
        {:ok,
         map
         |> Enum.map(fn
           {key, ""} -> {key, nil}
           p -> p
         end)
         |> Enum.into(%{})}
      end

      @impl PackageUrl.Package
      def sanitize_type(%{type: nil}),
        do: {:error, "Invalid purl: :type is a required field."}

      def sanitize_type(%{type: type} = map) do
        with {:allowed_characters, true} <- {:allowed_characters, valid_type?(type)},
             {:not_percent_encoded, true} <- {:not_percent_encoded, type == URI.decode(type)},
             sanitized <- update_in(map, [:type], &String.downcase/1) do
          {:ok, sanitized}
        else
          {:allowed_characters, _} ->
            {:error, "Invalid purl: :type contains forbidden characters"}

          {:not_percent_encoded, _} ->
            {:error, "Invalid purl: :type is percent encoded"}
        end
      end

      defp valid_type?(type), do: type =~ ~r/^[[:alpha:]\.+-][[:alnum:]\.+-]*$/

      @impl PackageUrl.Package
      def sanitize_namespace(%{} = map), do: {:ok, map}

      @impl PackageUrl.Package
      def sanitize_name(%{name: nil}),
        do: {:error, "Invalid purl: :name is a required field."}

      def sanitize_name(%{} = map), do: {:ok, map}

      @impl PackageUrl.Package
      def sanitize_version(%{} = map), do: {:ok, map}

      @impl PackageUrl.Package
      def sanitize_qualifiers(%{qualifiers: nil} = map), do: {:ok, map}

      def sanitize_qualifiers(%{qualifiers: qualifiers} = map) do
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
          sanitized -> {:ok, %{map | qualifiers: Enum.into(sanitized, %{})}}
        end
      end

      defp valid_qualifier_key?(key), do: key =~ ~r/^[[:alpha:]\.-_][[:alnum:]\.-_]*$/

      @impl PackageUrl.Package
      def sanitize_subpath(%{subpath: nil} = map), do: {:ok, map}

      def sanitize_subpath(%{subpath: subpath} = map) when is_binary(subpath),
        do: {:ok, %{map | subpath: String.trim(subpath, "/")}}

      @impl PackageUrl.Package
      def sanitize_aggregate(map), do: {:ok, map}

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
