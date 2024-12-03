{:ok, input1} = File.read("input_1b.txt")

defmodule Solver do
  def solve(items) do
    direction = cond do
      hd(items) === hd(tl(items)) -> nil
      hd(items) > hd(tl(items)) -> :down
      hd(items) < hd(tl(items)) -> :up
    end

    if is_nil(direction) do
      false
    else
      asdf = Enum.reduce(items, %{result: true, prev: nil}, fn item, acc ->
        if is_nil(acc[:prev]) || acc[:result] === false do
          %{ acc | prev: item}
        else
          result = cond do
            item === acc[:prev] -> false
            item > acc[:prev] && direction === :down -> false
            item < acc[:prev] && direction === :up -> false
            abs(item - acc[:prev]) > 3 -> false
            abs(item - acc[:prev]) < 1 -> false
            true -> true
          end
          %{acc | result: result, prev: item}
        end
      end)
      Map.get(asdf, :result)
    end
  end

  def solve2(items) do
    # Idea yoinked from: https://github.com/nitekat1124/advent-of-code-2024/blob/main/solutions/day02.py
    diffs = Enum.zip_reduce([items, tl items], [], fn [a, b], acc ->
      [ a - b | acc ]
    end)
    (Enum.all?(diffs, fn x -> x > 0 end) || Enum.all?(diffs, fn x -> x < 0 end)) &&
      Enum.all?(diffs, fn x -> 1 <= abs(x) && abs(x) <= 3 end)
  end

  def solve_part2(items) do
    if Solver.solve2(items) do
      true
    else
      Enum.with_index(items)
      |> Enum.map(fn {_, index} ->
        Solver.solve2(List.delete_at(items, index))
      end)
      |> Enum.any?()
    end
  end

end
input1
|> String.split("\n", trim: true)
|> Enum.map(fn x ->
  x |> String.split(" ")
    |> Enum.map(fn x -> String.to_integer(x) end)
    |> Solver.solve2()
end)
|> Enum.count(fn item -> item === true end)
|> IO.puts()

{:ok, input2} = File.read("input_2b.txt")

input2
|> String.split("\n", trim: true)
|> Enum.map(fn x ->
  x |> String.split(" ")
    |> Enum.map(fn x -> String.to_integer(x) end)
    |> Solver.solve_part2()
end)
|> Enum.count(fn item -> item === true end)
|> IO.puts()
