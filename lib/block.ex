defmodule Blockchain.Block do
  @enforce_keys [:data, :index, :timestamp, :hash, :previous_hash, :nonce]
  defstruct data: nil, index: nil, timestamp: nil, hash: nil, previous_hash: nil, nonce: nil

  @type t :: %__MODULE__{
          data: Map.t(),
          index: Integer.t(),
          timestamp: DateTime.t(),
          nonce: Integer.t(),
          hash: String.t(),
          previous_hash: String.t()
        }

  def new(data, index, previous_block_hash, difficulty, timestamp \\ DateTime.utc_now())
      when is_map(data) and is_integer(index) and is_binary(previous_block_hash) and
             is_integer(difficulty) do
    hash = compute_hash(data, index, previous_block_hash, timestamp, 0)
    {nonce, hash} = mine_block(data, index, previous_block_hash, timestamp, difficulty, 0, hash)

    %__MODULE__{
      data: data,
      index: index,
      timestamp: timestamp,
      hash: hash,
      nonce: nonce,
      previous_hash: previous_block_hash
    }
    |> IO.inspect(label: "Block mined")
  end

  defp mine_block(data, index, previous_hash, timestamp, difficulty, nonce, hash) do
    case String.starts_with?(hash, String.duplicate("0", difficulty)) do
      true ->
        {nonce, hash}

      false ->
        nonce = nonce + 1
        hash = compute_hash(data, index, previous_hash, timestamp, nonce)
        mine_block(data, index, previous_hash, timestamp, difficulty, nonce, hash)
    end
  end

  def calculate_hash(%__MODULE__{} = block) do
    compute_hash(block.data, block.index, block.previous_hash, block.timestamp, block.nonce)
  end

  defp compute_hash(data, index, previous_block_hash, timestamp, nonce) do
    body =
      Jason.encode!(data) <>
        Integer.to_string(index) <>
        previous_block_hash <> DateTime.to_string(timestamp) <> Integer.to_string(nonce)

    hash = :crypto.hash(:sha256, body) |> Base.encode16() |> String.downcase()
    hash
  end
end
