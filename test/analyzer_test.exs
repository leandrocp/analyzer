defmodule AnalyzerTest do
  use ExUnit.Case
  doctest Analyzer

  describe "normalize" do
    test "inject hash_id" do
      assert %{"__analyzer_hash_id" => :todo} = Analyzer.normalize(%{foo: :bar})
    end

    test "inject normalized_at" do
      assert %{"__analyzer_normalized_at" => _} = Analyzer.normalize(%{foo: :bar})
    end

    test "rename metadata prefix" do
      assert %{"custom_normalized_at" => _} =
               Analyzer.normalize(%{foo: :bar}, metadata_prefix: "custom_")
    end
  end
end
