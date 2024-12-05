defmodule Solver do
  def columns(matrix) do
    Enum.reduce(0..length(matrix) - 1, [], fn i, acc ->
      column = Enum.reduce(0..length(Enum.at(matrix, i)) - 1, [], fn j, acc ->
        elem = Enum.at(matrix, j)
        |> Enum.at(i)
        [ elem | acc ]
      end)
      [ column | acc ]
    end)
  end

  def diagonals(matrix) do
    Enum.reduce(0..(length(matrix) * 2) - 1, [], fn i, acc ->
      diag = Enum.reduce(0..i, [], fn j, acc ->
        if i - j < length(matrix) && j < length(matrix) do
          elem = Enum.at(matrix, i - j)
          |> Enum.at(j)
          [ elem | acc ]
        else
          acc
        end
      end)
      [ diag | acc ]
    end)
  end
end

{:ok, input1} = File.read("input_1b.txt")

input1
|> String.split("\n", trim: true)
|> Enum.map(&String.graphemes(&1))
|> (fn x ->
  columns = Solver.columns(x)
  diags = Solver.diagonals(x)
  rev_diags = Enum.reverse(x) |> Solver.diagonals()
  x ++ columns ++ diags ++ rev_diags
end).()
|> Enum.map(&(Enum.join(&1, "")))
|> Enum.map(&(
  (length(String.split(&1, "XMAS")) - 1) +
  (length(String.split(&1, "SAMX")) - 1)
))
|> Enum.sum()
|> IO.inspect()
