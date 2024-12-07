{:ok, input} = File.read("input_2.txt")

defmodule Solver do
  # Arithmetic concatenation operator:
  # If we want to concatenate A and B (e.g., 12 and 345 -> 12345):
  # 12345 = 12 * 10^3 + 345 (since 345 has 3 digits)
  def concat(a, b) do
    # Handle the case when b is 0 (log10(0) is not defined)
    # For b = 0, concatenation like 12||0 = 120
    digits =
      if b == 0 do
        1
      else
        :math.floor(:math.log10(b)) + 1
      end

    trunc(a * :math.pow(10, digits) + b)
  end

  # Recursive function to check if we can reach the target using any combination of ops.
  # This approach tries all operators at each step and returns as soon as it finds a match.
  def can_reach_target?([head | tail], target, ops) do
    do_can_reach_target?(head, tail, target, ops)
  end

  defp do_can_reach_target?(current, [], target, _ops), do: current == target
  defp do_can_reach_target?(current, [next_val | rest], target, ops) do
    Enum.any?(ops, fn op ->
      new_val = op.(current, next_val)
      do_can_reach_target?(new_val, rest, target, ops)
    end)
  end

  def is_valid(row, ops) do
    target = hd(row)
    values = tl(row)
    if can_reach_target?(values, target, ops), do: target, else: 0
  end
end

calibrations =
  input
  |> String.split("\n", trim: true)
  |> Enum.map(&String.split(&1, " "))
  |> Enum.map(fn line ->
    # The first element is target (with a colon), subsequent are values
    [target_with_colon | rest] = line
    target = String.trim(target_with_colon, ":") |> String.to_integer()
    vals = Enum.map(rest, &String.to_integer/1)
    [target | vals]
  end)

# Part 1: Only + and *
part1_result =
  calibrations
  |> Enum.map(fn row ->
    Solver.is_valid(row, [&Kernel.+/2, &Kernel.*/2])
  end)
  |> Enum.sum()

IO.inspect(part1_result, label: "Part 1 Result")

# Part 2: +, *, and concatenation
part2_result =
  calibrations
  |> Enum.map(fn row ->
    Solver.is_valid(row, [&Kernel.+/2, &Kernel.*/2, &Solver.concat/2])
  end)
  |> Enum.sum()

IO.inspect(part2_result, label: "Part 2 Result")
