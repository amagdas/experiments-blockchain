defmodule BlockchainTest do
  use ExUnit.Case
  alias Blockchain
  alias Blockchain.Block

  test "unmodified chain is valid" do
    chain = create_valid_chain()
    assert true == Blockchain.is_chain_valid?(chain)
  end

  test "modified block with invalid hash invalides the chain" do
    chain =
      create_valid_chain()
      |> Enum.map(fn block ->
        if block.index == 3 do
          %Block{
            block
            | data: %{block.data | message: "This block is tampered with."}
          }
        else
          block
        end
      end)

    assert false == Blockchain.is_chain_valid?(chain)
  end

  test "modified block with valid hash invalides the chain" do
    chain =
      create_valid_chain()
      |> Enum.map(fn block ->
        if block.index == 3 do
          tempered_block = %Block{
            block
            | data: %{block.data | message: "This block is tampered with."}
          }

          %Block{tempered_block | hash: Block.calculate_hash(tempered_block)}
        else
          block
        end
      end)

    assert false == Blockchain.is_chain_valid?(chain)
  end

  defp create_valid_chain() do
    1..5
    |> Enum.reduce(Blockchain.new(), fn num, acc ->
      Blockchain.add_new_block(acc, %{
        sender: "crafter",
        receiver: "crafting table",
        message: "Block #{num}"
      })
    end)
  end
end
