if Code.ensure_loaded?(Explorer) do
  defmodule Analyzer.Backend.Explorer do
    alias Explorer.DataFrame

    def expect_table_row_count_to_equal(%DataFrame{} = df, opts) do
      expected_count = Keyword.fetch!(opts, :count)
      observed_value = DataFrame.n_rows(df)

      if expected_count == observed_value do
        {:ok, %{observed_value: observed_value}}
      else
        {:error, %{observed_value: observed_value}}
      end
    end
  end
end
