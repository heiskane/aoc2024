{:ok, input} = File.read("input_2.txt")

defmodule Solver do
  def parse_antennas(grid) do
    Enum.with_index(grid)
    |> Enum.reduce(%{}, fn {row, i}, acc1 ->
      Enum.with_index(row)
      |> Enum.reduce(acc1, fn {elem, j}, acc2 ->
        if elem !== "." do
          cords = %{ x: i, y: j}
          Map.update(acc2, elem, [cords], fn list ->
            [ cords | list ]
          end)
        else acc2 end
      end)
    end)
  end

  def find_antinodes(antennas) do
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

    Solver.visualize_antinodes(grid, antinodes)

    Enum.reduce(antinodes, 0, fn antinode, acc ->
      if (0 <= antinode.x && antinode.x <= dimensions)
      && (0 <= antinode.y && antinode.y <= dimensions) do
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

  def find_valid_points(point1, point2, dimensions) do
    direction = %{ x: point1.x - point2.x, y: point1.y - point2.y }
    divisor = Integer.gcd(direction.x, direction.y)
    step_x = div(direction.x, divisor)
    step_y = div(direction.y, divisor)
    # IO.inspect({step_x, step_y})

    antinodes = Stream.iterate(%{ x: point1.x + 1 * step_x, y: point1.y + 1 * step_y}, fn point ->
      %{ x: point.x + 1 * step_x, y: point.y + 1 * step_y }
    end)
    |> Stream.take_while(fn point ->
      (0 <= point.x && point.x <= dimensions) &&
      (0 <= point.y && point.y <= dimensions)
    end)
    |> Enum.to_list()
  end

  def find_resonant_antinodes(grid) do
    antennas = Solver.parse_antennas(grid)
    dimensions = length(grid) - 1

    antinodes = find_antinodes(antennas)
    |> Enum.filter(&( (0 <= &1.x && &1.x <= dimensions)
      && (0 <= &1.y && &1.y <= dimensions) ))

    resonant_antinodes = Enum.flat_map(antennas, fn {_freq, locations} ->
      Enum.flat_map(locations, fn antenna1 ->
        Enum.flat_map(locations, fn antenna2 ->
          if antenna1 !== antenna2 do
            Solver.find_valid_points(antenna1, antenna2, dimensions)
          else [] end
        end)
      end)
    end)
    |> Enum.filter(&(!is_nil(&1)))
    |> Enum.uniq()

    all_antennas = Enum.reduce(antennas, [], fn {_freq, locations}, acc -> [ locations | acc ] end)
    all_antinodes = List.flatten([antinodes, resonant_antinodes, all_antennas])
    |> Enum.uniq()


    Solver.visualize_antinodes(grid, all_antinodes)

    IO.inspect(length(all_antinodes))
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
# |> IO.inspect()
