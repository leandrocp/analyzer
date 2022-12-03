defmodule Analyzer.Backend do
  def register(backend) do
    Process.put(:analyzer_backend, backend)
  end

  @doc false
  def fetch do
    Process.get(:analyzer_backend)
  end
end
