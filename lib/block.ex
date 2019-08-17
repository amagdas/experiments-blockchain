defmodule Blockchain.Block do
  @enforce_keys [:data, :index, :timestamp, :hash, :previous_hash]
  defstruct data: nil, index: nil, timestamp: nil, hash: nil, previous_hash: nil

  @type t :: %__MODULE__{
          data: Map.t(),
          index: Integer.t(),
          timestamp: DateTime.t(),
          hash: String.t(),
          previous_hash: String.t()
        }

  def new(data, index, previous_block_hash, timestamp \\ DateTime.utc_now())
      when is_map(data) and is_integer(index) and is_binary(previous_block_hash) do
    hash = compute_hash(data, index, previous_block_hash, timestamp)

    %__MODULE__{
      data: data,
      index: index,
      timestamp: timestamp,
      hash: hash,
      previous_hash: previous_block_hash
    }
  end

  def calculate_hash(%__MODULE__{} = block) do
    compute_hash(block.data, block.index, block.previous_hash, block.timestamp)
  end

  defp compute_hash(data, index, previous_block_hash, timestamp) do
    body =
      Jason.encode!(data) <>
        Integer.to_string(index) <> previous_block_hash <> DateTime.to_string(timestamp)

    hash = :crypto.hash(:sha256, body) |> Base.encode16() |> String.downcase()
    hash
  end
end
