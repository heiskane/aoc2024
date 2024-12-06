# {:ok, input1} = File.read("input_1a.txt")
{:ok, input1} = File.read("input_test.txt")

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

  def trace_path(grid, guard, direction, run) do
    IO.inspect({guard, direction})
    if run do
      new_grid = List.update_at(grid, guard.x, fn row ->
        List.update_at(row, guard.y, fn _ -> "X" end)
      end)

      next = %{x: guard.x + direction.x, y: guard.y + direction.y}

      next_char = case Enum.at(grid, next.x) do
        nil -> nil
        x -> Enum.at(x, next.y)
      end

      cond do
        is_nil(next_char) -> trace_path(new_grid, guard, direction, false)
        next_char === "#" ->
          new_dir = %{ x: direction.y, y: -direction.x } # turn right
          trace_path(new_grid, guard, new_dir, run)
        true -> Solver.trace_path(new_grid, next, direction, run)
      end
    else grid end
  end
end

grid = String.split(input1, "\n", trim: true)
|> Enum.map(&String.split(&1, "", trim: true))

start = Solver.find_guard(grid)
direction = %{x: -1, y: 0}

# IO.inspect(grid)
# IO.inspect({start, direction})

Solver.trace_path(grid, start, direction, true)
|> tap(&(IO.inspect(&1, limit: :infinity)))
|> Enum.reduce(0, fn row, acc ->
  acc + Enum.count(row, &(&1 === "X"))
end)
|> IO.inspect()
