{:ok, input} = File.read("input_2.txt")

defmodule Solver do
  def generate_combinations(chars, length, acc \\ [])
  def generate_combinations(_chars, 0, acc), do: [Enum.reverse(acc)]
  def generate_combinations(chars, length, acc) do
    Enum.flat_map(chars, fn char ->
      generate_combinations(chars, length - 1, [char | acc])
    end)
  end

  def concat(x, y) do
    :math.floor(:math.log10(y))
    |> then(&(trunc(x * (10 ** (&1 + 1)) + y)))
  end

  def is_valid(row, funcs) do
    target = hd(row)
    values = tl(row)
    operations = Solver.generate_combinations(funcs, (length(values) - 1))

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
end

calibrations = input
|> String.split("\n", trim: true)
|> Enum.map(&String.split(&1, " "))
|> Enum.map(&([ String.trim(hd(&1), ":") | tl(&1) ]))
|> Enum.map(fn row ->
  Enum.map(row, &String.to_integer/1)
end)

# part1
calibrations
|> Enum.map(fn row ->
  Task.async(fn ->
    Solver.is_valid(row, [&Kernel.+/2, &Kernel.*/2])
  end)
end)
|> Enum.map(&Task.await(&1))
|> Enum.sum()
|> IO.inspect()

# part2
calibrations
|> Enum.map(fn row ->
  Task.async(fn ->
    Solver.is_valid(
      row, [&Kernel.+/2, &Kernel.*/2, &Solver.concat/2]
    )
  end)
end)
|> Enum.map(&Task.await(&1))
|> Enum.sum()
|> IO.inspect()
