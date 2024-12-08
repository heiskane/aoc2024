{:ok, input} = File.read("input_1.txt")

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
    Enum.flat_map(antennas, fn {frequency, locations} ->
      IO.inspect({frequency, locations})
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
  end

  def count_valid_antinodes(grid) do
    antennas = Solver.parse_antennas(grid)
    IO.inspect(antennas, label: "Antennas")

    antinodes = Solver.find_antinodes(antennas)
    dimensions = length(grid) - 1
    IO.inspect(dimensions, label: "Dimensions")

    Solver.visualize_antinodes(grid, antinodes)

    Enum.uniq(antinodes)
    |> Enum.reduce(0, fn antinode, acc ->
      if (0 <= antinode.x && antinode.x <= dimensions) 
      && (0 <= antinode.y && antinode.y <= dimensions) do
        # IO.inspect(antinode, label: "Antinode")
        acc + 1
      else acc end
    end)
  end

  def visualize_antinodes(grid, antinodes) do
    IO.inspect(antinodes)
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
end

input
|> String.split("\n", trim: true)
|> Enum.map(&String.split(&1, "", trim: true))
# |> tap(&(IO.inspect(&1)))
|> Solver.count_valid_antinodes()
|> IO.inspect()
