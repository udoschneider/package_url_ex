defmodule PackageUrl.GenericPackageTest do
  use ExUnit.Case

  # These tests actually test the functions in `Package`. As they need to be
  # `use`d we'll test against `GenericPackage` which doesn't add any functions
  # its own.
  alias PackageUrl.GenericPackage, as: Package

  describe "type" do
    test "is valid" do
      assert Package.sanitize_type("type") == {:ok, "type"}
    end

    test "is not nil" do
      assert match?({:error, _}, Package.sanitize_type(nil))
    end

    test "contains invalid characters" do
      # The package type is composed only of ASCII letters and numbers, '.', '+' and '-' (period, plus, and dash)
      # The type cannot contains spaces
      assert match?({:error, _}, Package.sanitize_type("type#"))
      assert match?({:error, _}, Package.sanitize_type("ty pe"))
    end

    test "doesn't start with number" do
      # The type cannot start with a number
      assert match?({:error, _}, Package.sanitize_type("1type"))
    end

    test "isn't percent-encoded" do
      # The type must NOT be percent-encoded

      assert match?({:error, _}, Package.sanitize_type("%74ype"))
    end

    test "is case insensitive" do
      # The type is case insensitive. The canonical form is lowercase

      assert Package.sanitize_type("Type") == {:ok, "type"}
    end
  end

  describe "qualifiers" do
    test "are valid" do
      assert Package.sanitize_qualifiers(%{"key" => "value"}) == {:ok, %{"key" => "value"}}
    end

    test "cannot contain empty values" do
      # value cannot be an empty string: a key=value pair with an empty value is the same as no key/value at all for this key
      assert Package.sanitize_qualifiers(%{"key" => ""}) == {:ok, %{}}
      assert Package.sanitize_qualifiers(%{"key" => nil}) == {:ok, %{}}
    end

    test "key contains invalid characters" do
      # The key must be composed only of ASCII letters and numbers, '.', '-' and '_' (period, dash and underscore)
      # A key cannot contains spaces
      assert match?({:error, _}, Package.sanitize_qualifiers(%{"key#" => "value"}))
      assert match?({:error, _}, Package.sanitize_qualifiers(%{"k ey" => "value"}))
    end

    test "key must NOT be percent-encoded" do
      # A key must NOT be percent-encoded
      assert match?({:error, _}, Package.sanitize_qualifiers(%{"%6Bey" => "value"}))
    end

    test "key is case insensitive" do
      # A key is case insensitive. The canonical form is lowercase
      assert Package.sanitize_qualifiers(%{"Key" => "value"}) == {:ok, %{"key" => "value"}}
    end
  end

  describe "subpath" do
    test "is valid" do
      assert Package.sanitize_subpath("subpath") == {:ok, "subpath"}
    end

    test "has leading and trailing slashes trimmed" do
      assert Package.sanitize_subpath("/sub/sub/sub/path/") ==
               {:ok, "sub/sub/sub/path"}
    end
  end
end
