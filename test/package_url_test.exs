defmodule PackageUrlTest do
  use ExUnit.Case
  doctest PackageUrl

  test_suite_data =
    File.read!("test/fixtures/test-suite-data.json")
    |> Jason.decode!()
    |> Enum.map(fn o ->
      o
      |> Enum.map(fn {k, v} -> {String.to_atom(k), v} end)
      |> Enum.into(%{})
    end)

  describe "it should not be possible to create invalid PackageURLs /" do
    for obj <- test_suite_data do
      if obj.is_invalid do
        test "#{obj.description} / #{inspect(obj.purl)}" do
          purl =
            PackageUrl.new(
              type: unquote(obj.type),
              namespace: unquote(obj.namespace),
              name: unquote(obj.name),
              version: unquote(obj.version),
              qualifiers: unquote(Macro.escape(obj.qualifiers)),
              subpath: unquote(obj.subpath)
            )

          assert match?({:error, _}, purl)

          assert_raise ArgumentError, ~r/(is a required field|Invalid purl)/, fn ->
            PackageUrl.new!(
              type: unquote(obj.type),
              namespace: unquote(obj.namespace),
              name: unquote(obj.name),
              version: unquote(obj.version),
              qualifiers: unquote(Macro.escape(obj.qualifiers)),
              subpath: unquote(obj.subpath)
            )
          end
        end
      end
    end
  end

  describe "it should not be possible to parse invalid PackageURLs /" do
    for obj <- test_suite_data do
      if obj.is_invalid do
        test "#{obj.description} / #{inspect(obj.purl)}" do
          purl = PackageUrl.new(unquote(obj.purl))

          assert match?({:error, _}, purl)

          assert_raise ArgumentError, ~r/(purl is missing the required|Invalid purl)/, fn ->
            PackageUrl.new!(unquote(obj.purl))
          end
        end
      end
    end
  end

  describe "it should be able to create valid PackageURLs /" do
    for obj <- test_suite_data do
      unless obj.is_invalid do
        test "#{obj.description} / #{inspect(obj.purl)}" do
          {:ok, purl} =
            PackageUrl.new(
              type: unquote(obj.type),
              namespace: unquote(obj.namespace),
              name: unquote(obj.name),
              version: unquote(obj.version),
              qualifiers: unquote(Macro.escape(obj.qualifiers)),
              subpath: unquote(obj.subpath)
            )

          assert purl.type == unquote(obj.type)
          assert purl.namespace == unquote(obj.namespace)
          assert purl.name == unquote(obj.name)
          assert purl.version == unquote(obj.version)
          assert purl.qualifiers == unquote(Macro.escape(obj.qualifiers))
          assert purl.subpath == unquote(obj.subpath)
        end
      end
    end
  end

  describe "should be able to convert valid PackageURLs to a string /" do
    for obj <- test_suite_data do
      unless obj.is_invalid do
        test "#{obj.description} / #{inspect(obj.purl)}" do
          {:ok, purl} =
            PackageUrl.new(
              type: unquote(obj.type),
              namespace: unquote(obj.namespace),
              name: unquote(obj.name),
              version: unquote(obj.version),
              qualifiers: unquote(Macro.escape(obj.qualifiers)),
              subpath: unquote(obj.subpath)
            )

          assert PackageUrl.to_string!(purl) == unquote(obj.canonical_purl)
        end
      end
    end
  end

  describe "it should be able to parse valid PackageURLs /" do
    for obj <- test_suite_data do
      unless obj.is_invalid do
        test "#{obj.description} / #{inspect(obj.purl)}" do
          {:ok, purl} = PackageUrl.new(unquote(obj.canonical_purl))

          assert PackageUrl.to_string!(purl) == unquote(obj.canonical_purl)
          assert purl.type == unquote(obj.type)
          assert purl.namespace == unquote(obj.namespace)
          assert purl.name == unquote(obj.name)
          assert purl.version == unquote(obj.version)
          assert purl.qualifiers == unquote(Macro.escape(obj.qualifiers))
          assert purl.subpath == unquote(obj.subpath)
        end
      end
    end
  end
end
