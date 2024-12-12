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

end

defmodule Solver do
  def next_plant(grid) do
    Enum.with_index(grid)
    |> Enum.reduce_while(nil, fn {row, i}, _acc ->
      case Enum.find_index(row, &(!is_nil(&1))) do
        nil -> {:cont, nil}
        j -> {:halt, { %{ x: i,y: j }, Enum.at(row, j) } }
      end
    end)
  end

  def flood_fill(grid, point, target_plant, region \\ []) do
    if Grid.in_bounds(grid, point) do
      current_plant = Enum.at(grid, point.x) |> Enum.at(point.y)

      if current_plant === target_plant do

        grid = List.update_at(grid, point.x, fn row ->
          List.update_at(row, point.y, fn _ -> nil end)
        end)

        { grid, up } = Solver.flood_fill(grid, %{ x: point.x - 1, y: point.y }, target_plant, region)
        { grid, right } = Solver.flood_fill(grid, %{ x: point.x, y: point.y + 1 }, target_plant, region)
        { grid, down } = Solver.flood_fill(grid, %{ x: point.x + 1, y: point.y }, target_plant, region)
        { grid, left } = Solver.flood_fill(grid, %{ x: point.x, y: point.y - 1 }, target_plant, region)
        { grid, [point] ++ up ++ right ++ down ++ left }

      else { grid, region } end
    else { grid, region } end
  end

  def find_plots(grid) do
    case Solver.next_plant(grid) do
      { next_i, next_plant } ->
        { grid, region } = Solver.flood_fill(grid, next_i, next_plant)
        [ region | Solver.find_plots(grid) ]
      _ -> []
    end
  end


  def calculate_plot_cost(grid, plot) do
    Enum.reduce(plot, 0, fn point, acc2 ->
      curr_plant = Grid.at(grid, point.x, point.y)

      up = Grid.at(grid, point.x - 1, point.y)
      right = Grid.at(grid, point.x, point.y + 1)
      down = Grid.at(grid, point.x + 1, point.y)
      left = Grid.at(grid, point.x, point.y - 1)

      [up, right, down, left]
      |> Enum.reduce(0, fn elem, acc3 -> 
        if elem != curr_plant do
          acc3 + 1 else acc3
        end
      end)
      |> then(&(acc2 + &1))
    end)
  end

  def part1(grid) do
    plots = Solver.find_plots(grid)
    # IO.inspect(plots)
    Enum.map(plots, fn plot -> 
      length(plot) * Solver.calculate_plot_cost(grid, plot)
    end)
    |> Enum.sum()
  end
end

input
|> String.split("\n", trim: true)
|> Enum.map(&String.split(&1, "", trim: true))
|> Solver.part1()
|> IO.inspect()
