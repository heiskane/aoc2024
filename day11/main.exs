{:ok, input} = File.read("input_2.txt")

defmodule Solver do

  def num_len(num) when num === 0 do 1 end
  def num_len(num) do trunc(:math.floor(:math.log10(abs(num))) + 1) end

  # https://stackoverflow.com/a/32016977
  def split_stone(stone) do
    len = Solver.num_len(stone)
    left = div(stone, trunc(:math.pow(10, div(len, 2))))
    right = trunc(stone - left * :math.pow(10, div(len, 2)))
    {left, right}
  end

  def blink(stones) do
    Enum.reduce(stones, [], fn stone, acc ->
      if stone === 0 do
        [ 1 | acc ]
      else
        if rem(Solver.num_len(stone), 2) === 0 do
          {left, right} = Solver.split_stone(stone)
          [ left, right | acc ]
        else
          [ stone * 2024 | acc ]
        end
      end
    end)
  end

  def solve(stones, target_count, count \\ 0) do
    IO.inspect(length(stones), label: "stone count")
    IO.inspect(count, label: "blinking count")
    if count < target_count do
      # TODO: can we chunk the massive list into something more manageable
      # TODO: try using maps or something
      Solver.blink(stones)
      # |> tap(&(IO.inspect(&1, pretty: false, limit: :infinity)))
      |> Solver.solve(target_count, count + 1)
    else stones end
  end
end

{time, result} = :timer.tc(fn ->
input
  |> String.trim("\n")
  |> String.split(" ")
  |> Enum.map(&String.to_integer/1)
  |> Solver.solve(25)
  |> length()
  |> IO.inspect()
end)

IO.inspect("#{result} (#{time / 1_000}ms)", label: "Part 1")

# {time, result} = :timer.tc(fn ->
#   input
#   |> String.trim("\n")
#   |> String.split(" ")
#   |> Enum.map(&String.to_integer/1)
#   |> Solver.solve(75)
#   |> length()
# end)
#
# IO.inspect("#{result} (#{time / 1_000}ms)", label: "Part 2")
