{:ok, input1} = File.read("input_1b.txt")

defmodule Solver do

  def check_validity(rules, update) do
    Enum.reduce(rules, true, fn y, acc ->
      [left, right] = String.split(y, "|")
      left_i = Enum.find_index(update, &(&1 === left))
      right_i = Enum.find_index(update, &(&1 === right))

      if (!is_nil(left_i) && !is_nil(right_i)) &&
         (left_i > right_i) do false else acc
      end
    end)
  end

  def get_mid(update) do
    mid = Integer.floor_div(length(update), 2)
    Enum.at(update, mid)
    |> String.to_integer()
  end

  def sort_update(rules, update) do
    Enum.sort(update, fn a, b ->
      Enum.find(rules, &(String.contains?(&1, a) && String.contains?(&1, b)))
      |> String.split("|")
      |> then(&(&1 === [a, b]))
    end)
  end

end

[rules, updates] = input1
|> String.split("\n\n")
|> Enum.map(&String.split(&1))

updates
|> Enum.map(&String.split(&1, ","))
|> Enum.filter(&Solver.check_validity(rules, &1))
|> Enum.map(&Solver.get_mid(&1))
|> Enum.sum()
|> IO.puts()

updates
|> Enum.map(&String.split(&1, ","))
|> Enum.reject(&Solver.check_validity(rules, &1))
|> Enum.map(&Solver.sort_update(rules, &1))
|> Enum.map(&Solver.get_mid(&1))
|> Enum.sum()
|> IO.puts()
