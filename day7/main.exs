{:ok, input} = File.read("input_2.txt")

defmodule Combinations do
  # chatgpt code (modified)
  # TODO: make something nicer i guess

  def generate_combinations(chars, length, acc \\ [])
  def generate_combinations(_chars, 0, acc), do: [Enum.reverse(acc)]
  def generate_combinations(chars, length, acc) do
    Enum.flat_map(chars, fn char ->
      generate_combinations(chars, length - 1, [char | acc])
    end)
  end
end

defmodule Solver do
  def is_valid(row, funcs) do
    target = hd(row)
    values = tl(row)
    operations = Combinations.generate_combinations(funcs, (length(values) - 1))

    Enum.reduce_while(operations, false, fn ops, found ->
      result = Enum.with_index(tl(values))
      |> Enum.reduce(hd(values), fn {value, i}, acc ->
        Enum.at(ops, i)  # get operator
        |> (& &1.(acc, value)).()  # this feels naughty
      end)
      cond do
        result === target -> {:halt, true}
        result !== target -> {:cont, found}
      end
    end)
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
  case Solver.is_valid(row, [&Kernel.+/2, &Kernel.*/2]) do
    true -> hd(row)
    false -> 0
  end
end)
|> Enum.sum()
|> IO.inspect()

# part2
calibrations
|> Enum.map(fn row ->
  case Solver.is_valid(row, [&Kernel.+/2, &Kernel.*/2, &(String.to_integer("#{&1}#{&2}"))]) do
    true -> hd(row)
    false -> 0
  end
end)
|> Enum.sum()
|> IO.inspect()
