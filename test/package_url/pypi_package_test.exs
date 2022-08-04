defmodule PackageUrl.PypiPackageTest do
  use ExUnit.Case

  alias PackageUrl.PypiPackage

  describe "name" do
    test "is lowercased and underscores are replaced with dashes" do
      # PyPi treats - and _ as the same character and is not case sensitive.
      # Therefore a Pypi package name must be lowercased and underscore _ replaced with a dash -
      assert PypiPackage.sanitize_name("Pa_ckage") == {:ok, "pa-ckage"}
    end
  end
end
