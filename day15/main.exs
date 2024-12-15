{:ok, input} = File.read("input_2.txt")

defmodule Grid do
  def at(grid, x, y) do
    if Grid.in_bounds(grid, %{ x: x, y: y }) do
      case Enum.at(grid, x) do
        nil -> nil
        row -> Enum.at(row, y)
      end
    end
  end

  def in_bounds(grid, point) do
    dimensions = length(grid) - 1
    (0 <= point.x && point.x <= dimensions) &&
    (0 <= point.y && point.y <= dimensions)
  end

  def find(grid, element) do
    Enum.with_index(grid)
    |> Enum.reduce_while(nil, fn {row, x}, _acc ->
      case Enum.find_index(row, &(&1 == element)) do
        nil -> {:cont, nil}
        y -> {:halt, %{x: x, y: y}}
      end
    end)
  end

  def update_at(grid, x, y, new) do
    List.update_at(grid, x, fn row ->
      List.update_at(row, y, fn _ -> new end)
    end)
  end
end

defmodule Solver do
  def move_block(grid, block, direction) do
    next_pos = %{ x: block.x + direction.x, y: block.y + direction.y }
    next = Grid.at(grid, next_pos.x, next_pos.y)
    current = Grid.at(grid, block.x, block.y)
    # IO.inspect({current, next, block, direction})

    case next do
      "#" -> { false, grid }
      "." ->
        grid = Grid.update_at(grid, block.x, block.y, ".")
        |> Grid.update_at(next_pos.x, next_pos.y, current)
        { true, grid }
      "O" ->
        case move_block(grid, next_pos, direction) do
          { false, grid } -> { false, grid }
          { true, grid } ->
            grid = Grid.update_at(grid, block.x, block.y, ".")
            |> Grid.update_at(next_pos.x, next_pos.y, current)
            { true, grid }
        end
    end
  end

  def apply_moves(map, moves) do
    Enum.reduce(moves, map, fn move, map ->
      direction = case move do
        "^" -> %{ x: -1, y: 0 }
        ">" -> %{ x: 0, y: 1 }
        "v" -> %{ x: 1, y: 0 }
        "<" -> %{ x: 0, y: -1 }
      end

      # not very optimal but whatever
      robot = map
      |> Grid.find("@")

      # IO.puts("")
      # IO.puts("Move: #{move}")
      { _moved, map } = Solver.move_block(map, robot, direction)

      # Enum.join(map, "\n")
      # |> IO.puts()

      map
    end)
  end

  def calculate_points(map) do
    Enum.reduce(0..length(map) - 1, 0, fn i, acc1 ->
      acc1 + Enum.reduce(0..length(map) - 1, 0, fn j, acc2 ->
        if Grid.at(map, i, j) === "O" do
          acc2 + (100 * i + j)
        else acc2 end
      end)
    end)
  end

  def part1(map, moves) do
    map = Solver.apply_moves(map, moves)
    result = Solver.calculate_points(map)
    IO.puts("Part1: #{result}")
  end
end

[ map, moves ] = input
|> String.split("\n\n", trim: true)

map = map
|> String.split("\n", trim: true)
|> Enum.map(&String.split(&1, "", trim: true))

moves = moves
|> String.split("\n", trim: true)
|> Enum.flat_map(&String.split(&1, "", trim: true))

Solver.part1(map, moves)
