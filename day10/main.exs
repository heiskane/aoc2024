{:ok, input} = File.read("input_2.txt")

defmodule Solver do
  def in_bounds(grid, point) do
    dimensions = length(grid) - 1
    (0 <= point.x && point.x <= dimensions) &&
    (0 <= point.y && point.y <= dimensions)
  end

  def apply_direction(point, direction) do
    %{ x: point.x + direction.x, y: point.y + direction.y }
  end

  def find_trail_heads(grid) do
    Enum.with_index(grid)
    |> Enum.reduce([], fn { row, i }, acc1 ->
      Enum.with_index(row)
      |> Enum.reduce(acc1, fn { elem, j }, acc2  ->
        case elem === 0 do
          true -> [ %{ x: i, y: j } | acc2 ]
          false -> acc2
        end
      end)
    end)
  end

  def count_trail_tails(grid, point, score \\ nil) do
    if !Solver.in_bounds(grid, point) do
      []
    else
      current = Enum.at(grid, point.x)
      |> Enum.at(point.y)

      if is_nil(score) || current - score === 1 do
        if current === 9 do
          [ point ]
        else
          Solver.count_trail_tails(grid, Solver.apply_direction(point, %{ x: -1, y: 0 }), current) ++
          Solver.count_trail_tails(grid, Solver.apply_direction(point, %{ x: 0, y: 1 }), current) ++
          Solver.count_trail_tails(grid, Solver.apply_direction(point, %{ x: 1, y: 0 }), current) ++
          Solver.count_trail_tails(grid, Solver.apply_direction(point, %{ x: 0, y: -1 }), current)
        end
      else [] end
    end
  end

  def count_head_rating(grid, point, score \\ nil) do

    if !Solver.in_bounds(grid, point) do 0
    else
      current = Enum.at(grid, point.x)
      |> Enum.at(point.y)

      if is_nil(score) || current - score === 1 do
        if current === 9 do 1 else
          [ Solver.count_head_rating(grid, Solver.apply_direction(point, %{ x: -1, y: 0 }), current),
            Solver.count_head_rating(grid, Solver.apply_direction(point, %{ x: 0, y: 1 }), current),
            Solver.count_head_rating(grid, Solver.apply_direction(point, %{ x: 1, y: 0 }), current),
            Solver.count_head_rating(grid, Solver.apply_direction(point, %{ x: 0, y: -1 }), current)
          ]
          |> Enum.sum()
        end
      else 0 end
    end
  end

  def part1(grid) do
    heads = Solver.find_trail_heads(grid)

    Enum.map(heads, &Solver.count_trail_tails(grid, &1))
    |> Enum.map(&Enum.uniq(&1))
    |> Enum.map(&length/1)
    |> Enum.sum()
  end

  def part2(grid) do
    heads = Solver.find_trail_heads(grid)

    Enum.map(heads, &Solver.count_head_rating(grid, &1))
    |> Enum.sum()
  end
end

{time, result} = :timer.tc(fn ->
  input
  |> String.split("\n", trim: true)
  |> Enum.map(&String.split(&1, "", trim: true))
  |> Enum.map(fn row ->
    Enum.map(row, &String.to_integer/1)
  end)
  |> Solver.part1()
end)

IO.inspect("#{result} (#{time / 1_000}ms)", label: "Part 1")

{time, result} = :timer.tc(fn ->
  input
  |> String.split("\n", trim: true)
  |> Enum.map(&String.split(&1, "", trim: true))
  |> Enum.map(fn row ->
    Enum.map(row, &String.to_integer/1)
  end)
  |> Solver.part2()
end)

IO.inspect("#{result} (#{time / 1_000}ms)", label: "Part 2")
