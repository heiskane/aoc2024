{:ok, input} = File.read("input_2.txt")

defmodule Solver do
  def move_robot([ py, px, vy, vx ], width, height, limit \\ 100, seconds \\ 0) do
    # IO.inspect({py,px,vy,vx})
    # IO.inspect(seconds, label: "seconds")
    # Solver.visualize_robots([{py, px}], width, height)
    if seconds < limit do
      move_robot(
        [ Integer.mod(py + vy, width), Integer.mod(px + vx, height), vy, vx ],
        width, height, limit, seconds + 1
      )
    else [ py, px, vy, vx ] end
  end

  def visualize_robots(robots, width, height) do
    robots = Enum.map(robots, fn [py, px, vy, vx] -> { py, px } end)
    # IO.inspect(robots, label: "to visualize")
    visualized = Enum.map(0..height - 1, fn row ->
      Enum.map(0..width - 1, fn col ->
        if Enum.member?(robots, { col, row }) do
          Enum.count(robots, &(&1 == { col, row }))
          |> Integer.to_string()
        else "." end
      end)
    end)
    |> Enum.join("\n")

    asdf = visualized
    |> String.split("111")
    |> length()

    if asdf - 1 >= 3 do
      IO.puts("FOUND")
      IO.puts(visualized)
    end

    # IO.puts(visualized)
    # IO.puts("")
  end

  def calculate_safety_factor(robots, width, height) do
    robots = Enum.map(robots, fn [py, px, vy, vx] -> { py, px } end)
    top_left = Enum.reduce(0..div(height, 2) - 1, 0, fn x, acc1 ->
      Enum.reduce(0..div(width, 2) - 1, acc1, fn y, acc2 ->
        acc2 + Enum.count(robots, &(&1 === { y, x }))
      end)
    end)
    top_right = Enum.reduce(0..div(height, 2) - 1, 0, fn x, acc1 ->
      Enum.reduce(div(width, 2) + 1..width, acc1, fn y, acc2 ->
        acc2 + Enum.count(robots, &(&1 === { y, x }))
      end)
    end)
    bottom_right = Enum.reduce(div(height, 2) + 1..height, 0, fn x, acc1 ->
      Enum.reduce(div(width, 2) + 1..width, acc1, fn y, acc2 ->
        acc2 + Enum.count(robots, &(&1 === { y, x }))
      end)
    end)
    bottom_left = Enum.reduce(div(height, 2) + 1..height, 0, fn x, acc1 ->
      Enum.reduce(0..div(width, 2) - 1, acc1, fn y, acc2 ->
        acc2 + Enum.count(robots, &(&1 === { y, x }))
      end)
    end)

    # IO.inspect({top_left, top_right, bottom_right, bottom_left})

    [ top_left, top_right, bottom_right, bottom_left ]
    |> Enum.product()
  end

  # spaghetti.
  # pipe to file or something and grep for 1111111111111111
  def part2?(robots, width, height) do
    Enum.reduce(0..10_000, robots, fn i, robots -> 
      IO.puts("iteration #{i}")
      Enum.map(robots, &Solver.move_robot(&1, width, height, 1))
      |> tap(&Solver.visualize_robots(&1, width, height))
    end)
  end
end

width = 101
height = 103

# input
# |> String.split("\n", trim: true)
# |> Enum.map(fn robot ->
#   Regex.scan(~r/p=(\d+),(\d+)\ v=(-?\d+),(-?\d+)/, robot)
#   |> hd
#   |> tl
#   |> Enum.map(&String.to_integer/1)
# end)
# |> tap(&Solver.visualize_robots(&1, width, height))
# |> Enum.map(&Solver.move_robot(&1, width, height))
# |> tap(&Solver.visualize_robots(&1, width, height))
# |> Solver.calculate_safety_factor(width, height)
# |> IO.inspect()

input
|> String.split("\n", trim: true)
|> Enum.map(fn robot ->
  Regex.scan(~r/p=(\d+),(\d+)\ v=(-?\d+),(-?\d+)/, robot)
  |> hd
  |> tl
  |> Enum.map(&String.to_integer/1)
end)
|> Solver.part2?(width, height)
