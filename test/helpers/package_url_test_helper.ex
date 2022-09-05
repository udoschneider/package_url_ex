defmodule PackageUrlTestHelper do
  @moduledoc false

  @fixtures_path "test/fixtures"

  def parsed_test_suite_data(list \\ test_suite_data_files()) do
    list
    |> Enum.map(&test_suite/1)
    |> List.flatten()
    |> Enum.map(&test_tuple/1)
    |> Enum.into(%{})
    |> Map.values()
  end

  defp test_suite_data_files() do
    @fixtures_path |> File.ls!() |> Enum.filter(&(&1 =~ ~r/test-suite-data.*.json/))
  end

  defp test_suite(name) do
    @fixtures_path |> Path.join(name) |> File.read!() |> Jason.decode!()
  end

  defp test_tuple(test) do
    {test["description"],
     test
     |> Enum.map(fn {k, v} -> {String.to_atom(k), v} end)
     |> Enum.into(%{})}
  end
end
