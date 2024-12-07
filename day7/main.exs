{:ok, input} = File.read("input_2.txt")

defmodule Solver do
  def generate_combinations(chars, length, acc \\ [])
  def generate_combinations(_chars, 0, acc), do: [Enum.reverse(acc)]
  def generate_combinations(chars, length, acc) do
    Enum.flat_map(chars, fn char ->
      generate_combinations(chars, length - 1, [char | acc])
    end)
  end

  def is_valid(row, funcs) do
    target = hd(row)
    values = tl(row)

    {time, operations} = :timer.tc(fn ->
      # TODO: Optimize me away
      Solver.generate_combinations(funcs, (length(values) - 1))
    end)

    time / 1000000
    |> IO.puts()

    valid = Enum.reduce_while(operations, false, fn ops, found ->
      result = Enum.with_index(tl(values))
      |> Enum.reduce(hd(values), fn {value, i}, acc ->
        Enum.at(ops, i)  # get operator
        |> (& &1.(acc, value)).()  # this feels naughty
      end)
      cond do
        result === target -> {:halt, true}  # stop on first valid result
        result !== target -> {:cont, found}
      end
    end)

    if valid do target else 0 end
  end

  def concat(x, y) do
    :math.floor(:math.log10(y))
    |> then(&(trunc(x * (10 ** (&1 + 1)) + y)))
  end

  def is_valid2(target, [], _operators, acc), do: target === acc
  def is_valid2(target, [head | tail], operators, acc) do
    Enum.any?(operators, fn op ->
      op.(acc, head)
      |> then(&Solver.is_valid2(target, tail, operators, &1))
    end)
  end

  def check_validity_slow([target | values], operators) do
    case is_valid2(target, values, operators, hd(values)) do
      true -> target
      _ -> 0
    end
  end

  def check_validity([target | [ head | tail ]], operators) do
    case is_valid2(target, tail, operators, head) do
      true -> target
      _ -> 0
    end
  end
end

# part1
# calibrations
# |> Enum.map(fn row ->
#   Task.async(fn ->
#     Solver.is_valid(row, [&Kernel.+/2, &Kernel.*/2])
#   end)
# end)
# |> Enum.map(&Task.await(&1))
# |> Enum.sum()
# |> IO.inspect()

# part2
{time, result} = :timer.tc(fn ->
  calibrations = input
  |> String.split("\n", trim: true)
  |> Enum.map(&String.split(&1, " "))
  |> Enum.map(&([ String.trim(hd(&1), ":") | tl(&1) ]))
  |> Enum.map(fn row ->
    Enum.map(row, &String.to_integer/1)
  end)

  calibrations
  |> Enum.map(fn row ->
    Task.async(fn ->
      Solver.check_validity(row, [&Kernel.+/2, &Kernel.*/2, &Solver.concat/2])
    end)
  end)
  |> Enum.map(&Task.await(&1))
  |> Enum.sum()
end)

IO.inspect("#{result} (#{time / 1_000}ms)", label: "Part 2")
