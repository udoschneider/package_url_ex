defmodule PackageUrl.CranPackageTest do
  use ExUnit.Case

  alias PackageUrl.CranPackage

  describe "version" do
    test "is not nil" do
      assert match?({:error, _}, CranPackage.sanitize_version(nil))
    end
  end
end
