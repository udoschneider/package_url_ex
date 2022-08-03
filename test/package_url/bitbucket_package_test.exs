defmodule PackageUrl.BitbucketPackageTest do
  use ExUnit.Case

  alias PackageUrl.BitbucketPackage

  describe "namespace" do
    test "is lowercased" do
      # The namespace is the user or organization. It is not case sensitive and must be lowercased.
      map = %{namespace: "MyOrg"}
      assert BitbucketPackage.sanitize_namespace(map) == {:ok, %{namespace: "myorg"}}
    end
  end

  describe "name" do
    test "is lowercased" do
      # The name is the repository name. It is not case sensitive and must be lowercased.
      map = %{name: "MyRepo"}
      assert BitbucketPackage.sanitize_name(map) == {:ok, %{name: "myrepo"}}
    end
  end
end
