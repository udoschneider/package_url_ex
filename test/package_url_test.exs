defmodule PackageUrlTest do
  use ExUnit.Case
  doctest PackageUrl

  test_suite_data =
    File.read!("test/fixtures/test-suite-data.json")
    |> Jason.decode!()

  describe "parsing the test canonical purl then re-building a purl from these parsed components should return the test canonical purl" do
  end

  describe "parsing the test purl should return the components parsed from the test canonical purl" do
    for %{
          "description" => description,
          "purl" => purl,
          "canonical_purl" => canonical_purl,
          "type" => type,
          "namespace" => namespace,
          "name" => name,
          "version" => version,
          "qualifiers" => qualifiers,
          "subpath" => subpath,
          "is_invalid" => is_invalid
        } <- test_suite_data do
      test "#{description}" do
        assert PackageUrl.new(unquote(purl)) == PackageUrl.new(unquote(canonical_purl))
      end
    end
  end

  describe "parsing the test purl then re-building a purl from these parsed components should return the test canonical purl" do
  end

  describe "building a purl from the test components should return the test canonical purl" do
    for %{
          "description" => description,
          "purl" => purl,
          "canonical_purl" => canonical_purl,
          "type" => type,
          "namespace" => namespace,
          "name" => name,
          "version" => version,
          "qualifiers" => qualifiers,
          "subpath" => subpath,
          "is_invalid" => is_invalid
        } <- test_suite_data do
      test "#{description}" do
        {:ok, purl} =
          PackageUrl.new(
            type: unquote(type),
            namespace: unquote(namespace),
            name: unquote(name),
            version: unquote(version),
            qualifiers: unquote(Macro.escape(qualifiers)),
            subpath: unquote(subpath)
          )

        assert PackageUrl.canonical_url(purl) == unquote(canonical_purl)
      end
    end
  end
end
