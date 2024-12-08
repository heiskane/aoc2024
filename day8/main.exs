{:ok, input} = File.read("input_2.txt")

defmodule Solver do
  def parse_antennas(grid) do
    Enum.with_index(grid)
    |> Enum.reduce(%{}, fn { row, i }, acc1 ->
      Enum.with_index(row)
      |> Enum.reduce(acc1, fn { elem, j }, acc2 ->
        if elem !== "." do
          cords = %{ x: i, y: j}
          Map.update(acc2, elem, [cords], &([ cords | &1 ]))
        else acc2 end
      end)
    end)
  end

  def find_antinodes(antennas) do
    # part1
    Enum.flat_map(antennas, fn {_frequency, locations} ->
      # IO.inspect({frequency, locations})
      Enum.flat_map(locations, fn antenna1 ->
        Enum.map(locations, fn antenna2 ->
          if antenna1 !== antenna2 do
            distance = %{ x: antenna1.x - antenna2.x, y: antenna1.y - antenna2.y }
            %{ x: antenna1.x + distance.x, y: antenna1.y + distance.y }
          else nil end
        end)
      end)
    end)
    |> Enum.filter(&(!is_nil(&1)))
    |> Enum.uniq()
  end

  def count_valid_antinodes(grid) do
    antennas = Solver.parse_antennas(grid)
    IO.inspect(antennas, label: "Antennas")

    antinodes = Solver.find_antinodes(antennas)
    dimensions = length(grid) - 1
    IO.inspect(dimensions, label: "Dimensions")

    # Solver.visualize_antinodes(grid, antinodes)

    Enum.reduce(antinodes, 0, fn antinode, acc ->
      if Solver.in_bounds(antinode, dimensions) do
        # IO.inspect(antinode, label: "Antinode")
        acc + 1
      else acc end
    end)
  end

  def visualize_antinodes(grid, antinodes) do
    # IO.inspect(antinodes)
    dimensions = length(grid) - 1
    Enum.reduce(antinodes, grid, fn antinode, acc ->
      if (0 <= antinode.x && antinode.x <= dimensions)
      && (0 <= antinode.y && antinode.y <= dimensions) do
        # IO.inspect(antinode, label: "Antinode")
        List.update_at(acc, antinode.x, fn row ->
          List.update_at(row, antinode.y, fn _ -> "#" end)
        end)
      else acc end
    end)
    |> Enum.map(&Enum.join/1)
    |> Enum.join("\n")
    |> IO.puts()
  end

  def in_bounds(point, dimensions) do 
    (0 <= point.x && point.x <= dimensions) &&
    (0 <= point.y && point.y <= dimensions)
  end

  def find_valid_points(point1, point2, dimensions) do
    direction = %{ x: point1.x - point2.x, y: point1.y - point2.y }

    # If the input would have 2 antennas on the same horizontal/vertical
    # row more than 1 unit apart we would have to calculate step size
    # divisor = Integer.gcd(direction.x, direction.y)
    # step_x = div(direction.x, divisor)
    # step_y = div(direction.y, divisor)

    Stream.iterate(point1, &(%{ x: &1.x + direction.x, y: &1.y + direction.y }))
    # Stream.iterate(point1, &(%{ x: &1.x + step_x, y: &1.y + step_y }))
    |> Stream.take_while(&Solver.in_bounds(&1, dimensions))
    |> Enum.to_list()
  end

  @doc """
  part2
  """
  def find_resonant_antinodes(grid) do
    dimensions = length(grid) - 1

    # could be more efficient by only iterating over each unique
    # combination of antennas and finding antinodes in both directions
    Solver.parse_antennas(grid)
    |> Enum.flat_map(fn {_freq, locations} ->
      Enum.flat_map(locations, fn antenna1 ->
        Enum.flat_map(locations, fn antenna2 ->
          if antenna1 !== antenna2 do
            Solver.find_valid_points(antenna1, antenna2, dimensions)
          else [] end
        end)
      end)
    end)
    |> Enum.uniq()
    |> tap(&(Solver.visualize_antinodes(grid, &1)))
  end
end

input
|> String.split("\n", trim: true)
|> Enum.map(&String.split(&1, "", trim: true))
# |> tap(&(IO.inspect(&1)))
|> Solver.count_valid_antinodes()
|> IO.inspect()

input
|> String.split("\n", trim: true)
|> Enum.map(&String.split(&1, "", trim: true))
# |> tap(&(IO.inspect(&1)))
|> Solver.find_resonant_antinodes()
|> length()
|> IO.inspect()
