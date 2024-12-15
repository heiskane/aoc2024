{:ok, input} = File.read("input_2.txt")

defmodule Solver do
  def find_a_presses(ax, ay, bx, by, x, y, presses \\ 0, limit \\ 100) do
    if x == 0 && y == 0 do presses else
      if !(x <= 0 || y <= 0 || presses > limit) do
        bx_count = x / bx
        by_count = y / by
        if trunc(bx_count) == bx_count && trunc(by_count) == by_count && bx_count === by_count do
          presses
        else find_a_presses(ax, ay, bx, by, x - ax, y - ay, presses + 1) end
      else nil end
    end
  end

  def calculate_cost([ ax, ay, bx, by, x, y ]) do
    # IO.inspect({ax, ay, bx, by, x, y})
    case Solver.find_a_presses(ax, ay, bx, by, x, y) do
      nil -> 0
      a_presses -> (a_presses * 3) + div(x - (a_presses * ax), bx)
    end
  end
end

input
|> String.split("\n\n", trim: true)
|> Enum.map(&String.replace(&1, "\n", ""))
|> Enum.map(fn machine ->
  Regex.scan(~r/.*X\+(\d+).*Y\+(\d+).*X\+(\d+).*Y\+(\d+).*X\=(\d+).*Y\=(\d+)/, machine)
  |> hd |> tl |> Enum.map(&String.to_integer(&1))
end)
|> Enum.map(&Solver.calculate_cost/1)
|> Enum.sum()
# |> then(&(Solver.calculate_cost(hd(&1))))  # testing
|> IO.inspect()
