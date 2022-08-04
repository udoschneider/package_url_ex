defmodule PackageUrl.HexPackageTest do
  use ExUnit.Case

  alias PackageUrl.HexPackage

  describe "namespace" do
    test "is lowercased" do
      # The namespace is optional; it may be used to specify the organization
      # for private packages on hex.pm. It is not case sensitive and must be
      # lowercased.
      assert HexPackage.sanitize_namespace("MyOrg") == {:ok, "myorg"}
    end
  end

  describe "name" do
    test "is lowercased" do
      # The name is not case sensitive and must be lowercased.
      assert HexPackage.sanitize_name("MyRepo") == {:ok, "myrepo"}
    end
  end
end
