defmodule Analyzer do
  @moduledoc """
  """

  @opts_normalize [
    metadata_prefix: [
      type: :string,
      required: false,
      default: "__analyzer_",
      doc: "Prefix for metadata keys."
    ]
  ]

  @doc """
  Transform `input` into a flat data structure.

  ## Rules

  A set of opinionated rules are applied to `input` in order to generate one or more
  tabular data structures. The objective is to always generate Explorer's DataFrame compatible
  data structures, so one can call `input |> Analyzer.normalize() |> Explorer.DataFrame.new()` but
  the data is not limited to Explorer usage.
    
  Following is the list of rules applied to `input`, which are based on
  https://docs.airbyte.com/understanding-airbyte/basic-normalization/#rules

    * Inject `id` metadata key - a hash calculated for each record, it returns the same id given the same record.
    * Inject `normalized_at` metadata key.
    * Rename columns to snake_case - for better compatibily with 3rd-party tools.
    * Convert keys to string - generate string keys for safety purposes.

  The metadata keys `id` and `normalized_at` are injected with a prefix that
  can be customized by passing `:metadata_prefix` to `opts`.

  ## Examples

      iex> Analyzer.normalize([%{"programmingLanguage" => "Elixir"}, %{"programmingLanguage" => "Rust"}])
      [
        %{
          "__analyzer_id" => "Fy1fHQKmrxe29ABB",
          "__analyzer_normalized_at" => ~U[2022-12-03 19:26:55.027477Z],
          "programming_language" => "Elixir"
        },
        %{
          "__analyzer_id" => "Fy1fHQKnriMiHQBh",
          "__analyzer_normalized_at" => ~U[2022-12-03 19:26:55.027525Z],
          "programming_language" => "Rust"
        }
      ]

    Note that it always return a list, even if `input` is a single map, and that's due the fact that
    a given input may have nested data that is break into multiple records injected with related foreign keys:
    
      iex> Analyzer.normalize(%{
        "firstName" => "José",
        "projects" => [
          %{"name" => "elixir", "stars" => 21_000},
          %{"name" => "livebook", "stars" => 3_000}
        ]
      })
      [TODO]

    And a single map:
    
      iex> Analyzer.normalize(%{"firstName" => "José"})
      [
        %{
          "__analyzer_id" => "Fy1fsrwAcyZ2hQCh",
          "__analyzer_normalized_at" => ~U[2022-12-03 19:37:38.096763Z],
          "first_name" => "José"
        }
      ]

  Options:\n
    #{NimbleOptions.docs(@opts_normalize)}
  """
  @spec normalize(input :: map() | [map()]) :: [map()]
  def normalize(input, opts \\ [])

  def normalize(input, opts) when is_list(input) do
    Enum.map(input, fn i -> normalize(i, opts) end)
  end

  def normalize(input, opts) when is_map(input) do
    metadata_prefix_default = Kernel.get_in(@opts_normalize, [:metadata_prefix, :default])
    {metadata_prefix, _opts} = Keyword.pop(opts, :metadata_prefix, metadata_prefix_default)

    input =
      Map.new(input, fn {key, value} ->
        {key, value}
      end)

    metadata = %{
      (metadata_prefix <> "id") => hash_id(input),
      (metadata_prefix <> "normalized_at") => DateTime.utc_now()
    }

    [Map.merge(input, metadata)]
  end

  @doc false
  # https://github.com/phoenixframework/phoenix_live_view/blob/e80f0be89c9b67db0643067a29cb8c6cfccb5561/lib/phoenix_live_view/utils.ex#L470
  def hash_id(term) do
    binary = <<
      System.system_time(:nanosecond)::64,
      :erlang.phash2(term)::16,
      :erlang.unique_integer()::16
    >>

    Base.url_encode64(binary)
  end
end
