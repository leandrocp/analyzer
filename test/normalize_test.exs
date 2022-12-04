defmodule NormalizeTest do
  use ExUnit.Case

  test "hash_id" do
    assert Analyzer.hash_id(%{foo: :bar}) |> is_binary()
  end

  describe "named record" do
    test "default" do
      assert %{"record" => %{}} = Analyzer.normalize(%{foo: :bar})
    end

    test "overwrite" do
      assert %{"custom" => %{}} = Analyzer.normalize(%{foo: :bar}, as: "custom")
    end
  end

  describe "metadata" do
    test "inject id" do
      assert %{"record" => %{"__analyzer_id" => _}} = Analyzer.normalize(%{foo: :bar})
    end

    test "inject normalized_at" do
      assert %{"record" => %{"__analyzer_normalized_at" => _}} = Analyzer.normalize(%{foo: :bar})
    end

    test "rename metadata prefix" do
      assert %{"record" => %{"custom_normalized_at" => _}} =
               Analyzer.normalize(%{foo: :bar}, metadata_prefix: "custom_")
    end
  end

  describe "rules" do
    test "convert key to string" do
      assert %{"record" => %{"first_name" => "test"}} = Analyzer.normalize(%{first_name: "test"})
    end

    test "rename columns to snake_case" do
      assert %{"record" => %{"first_name" => "test"}} =
               Analyzer.normalize(%{"firstName" => "test"})
    end
  end

  describe "rules - expansion" do
    test "inject metadata into all records" do
      assert %{
               "record" => %{"__analyzer_id" => _, "__analyzer_normalized_at" => _},
               "projects" => [%{"__analyzer_id" => _, "__analyzer_normalized_at" => _}]
             } = Analyzer.normalize(%{first_name: "test", projects: ["elixir"]})
    end

    test "expand list of binary" do
      assert %{
               "record" => %{"first_name" => "test"},
               "projects" => [%{"data" => "elixir"}, %{"data" => "livebook"}]
             } = Analyzer.normalize(%{first_name: "test", projects: ["elixir", "livebook"]})
    end

    test "expand list of map" do
      assert %{
               "record" => %{"first_name" => "test"},
               "projects" => [%{"name" => "elixir"}, %{"name" => "livebook"}]
             } =
               Analyzer.normalize(%{
                 first_name: "test",
                 projects: [%{name: "elixir"}, %{name: "livebook"}]
               })
    end
  end
end
