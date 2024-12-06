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

end

[rules, updates] = input1
|> String.split("\n\n")
|> (fn [rules, updates] -> [String.split(rules), String.split(updates)] end).()

updates
|> Enum.map(&String.split(&1, ","))
|> Enum.reduce(0, fn x, acc ->
  case Solver.check_validity(rules, x) do
    true -> Solver.get_mid(x) + acc
    false -> acc
  end
end)
|> IO.inspect()

updates
|> Enum.map(&String.split(&1, ","))
|> Enum.reduce(0, fn x, acc ->
  case Solver.check_validity(rules, x) do
    false ->
      Enum.sort(x, fn a, b ->
        [left, right] = Enum.find(rules, &(String.contains?(&1, a) && String.contains?(&1, b)))
        |> String.split("|")
        (a === left && b === right)
      end)
      |> Solver.get_mid()
      |> Kernel.+(acc)
    true -> acc
  end
end)
|> IO.inspect()
