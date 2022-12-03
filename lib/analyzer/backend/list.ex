defmodule Analyzer.Backend.List do
  def expect_table_row_count_to_equal(data, opts) when is_list(data) do
    expected_count = Keyword.fetch!(opts, :count)
    observed_value = length(data)

    if expected_count == observed_value do
      {:ok, %{observed_value: observed_value}}
    else
      {:error, %{observed_value: observed_value}}
    end
  end
end
