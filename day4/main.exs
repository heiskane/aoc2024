defmodule Solver do
  def columns(matrix) do
    Enum.reduce(0..length(matrix) - 1, [], fn i, acc -> 
      [ Enum.reduce(0..length(Enum.at(matrix, i)) - 1, [], fn j, acc -> 
        [ Enum.at(matrix, j)
        |> Enum.at(i) | acc ]
      end) | acc ]
    end)
  end

  def diagonals(matrix) do
    Enum.each(0..(length(matrix) * 2) - 1, fn i -> 
      Enum.each(0..i, fn j -> 
        if i - j < length(matrix) && j < length(matrix) do
          Enum.at(matrix, i - j)
          |> Enum.at(j)
          |> IO.inspect()
        end
      end)
    end)
  end
end

{:ok, input1} = File.read("input_1a.txt")

input1
|> String.split("\n", trim: true)
|> Enum.map(&String.graphemes(&1))
|> tap(&IO.inspect(&1))
|> Solver.columns()
|> IO.inspect()
# |> Solver.diagonals1()
# |> Enum.reverse()
# |> Enum.map(&(Enum.reverse(&1)))
# |> Solver.diagonals()
