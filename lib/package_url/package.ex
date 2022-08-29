defmodule PackageUrl.Package do
  @moduledoc """
  Default implementation used by all `CustomPackage` implementations.

  Implicitly used by `use CustomPackage`.

  """

  defmacro __using__(_opts) do
    quote do
      @doc false

      @doc "Sanitize/filter the `type` attribute of a `PackageUrl`."
      @spec sanitize_type(type :: binary() | nil) ::
              {:ok, result :: binary()} | {:error, reason :: term()}
      @impl PackageUrl.CustomPackage
      def sanitize_type(nil),
        do: {:error, "Invalid purl: :type is a required field."}

      def sanitize_type(type) when is_binary(type) do
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

      def sanitize_type(_),
        do: {:error, "Invalid purl: :type invalid."}

      defp valid_type?(type), do: type =~ ~r/^[[:alpha:]\.+-][[:alnum:]\.+-]*$/

      @doc "Sanitize/filter the `namespace` attribute of a `PackageUrl`."
      @spec sanitize_namespace(namespace :: binary() | nil) ::
              {:ok, result :: binary() | nil} | {:error, reason :: term()}
      @impl PackageUrl.CustomPackage
      def sanitize_namespace(namespace) when is_nil(namespace) or is_binary(namespace),
        do: {:ok, namespace}

      def sanitize_namespace(_),
        do: {:error, "Invalid purl: :namespace invalid."}

      @doc "Sanitize/filter the `name` attribute of a `PackageUrl`."
      @spec sanitize_name(name :: binary() | nil) ::
              {:ok, result :: binary()} | {:error, reason :: term()}
      @impl PackageUrl.CustomPackage
      def sanitize_name(nil),
        do: {:error, "Invalid purl: :name is a required field."}

      def sanitize_name(name) when is_binary(name), do: {:ok, name}

      def sanitize_name(_),
        do: {:error, "Invalid purl: :name invalid."}

      @doc "Sanitize/filter the `version` attribute of a `PackageUrl`."
      @spec sanitize_version(version :: binary() | nil) ::
              {:ok, result :: binary() | nil} | {:error, reason :: term()}
      @impl PackageUrl.CustomPackage
      def sanitize_version(version) when is_nil(version) or is_binary(version), do: {:ok, version}

      def sanitize_version(_),
        do: {:error, "Invalid purl: :version invalid."}

      @doc "Sanitize/filter the `qualifiers` attribute of a `PackageUrl`."
      @spec sanitize_qualifiers(
              qualifiers :: %{optional(binary()) => binary() | map() | nil} | nil
            ) ::
              {:ok, result :: %{optional(binary()) => binary() | map() | nil} | nil}
              | {:error, reason :: term()}
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

      def sanitize_qualifiers(_),
        do: {:error, "Invalid purl: :qualifiers invalid."}

      defp valid_qualifier_key?(key), do: key =~ ~r/^[[:alpha:]\.-_][[:alnum:]\.-_]*$/

      @doc "Sanitize/filter the `subpath` attribute of a `PackageUrl`."
      @spec sanitize_subpath(subpath :: binary() | nil) ::
              {:ok, result :: binary() | nil} | {:error, reason :: term()}
      @impl PackageUrl.CustomPackage
      def sanitize_subpath(nil), do: {:ok, nil}

      def sanitize_subpath(subpath) when is_binary(subpath),
        do: {:ok, String.trim(subpath, "/")}

      def sanitize_subpath(_),
        do: {:error, "Invalid purl: :subpath invalid."}

      @doc "Sanitize/filter complete `PackageUrl`."
      @spec sanitize_aggregate(purl :: PackageUrl.t()) ::
              {:ok, result :: PackageUrl.t()} | {:error, reason :: term()}
      @impl PackageUrl.CustomPackage
      def sanitize_aggregate(%PackageUrl{} = purl), do: {:ok, purl}
    end
  end
end
