{:ok, input} = File.read("input_1b.txt")

input
|> String.split("\n", trim: true)
|> Enum.reduce([[], []], fn x, acc ->
  [a1, a2] = x |> String.split("   ")
  [acc1, acc2] = acc
  [[String.to_integer(a1) | acc1], [String.to_integer(a2) | acc2]]
end)
|> Enum.map(fn x -> Enum.sort(x) end)
# |> Enum.zip()
# |> Enum.map(fn {x, y} -> abs(x - y) end)
# |> Enum.sum()
|> Enum.zip_reduce(0, fn [x, y], acc ->
  acc + abs(x - y)
end)
|> IO.puts()

input
|> String.split("\n", trim: true)
|> Enum.reduce([[], []], fn x, acc ->
  [a1, a2] = x |> String.split("   ")
  [acc1, acc2] = acc
  [[String.to_integer(a1) | acc1], [String.to_integer(a2) | acc2]]
end)
|> (fn [a, b] ->
  Enum.map(a, fn x ->
    Enum.count(b, fn item -> item == x end) * x
  end)
end).()
|> Enum.sum()
|> IO.puts()
