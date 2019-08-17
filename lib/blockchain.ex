defmodule Blockchain do
  alias Blockchain.Block

  @moduledoc """
  Basic blockchain implementation.
  Based on: https://www.youtube.com/watch?v=XSJXrCSQaWw
  """

  def new(difficulty) do
    genesis_block = create_genesis_block()
    {difficulty, [genesis_block]}
  end

  defp create_genesis_block() do
    Block.new(%{genesis: true}, 0, "0", 0)
  end

  def get_last_block(chain) do
    List.last(chain)
  end

  def add_new_block({difficulty, chain}, block_data)
      when is_integer(difficulty) and is_list(chain) and is_map(block_data) do
    last_block = get_last_block(chain)
    new_index = last_block.index + 1
    new_block = Block.new(block_data, new_index, last_block.hash, difficulty)
    {difficulty, chain ++ [new_block]}
  end

  def is_chain_valid?([_h | _t] = chain) when is_list(chain) do
    with true <- check_block_validity(chain),
         true <- check_previous_hash_validity(chain) do
      IO.puts("Chain is valid")
      true
    else
      false ->
        IO.puts("Chain is invalid")
        false
    end
  end

  def is_chain_valid?([_h]) do
    false
  end

  def is_chain_valid?([]) do
    false
  end

  defp check_block_validity(chain) do
    chain
    |> Enum.all?(fn block ->
      case block.hash == Block.calculate_hash(block) do
        true ->
          true

        false ->
          IO.puts("Block #{block.index} has been corrupted. Hash doesn't match the data")
          false
      end
    end)
  end

  defp check_previous_hash_validity([_h | t] = chain) do
    Enum.zip(t, chain)
    |> Enum.all?(fn {current_block, previous_block} ->
      case current_block.previous_hash == previous_block.hash do
        false ->
          IO.puts(
            "Block #{previous_block.index} has been corrupted. Expected hash: #{
              current_block.previous_hash
            } but got: #{previous_block.hash}"
          )

          false

        true ->
          true
      end
    end)
  end
end
