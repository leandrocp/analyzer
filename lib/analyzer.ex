defmodule Analyzer do
  @moduledoc """
  """

  @opts_normalize [
    metadata_prefix: [
      type: :string,
      required: false,
      default: "__analyzer_",
      doc: "TODO"
    ]
  ]

  @doc """
  Transform `input` into a flat data structure.
    
  Rules are based on https://docs.airbyte.com/understanding-airbyte/basic-normalization

  A few metadata columns will be injected into the resulting data:
    
    * hash_id - TODO
    * normalized_at - TODO

  They are prefixed with `__analyzer_` by default, but can be changed
  by passing `:metadata_prefix` to `opts`.

  Options:\n
    #{NimbleOptions.docs(@opts_normalize)}
  """
  def normalize(input, opts \\ []) do
    metadata_prefix_default = Kernel.get_in(@opts_normalize, [:metadata_prefix, :default])
    {metadata_prefix, _opts} = Keyword.pop(opts, :metadata_prefix, metadata_prefix_default)

    hash_id = :todo
    normalized_at = DateTime.utc_now()

    metadata = %{
      (metadata_prefix <> "hash_id") => hash_id,
      (metadata_prefix <> "normalized_at") => normalized_at
    }

    Map.merge(input, metadata)
  end
end
