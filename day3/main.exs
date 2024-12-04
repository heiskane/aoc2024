{:ok, input1} = File.read("input_1b.txt")

Regex.scan(~r/mul\((\d+),(\d+)\)/, input1)
|> Enum.map(fn x -> 
  String.to_integer(Enum.at(x, 2)) * String.to_integer(Enum.at(x, 1))
end)
|> Enum.sum()
|> IO.puts()
