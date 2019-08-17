defmodule BlockchainTest do
  use ExUnit.Case
  alias Blockchain
  alias Blockchain.Block
  @chain_difficulty 3

  test "unmodified chain is valid" do
    {difficulty, chain} = create_valid_chain()
    assert true == Blockchain.is_chain_valid?(chain)
  end

  test "modified block with invalid hash invalides the chain" do
    {difficulty, chain} = create_valid_chain()

    tempered_chain =
      chain
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

    assert false == Blockchain.is_chain_valid?(tempered_chain)
  end

  test "modified block with valid hash invalides the chain" do
    {difficulty, chain} = create_valid_chain()

    tempered_chain =
      chain
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

    assert false == Blockchain.is_chain_valid?(tempered_chain)
  end

  defp create_valid_chain(size \\ 5) do
    1..size
    |> Enum.reduce(Blockchain.new(@chain_difficulty), fn num, {difficulty, acc} ->
      Blockchain.add_new_block({difficulty, acc}, %{
        sender: "crafter",
        receiver: "crafting table",
        message: "Block #{num}"
      })
    end)
  end
end
