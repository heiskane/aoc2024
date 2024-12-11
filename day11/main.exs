{:ok, input} = File.read("input_2.txt")

defmodule Solver do
  def blink(stones) do
    Enum.reduce(stones, [], fn stone, acc ->
      if stone === "0" do
        acc ++ ["1"]
      else
        if rem(String.length(stone), 2) === 0 do
          {left, right} = String.split_at(stone, div(String.length(stone), 2))

          # This spaghetti is to trim leading zeroes
          left = String.to_integer(left)
          right = String.to_integer(right)

          acc ++ [Integer.to_string(left), Integer.to_string(right)]
        else
          num = String.to_integer(stone)
          acc ++ [Integer.to_string(num * 2024)]
        end
      end
    end)
  end

  def solve(stones, target_count, count \\ 0) do
    if count < target_count do
      Solver.blink(stones)
      # |> tap(&(IO.inspect(&1, pretty: false, limit: :infinity)))
      |> Solver.solve(target_count, count + 1)
    else stones end
  end
end

input
|> String.trim("\n")
|> String.split(" ")
# |> Solver.blink()
|> Solver.solve(25)
# |> Solver.solve(75)
|> length()
|> IO.inspect()
