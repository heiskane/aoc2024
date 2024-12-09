{:ok, input} = File.read("input_1.txt")

defmodule Solver do
  def parse_blocks(input) do
    Enum.with_index(input)
    |> Enum.flat_map(fn {elem, i} ->
      if rem(i, 2) === 0 do
        List.duplicate(div(i, 2), elem)
      else List.duplicate(nil, elem) end
    end)
  end

  def sort_blocks(blocks) do
    Enum.with_index(blocks)
    |> Enum.reverse()
    |> Enum.reduce(blocks, fn { block, i }, acc ->
      if !is_nil(block) do
        next_nil = Enum.find_index(acc, &(is_nil(&1)))
        if next_nil < i do
          List.replace_at(acc, next_nil, block)
          |> List.replace_at(i, nil)
        else acc end
      else acc end
    end)
  end

  def sort_blocks2(blocks) do
    Enum.with_index(blocks)
    |> Enum.reverse()
    |> Enum.reduce(blocks, fn { block, i }, acc ->
      acc
    end)
  end

  def find_free_block(list, len) do
    Enum.chunk_every(list, len, 1, :discard)
    |> Enum.find_index(fn item ->
      Enum.all?(item, &(is_nil(&1)))
    end)
  end

end

input
|> String.trim("\n")
|> String.split("", trim: true)
|> Enum.map(&String.to_integer(&1))
|> Solver.parse_blocks()
|> Solver.sort_blocks()
|> Enum.filter(&(!is_nil(&1)))
|> Enum.with_index()
|> Enum.map(fn {num, i} -> num * i end)
|> Enum.sum()
|> IO.inspect()

input
|> String.trim("\n")
|> String.split("", trim: true)
|> Enum.map(&String.to_integer(&1))
|> Solver.parse_blocks()
# |> Solver.sort_blocks2()
|> Enum.group_by(&(&1))
# |> tap(&(IO.inspect(&1)))
# |> Enum.filter(&(!is_nil(&1.id)))
# |> Enum.map(&(&1.id * &1.len))
# |> Enum.sum()
|> IO.inspect()
