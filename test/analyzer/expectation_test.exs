defmodule Analyzer.ExpectationTest do
  use ExUnit.Case, async: true

  alias Analyzer.Expectation

  describe "explorer" do
    test "success" do
      data = Explorer.DataFrame.new([%{a: 1}, %{a: 2}])

      expected = [{:expect_table_row_count_to_equal, [count: 2], {:ok, %{observed_value: 2}}}]

      assert Analyzer.Expectation.new(
               backend: Analyzer.Backend.Explorer,
               data: data
             )
             |> Analyzer.Expectation.expect_table_row_count_to_equal(count: 2)
             |> Analyzer.Expectation.run() == expected
    end

    test "failure" do
      data = Explorer.DataFrame.new([%{a: 1}])

      expected = [{:expect_table_row_count_to_equal, [count: 2], {:error, %{observed_value: 1}}}]

      assert Analyzer.Expectation.new(
               backend: Analyzer.Backend.Explorer,
               data: data
             )
             |> Analyzer.Expectation.expect_table_row_count_to_equal(count: 2)
             |> Analyzer.Expectation.run() == expected
    end
  end

  describe "list" do
    test "success" do
      data = [%{a: 1}, %{a: 2}]

      expected = [{:expect_table_row_count_to_equal, [count: 2], {:ok, %{observed_value: 2}}}]

      assert Analyzer.Expectation.new(
               backend: Analyzer.Backend.List,
               data: data
             )
             |> Analyzer.Expectation.expect_table_row_count_to_equal(count: 2)
             |> Analyzer.Expectation.run() == expected
    end

    test "failure" do
      data = [%{a: 1}]

      expected = [{:expect_table_row_count_to_equal, [count: 2], {:error, %{observed_value: 1}}}]

      assert Analyzer.Expectation.new(
               backend: Analyzer.Backend.List,
               data: data
             )
             |> Analyzer.Expectation.expect_table_row_count_to_equal(count: 2)
             |> Analyzer.Expectation.run() == expected
    end
  end
end
