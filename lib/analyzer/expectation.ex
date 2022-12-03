defmodule Analyzer.Expectation do
  @moduledoc """
  Expectations
  """

  defstruct expectations: [], backend: nil, data: nil

  @type data :: Explorer.DataFrame.t() | Ecto.Queryable.t() | list(map() | struct())
  @type t :: %__MODULE__{expectations: list(), backend: module(), data: data}

  # TODO docs, spec, validation
  def new(opts) do
    {backend, opts} = Keyword.pop(opts, :backend)
    {data, _opts} = Keyword.pop(opts, :data)

    %Analyzer.Expectation{expectations: [], backend: backend, data: data}
  end

  # TODO supervisor
  def run(token) do
    %{backend: backend, data: data} = token

    tasks =
      Enum.map(token.expectations, fn {expectation, opts} ->
        Task.async(fn ->
          # TODO result spec
          {expectation, opts, Kernel.apply(backend, expectation, [data, opts])}
        end)
      end)

    Task.await_many(tasks)
  end

  @opts_expect_table_row_count_to_equal [
    count: [
      type: :integer,
      required: true,
      doc: "TODO"
    ]
  ]
  @doc """
  expect_table_row_count_to_equal

  Options:\n
    #{NimbleOptions.docs(@opts_expect_table_row_count_to_equal)}
  """
  @spec expect_table_row_count_to_equal(term, Keyword.t()) :: t()
  def expect_table_row_count_to_equal(token, opts) do
    expectation = {:expect_table_row_count_to_equal, opts}
    %{token | expectations: [expectation | token.expectations]}
  end
end
