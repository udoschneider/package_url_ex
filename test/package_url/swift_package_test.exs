defmodule PackageUrl.CranPackageTest do
  use ExUnit.Case

  alias PackageUrl.CranPackage

  describe "version" do
    test "is not nil" do
      map = %{version: nil}
      assert match?({:error, _}, CranPackage.sanitize_version(map))
    end
  end
end
