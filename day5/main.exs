{:ok, input1} = File.read("input_1b.txt")

[rules, updates] = input1
|> String.split("\n\n")
|> (fn [rules, updates] -> [String.split(rules), String.split(updates)] end).()

updates
|> Enum.map(&String.split(&1, ","))
|> Enum.reduce(0, fn x, acc ->
  # IO.inspect(x)
  valid = Enum.reduce(rules, true, fn y, acc ->
    [left, right] = String.split(y, "|")
    left_i = Enum.find_index(x, &(&1 === left))
    right_i = Enum.find_index(x, &(&1 === right))
    # IO.inspect({left, left_i, right, right_i})

    if (!is_nil(left_i) && !is_nil(right_i)) &&
       (left_i > right_i) do false else acc
    end
  end)
  # IO.inspect(valid)
  if valid do
    mid = Integer.floor_div(length(x), 2)
    Enum.at(x, mid)
    |> String.to_integer()
    |> Kernel.+(acc)
  else acc end
end)
|> IO.inspect()

updates
|> Enum.map(&String.split(&1, ","))
|> Enum.reduce(0, fn x, acc ->
  valid = Enum.reduce(rules, true, fn y, acc ->
    [left, right] = String.split(y, "|")
    left_i = Enum.find_index(x, &(&1 === left))
    right_i = Enum.find_index(x, &(&1 === right))

    if (!is_nil(left_i) && !is_nil(right_i)) &&
       (left_i > right_i) do false else acc
    end
  end)

  if valid do acc else
    sorted = Enum.sort(x, fn a, b ->
      [left, right] = Enum.find(rules, &(String.contains?(&1, a) && String.contains?(&1, b)))
      |> String.split("|")
      (a === left && b === right)
    end)

    mid = Integer.floor_div(length(sorted), 2)

    Enum.at(sorted, mid)
    |> String.to_integer()
    |> Kernel.+(acc)
  end
end)
|> IO.inspect()
