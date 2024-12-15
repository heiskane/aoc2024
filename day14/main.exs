{:ok, input} = File.read("input_2.txt")

defmodule Solver do
  def move_robot([ py, px, vy, vx ], width, height, seconds \\ 0, limit \\ 100) do
    # IO.inspect({py,px,vy,vx})
    # IO.inspect(seconds, label: "seconds")
    # Solver.visualize_robots([{py, px}], width, height)
    if seconds < limit do
      move_robot(
        [ Integer.mod(py + vy, width), Integer.mod(px + vx, height), vy, vx ],
        width, height, seconds + 1, limit
      )
    else { py, px } end
  end

  def visualize_robots(robots, width, height) do
    # IO.inspect(robots, label: "to visualize")
    Enum.map(0..height - 1, fn row ->
      Enum.map(0..width - 1, fn col ->
        if Enum.member?(robots, { col, row }) do
          Enum.count(robots, &(&1 == { col, row }))
          |> Integer.to_string()
        else "." end
      end)
    end)
    |> Enum.join("\n")
    |> IO.puts()
    IO.puts("")
  end

  def calculate_safety_factor(robots, width, height) do
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
end

width = 101
height = 103

input
|> String.split("\n", trim: true)
|> Enum.map(fn robot ->
  Regex.scan(~r/p=(\d+),(\d+)\ v=(-?\d+),(-?\d+)/, robot)
  |> hd
  |> tl
  |> Enum.map(&String.to_integer/1)
end)
|> tap(fn robots ->
  Enum.map(robots, fn [ py, px, _vy, _vx ] ->
    { py, px }
  end)
  |> Solver.visualize_robots(width, height)
end)
|> Enum.map(&Solver.move_robot(&1, width, height))
|> tap(&Solver.visualize_robots(&1, width, height))
|> Solver.calculate_safety_factor(width, height)
|> IO.inspect()
