{:ok, input1} = File.read("input_1b.txt")
# {:ok, input1} = File.read("input_test.txt")

defmodule Solver do
  def find_guard(grid) do
    # chatgpt
    Enum.with_index(grid)
    |> Enum.reduce_while(nil, fn {row, x}, _acc ->
      case Enum.find_index(row, &(&1 == "^")) do
        nil -> {:cont, nil}
        y -> {:halt, %{x: x, y: y}}
      end
    end)
  end

  # mimic while loop. not sure what would be more "elixir" way of doing it
  def trace_path(grid, guard, direction \\ %{x: -1, y: 0}, run \\ true) do
    if run && !(guard.x < 0 || guard.y < 0) do
      grid = List.update_at(grid, guard.x, fn row ->
        List.update_at(row, guard.y, fn _ -> "X" end)
      end)

      next = %{x: guard.x + direction.x, y: guard.y + direction.y}

      next_char = case Enum.at(grid, next.x) do
        nil -> nil
        x -> Enum.at(x, next.y)
      end

      cond do
        is_nil(next_char) -> trace_path(grid, guard, direction, false)
        next_char === "#" ->
          new_dir = %{ x: direction.y, y: -direction.x } # turn right
          trace_path(grid, guard, new_dir)
        true -> Solver.trace_path(grid, next, direction)
      end
    else grid end
  end

  # mimic while loop. not sure what would be more "elixir" way of doing it
  def is_infinite(grid, guard, turns \\ [], direction \\ %{x: -1, y: 0}, run \\ true) do
    if run && !(guard.x < 0 || guard.y < 0) do
      next = %{x: guard.x + direction.x, y: guard.y + direction.y}

      next_char = case Enum.at(grid, next.x) do
        nil -> nil
        x -> Enum.at(x, next.y)
      end

      cond do
        is_nil(next_char) -> is_infinite(grid, guard, turns, direction, false)
        next_char === "#" || next_char === "O" ->
          is_loop = Enum.find(turns, &(&1 === %{ cords: guard, dir: direction}))

          if is_loop do
            true
          else
            turns = [ %{ cords: guard, dir: direction } | turns ]
            new_dir = %{ x: direction.y, y: -direction.x } # turn right
            is_infinite(grid, guard, turns, new_dir)
          end
        true -> Solver.is_infinite(grid, next, turns, direction)
      end
    else false end
  end

  def puts_grid(grid) do
    Enum.map(grid, fn row ->
      Enum.join(row, "")
    end)
    |> Enum.join("\n")
    |> IO.puts()
    IO.puts("\n")
  end
end

grid = String.split(input1, "\n", trim: true)
|> Enum.map(&String.split(&1, "", trim: true))

start = Solver.find_guard(grid)

# Solver.trace_path(grid, start)
# |> tap(&(Solver.puts_grid(&1)))
# |> Enum.reduce(0, fn row, acc ->
#   acc + Enum.count(row, &(&1 === "X"))
# end)
# |> IO.puts()

grid
|> Solver.trace_path(start)
|> Enum.with_index(fn row, i ->
  Task.async(fn ->
    Enum.with_index(row, fn char, j ->
      # Only try blocking locations where guard patrols
      if char === "X" && ! %{x: i, y: j} !== start do
        List.update_at(grid, i, fn row ->
          List.update_at(row, j, fn _ -> "O" end)
        end)
        |> Solver.is_infinite(start)
      else false end
    end)
  end)
end)
|> Enum.reduce(0, fn row, acc ->
  Task.await(row)
  |> Enum.count(&(&1 === true))
  |> then(&(&1 + acc))
end)
|> IO.inspect()
