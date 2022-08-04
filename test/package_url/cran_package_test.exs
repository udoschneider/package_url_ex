defmodule PackageUrl.SwiftPackageTest do
  use ExUnit.Case

  alias PackageUrl.SwiftPackage

  describe "namespace" do
    test "is not nil" do
      assert match?({:error, _}, SwiftPackage.sanitize_namespace(nil))
    end
  end

  describe "version" do
    test "is not nil" do
      assert match?({:error, _}, SwiftPackage.sanitize_version(nil))
    end
  end
end
