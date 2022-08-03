defmodule PackageUrlTest do
  use ExUnit.Case
  doctest PackageUrl

  test_suite_data_1 =
    "test/fixtures/test-suite-data-1.json"
    |> File.read!()
    |> Jason.decode!()

  test_suite_data_2 =
    "test/fixtures/test-suite-data-2.json"
    |> File.read!()
    |> Jason.decode!()

  test_suite_data =
    (test_suite_data_1 ++ test_suite_data_2)
    |> Enum.map(fn test ->
      {test["description"],
       test
       |> Enum.map(fn {k, v} -> {String.to_atom(k), v} end)
       |> Enum.into(%{})}
    end)
    |> Enum.into(%{})
    |> Map.values()

  describe "it should not be possible to create invalid PackageURLs /" do
    for obj <- test_suite_data do
      if obj.is_invalid do
        test "#{obj.description}" do
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
        test "#{obj.description}" do
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
        test "#{obj.description}" do
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
        test "#{obj.description}" do
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
        test "#{obj.description}" do
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

  describe "parsing the test canonical purl then re-building a purl from these parsed components should return the test canonical purl /" do
    for obj <- test_suite_data do
      unless obj.is_invalid do
        test "#{obj.description}" do
          {:ok, purl} = PackageUrl.new(unquote(obj.canonical_purl))

          assert PackageUrl.to_string!(purl) == unquote(obj.canonical_purl)
        end
      end
    end
  end

  describe "parsing the test purl should return the components parsed from the test canonical purl /" do
    for obj <- test_suite_data do
      unless obj.is_invalid do
        test "#{obj.description}" do
          purl = PackageUrl.new!(unquote(obj.purl))
          canonical_purl = PackageUrl.new!(unquote(obj.canonical_purl))

          unless purl.namespace == canonical_purl.namespace do
            IO.inspect(unquote(obj.purl))
            IO.inspect(purl)
            IO.inspect(unquote(obj.canonical_purl))
            IO.inspect(canonical_purl)
          end

          assert purl.type == canonical_purl.type
          assert purl.namespace == canonical_purl.namespace
          assert purl.name == canonical_purl.name
          assert purl.version == canonical_purl.version
          assert purl.qualifiers == canonical_purl.qualifiers
          assert purl.subpath == canonical_purl.subpath
        end
      end
    end
  end

  describe "parsing the test purl then re-building a purl from these parsed components should return the test canonical purl /" do
    for obj <- test_suite_data do
      unless obj.is_invalid do
        test "#{obj.description}" do
          purl = PackageUrl.new!(unquote(obj.purl))

          rebuilt =
            PackageUrl.new!(
              type: purl.type,
              namespace: purl.namespace,
              name: purl.name,
              version: purl.version,
              qualifiers: purl.qualifiers,
              subpath: purl.subpath
            )

          assert PackageUrl.to_string!(rebuilt) == unquote(obj.canonical_purl)
        end
      end
    end
  end

  describe "building a purl from the test components should return the test canonical purl /" do
    for obj <- test_suite_data do
      unless obj.is_invalid do
        test "#{obj.description}" do
          purl =
            PackageUrl.new!(
              type: unquote(obj.type),
              namespace: unquote(obj.namespace),
              name: unquote(obj.name),
              version: unquote(obj.version),
              qualifiers: unquote(Macro.escape(obj.qualifiers)),
              subpath: unquote(obj.subpath)
            )

          canonical_purl = PackageUrl.new!(unquote(obj.canonical_purl))

          assert purl == canonical_purl
        end
      end
    end
  end
end
