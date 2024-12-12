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

  def count_corners(point, points) do
    top_left = %{ x: point.x - 1, y: point.y - 1 } # top-left
    top_right = %{ x: point.x - 1, y: point.y + 1 } # top-right
    bottom_left = %{ x: point.x + 1, y: point.y - 1 } # bottom-left
    bottom_right = %{ x: point.x + 1, y: point.y + 1 }  # bottom-right

    above = %{ x: point.x - 1, y: point.y} # above
    below = %{ x: point.x + 1, y: point.y} # below
    left = %{ x: point.x, y: point.y - 1} # left
    right = %{ x: point.x, y: point.y + 1}  # right

    # TODO: have to go to sleep in 10min so aint got the time to cleanup
    corners = 0
    corners = corners + if (Enum.member?(points, top_left) && (!Enum.member?(points, above) && !Enum.member?(points, left)))
      || (!Enum.member?(points, top_left) && (Enum.member?(points, above) && Enum.member?(points, left)))
      || (!Enum.member?(points, top_left) && (!Enum.member?(points, above) && !Enum.member?(points, left)))
    do 1
    else 0 end

    corners = corners + if (Enum.member?(points, top_right) && (!Enum.member?(points, above) && !Enum.member?(points, right)))
      || (!Enum.member?(points, top_right) && (Enum.member?(points, above) && Enum.member?(points, right)))
      || (!Enum.member?(points, top_right) && (!Enum.member?(points, above) && !Enum.member?(points, right)))
    do 1
    else 0 end

    corners = corners + if (Enum.member?(points, bottom_right) && (!Enum.member?(points, below) && !Enum.member?(points, right)))
      || (!Enum.member?(points, bottom_right) && (Enum.member?(points, below) && Enum.member?(points, right)))
      || (!Enum.member?(points, bottom_right) && (!Enum.member?(points, below) && !Enum.member?(points, right)))
    do 1
    else 0 end

    corners = corners + if (Enum.member?(points, bottom_left) && (!Enum.member?(points, below) && !Enum.member?(points, left)))
      || (!Enum.member?(points, bottom_left) && (Enum.member?(points, below) && Enum.member?(points, left)))
      || (!Enum.member?(points, bottom_left) && (!Enum.member?(points, below) && !Enum.member?(points, left)))
    do 1
    else 0 end

    # IO.inspect({point, corners}, label: "corners")
    corners
  end

  def part1(grid) do
    plots = Solver.find_plots(grid)
    # IO.inspect(plots)
    Enum.map(plots, fn plot ->
      length(plot) * Solver.calculate_plot_cost(grid, plot)
    end)
    |> Enum.sum()
  end

  def part2(grid) do
    plots = Solver.find_plots(grid)
    # IO.inspect(plots)

    # Enum.map(hd(plots), &Solver.count_corners(&1, hd(plots)))
    # |> Enum.sum()
    # |> IO.inspect()

    plots
    |> Enum.reduce(0, fn plot, acc ->
      Enum.map(plot, &Solver.count_corners(&1, plot))
      |> Enum.sum()
      # |> tap(&IO.inspect({length(plot), &1}, label: "corners"))
      |> then(&(length(plot) * &1))
      |> then(&(acc + &1))
    end)
    |> IO.inspect(label: "corners")
  end
end

input
|> String.split("\n", trim: true)
|> Enum.map(&String.split(&1, "", trim: true))
|> Solver.part1()
|> IO.inspect()

input
|> String.split("\n", trim: true)
|> Enum.map(&String.split(&1, "", trim: true))
|> Solver.part2()
|> IO.inspect()
