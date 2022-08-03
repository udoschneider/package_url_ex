defmodule PackageUrl.GenericPackageTest do
  use ExUnit.Case

  alias PackageUrl.GenericPackage

  describe "type" do
    test "is valid" do
      map = %{type: "type"}
      assert GenericPackage.sanitize_type(map) == {:ok, map}
    end

    test "is not nil" do
      map = %{type: nil}
      assert match?({:error, _}, GenericPackage.sanitize_type(map))
    end

    test "contains invalid characters" do
      # The package type is composed only of ASCII letters and numbers, '.', '+' and '-' (period, plus, and dash)
      # The type cannot contains spaces
      map = %{type: "type#"}
      assert match?({:error, _}, GenericPackage.sanitize_type(map))

      map = %{type: "ty pe"}
      assert match?({:error, _}, GenericPackage.sanitize_type(map))
    end

    test "doesn't start with number" do
      # The type cannot start with a number
      map = %{type: "1type"}
      assert match?({:error, _}, GenericPackage.sanitize_type(map))
    end

    test "isn't percent-encoded" do
      # The type must NOT be percent-encoded
      map = %{type: "%74ype"}
      assert match?({:error, _}, GenericPackage.sanitize_type(map))
    end

    test "is case insensitive" do
      # The type is case insensitive. The canonical form is lowercase
      map = %{type: "Type"}
      assert GenericPackage.sanitize_type(map) == {:ok, %{type: "type"}}
    end
  end

  describe "qualifiers" do
    test "are valid" do
      map = %{qualifiers: %{"key" => "value"}}
      assert GenericPackage.sanitize_qualifiers(map) == {:ok, map}
    end

    test "cannot contain empty values" do
      # value cannot be an empty string: a key=value pair with an empty value is the same as no key/value at all for this key
      map = %{qualifiers: %{"key" => ""}}
      assert GenericPackage.sanitize_qualifiers(map) == {:ok, %{qualifiers: %{}}}

      map = %{qualifiers: %{"key" => nil}}
      assert GenericPackage.sanitize_qualifiers(map) == {:ok, %{qualifiers: %{}}}
    end

    test "key contains invalid characters" do
      # The key must be composed only of ASCII letters and numbers, '.', '-' and '_' (period, dash and underscore)
      # A key cannot contains spaces
      map = %{qualifiers: %{"key#" => "value"}}
      assert match?({:error, _}, GenericPackage.sanitize_qualifiers(map))

      map = %{qualifiers: %{"k ey" => "value"}}
      assert match?({:error, _}, GenericPackage.sanitize_qualifiers(map))
    end

    test "key must NOT be percent-encoded" do
      # A key must NOT be percent-encoded
      map = %{qualifiers: %{"%6Bey" => "value"}}
      assert match?({:error, _}, GenericPackage.sanitize_qualifiers(map))
    end

    test "key is case insensitive" do
      # A key is case insensitive. The canonical form is lowercase
      map = %{qualifiers: %{"Key" => "value"}}
      assert GenericPackage.sanitize_qualifiers(map) == {:ok, %{qualifiers: %{"key" => "value"}}}
    end
  end

  describe "subpath" do
    test "is valid" do
      map = %{subpath: "subpath"}
      assert GenericPackage.sanitize_subpath(map) == {:ok, map}
    end

    test "has leading and trailing slashes trimmed" do
      map = %{subpath: "/sub/sub/sub/path/"}

      assert GenericPackage.sanitize_subpath(map) ==
               {:ok, %{subpath: "sub/sub/sub/path"}}
    end
  end
end
