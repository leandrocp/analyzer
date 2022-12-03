defmodule AnalyzerTest do
  use ExUnit.Case

  test "hash_id" do
    assert Analyzer.hash_id(%{foo: :bar}) |> is_binary()
  end

  describe "normalize metadata" do
    test "inject id" do
      assert [%{"__analyzer_id" => _}] = Analyzer.normalize(%{foo: :bar})
    end

    test "inject normalized_at" do
      assert [%{"__analyzer_normalized_at" => _}] = Analyzer.normalize(%{foo: :bar})
    end

    test "rename metadata prefix" do
      assert [%{"custom_normalized_at" => _}] =
               Analyzer.normalize(%{foo: :bar}, metadata_prefix: "custom_")
    end
  end

  describe "normalize rules" do
    @tag :skip
    test "rename columns to snake_case" do
      assert [%{"first_name" => "test"}] = Analyzer.normalize(%{"firstName" => "test"})
    end
  end
end
