{:ok, input} = File.read("input_1b.txt")

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

input
|> String.split("\n", trim: true)
|> Enum.map(fn x ->
  x |> String.split(" ")
    |> Enum.map(&String.to_integer(&1))
    |> Solver.solve2()
end)
|> Enum.count(&(&1 === true))
|> IO.puts()

input
|> String.split("\n", trim: true)
|> Enum.map(fn x ->
  x |> String.split(" ")
    |> Enum.map(&String.to_integer(&1))
    |> Solver.solve_part2()
end)
|> Enum.count(&(&1 === true))
|> IO.puts()
