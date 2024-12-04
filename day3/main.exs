defmodule Solver do
  def consume_string(string, enabled \\ true)
  def consume_string(string, enabled) when string === "" do 0 end
  def consume_string(string, enabled) do
    {char, rest} = String.next_codepoint(string)
    cond do
      enabled && String.starts_with?(string, "mul") ->
        case Regex.run(~r/^mul\((\d+),(\d+)\)/, string) do
          [match, a, b] -> consume_string(rest, enabled) + String.to_integer(a) * String.to_integer(b)
          nil -> consume_string(rest, enabled)
        end

      !enabled && String.starts_with?(string, "do()") ->
        consume_string(rest, true)
      enabled && String.starts_with?(string, "don't()") ->
        consume_string(rest, false)
      true -> consume_string(rest, enabled)
    end
  end
end

{:ok, input1} = File.read("input_1b.txt")

Regex.scan(~r/mul\((\d+),(\d+)\)/, input1)
|> Enum.map(fn x ->
  String.to_integer(Enum.at(x, 2)) * String.to_integer(Enum.at(x, 1))
end)
|> Enum.sum()
|> IO.puts()

{:ok, input2} = File.read("input_1b.txt")
input2
|> Solver.consume_string()
|> IO.inspect()
