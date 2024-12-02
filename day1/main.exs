{:ok, input1} = File.read("input_1b.txt")

# input
# |> String.split("\n", trim: true)
# |> Enum.map(fn (x) -> x |> String.split("   ") end)
# |> Enum.map(&IO.puts/1)

# list1 = []
# list2 = []
#
# asdf = input
# |> String.split("\n", trim: true)
# |> Enum.map(fn (x) ->
#     # IO.inspect(x)
#   [a1, a2] = x |>
#   String.split("   ")
#   # IO.puts([a1 | []])
#   # IO.puts(a2)
#   list1 = [a1 | list1]
#   list2 = [a2 | list2]
# end)

# IO.inspect(list1)
# IO.inspect(list2)
# IO.inspect(asdf)

result = input1
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

IO.puts(result)

{:ok, input2} = File.read("input_2b.txt")

[left, right] = input2
|> String.split("\n", trim: true)
|> Enum.reduce([[], []], fn x, acc ->
  [a1, a2] = x |> String.split("   ")
  [acc1, acc2] = acc
  [[String.to_integer(a1) | acc1], [String.to_integer(a2) | acc2]]
end)

result = left
|> Enum.map(fn x -> 
  Enum.count(right, fn item -> item == x end) * x
end)
|> Enum.sum()

IO.puts(result)
