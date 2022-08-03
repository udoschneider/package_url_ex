defmodule PackageUrl.SwiftPackageTest do
  use ExUnit.Case

  alias PackageUrl.SwiftPackage

  describe "namespace" do
    test "is not nil" do
      map = %{namespace: nil}
      assert match?({:error, _}, SwiftPackage.sanitize_namespace(map))
    end
  end

  describe "version" do
    test "is not nil" do
      map = %{version: nil}
      assert match?({:error, _}, SwiftPackage.sanitize_version(map))
    end
  end
end
