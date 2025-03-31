{:ok, input1} = File.read("input.txt")
# {:ok, input1} = File.read("input_test.txt")

defmodule Point do
  defstruct x: 0, y: 0
  def new(x \\ 0, y \\ 0), do: %Point{x: x, y: y}

  def add(%Point{x: x1, y: y1}, %Point{x: x2, y: y2}) do
    %Point{x: x1 + x2, y: y1 + y2}
  end

  def subtract(%Point{x: x1, y: y1}, %Point{x: x2, y: y2}) do
    %Point{x: x1 - x2, y: y1 - y2}
  end
end

defmodule Grid do
  defmacro in_bounds(grid, x, y) do
    quote do
      (0 <= unquote(x) and unquote(x) <= length(unquote(grid)) - 1) and
      (0 <= unquote(y) and unquote(y) <= length(hd(unquote(grid))) - 1)
    end
  end

  def at(grid, %Point{x: x, y: y}) when not in_bounds(grid, x, y), do: nil
  def at(grid, %Point{x: x, y: y}) do Enum.at(grid, x) |> Enum.at(y) end

  def find(grid, element) do
    Enum.with_index(grid)
    |> Enum.reduce_while(nil, fn {row, x}, _acc ->
      case Enum.find_index(row, &(&1 == element)) do
        nil -> {:cont, nil}
        y -> {:halt, Point.new(x, y)}
      end
    end)
  end

  def update_at(grid, %Point{x: x, y: y}, new) do
    List.update_at(grid, x, fn row ->
      List.update_at(row, y, fn _ -> new end)
    end)
  end
end

defmodule Solver do
  def trace_path(grid, guard, direction \\ Point.new(-1, 0))
  def trace_path(grid, guard, _) when guard.x < 0 or guard.y < 0, do: grid
  def trace_path(grid, guard, direction) do
    grid = Grid.update_at(grid, guard, "X")
    next = Point.add(guard, direction)

    case Grid.at(grid, next) do
      nil -> grid
      "#" -> trace_path(grid, guard, Point.new(direction.y, -direction.x))  # turn right
      _ -> Solver.trace_path(grid, next, direction)
    end
  end

  def is_infinite(grid, guard, turns \\ [], direction \\ Point.new(-1, 0))
  def is_infinite(_, guard, _, _) when guard.x < 0 or guard.y < 0, do: false
  def is_infinite(grid, guard, turns, direction) do
    next = Point.add(guard, direction)

    case Grid.at(grid, next) do
      nil -> grid
      char when char in ["#", "O"] ->
        is_loop = Enum.find(turns, &(&1 === %{ cords: guard, dir: direction}))

        if is_loop do
          true
        else
          turns = [ %{ cords: guard, dir: direction } | turns ]
          new_dir = Point.new(direction.y, -direction.x)  # turn right
          is_infinite(grid, guard, turns, new_dir)
        end
      _ -> Solver.is_infinite(grid, next, turns, direction)
    end
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

start = Grid.find(grid, "^")

Solver.trace_path(grid, start)
# |> tap(&(Solver.puts_grid(&1)))
|> Enum.reduce(0, fn row, acc ->
  acc + Enum.count(row, &(&1 === "X"))
end)
|> IO.puts()

grid
|> Solver.trace_path(start)
|> Enum.with_index(fn row, i ->
  Task.async(fn ->
    Enum.with_index(row, fn char, j ->
      current_point = Point.new(i, j)
      # Only try blocking locations where guard patrols
      if char === "X" && ! current_point !== start do
        Grid.update_at(grid, current_point, "O")
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
