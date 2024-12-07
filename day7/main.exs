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
  def is_valid(row) do
    target = hd(row)
    values = tl(row)

    operations = Combinations.generate_combinations(
      [&Kernel.+/2, &Kernel.*/2], (length(values) - 1)
    )

    Enum.map(operations, fn ops ->
      Enum.with_index(tl(values))
      |> Enum.reduce(hd(values), fn {value, i}, acc ->
        Enum.at(ops, i)  # get operator
        |> (& &1.(acc, value)).()  # this feels naughty
      end)
    end)
    |> Enum.member?(target)
  end
end

input
|> String.split("\n", trim: true)
|> Enum.map(&String.split(&1, " "))
|> Enum.map(&([ String.trim(hd(&1), ":") | tl(&1) ]))
|> Enum.map(fn row ->
  Enum.map(row, &String.to_integer/1)
end)
|> Enum.map(fn row ->
  case Solver.is_valid(row) do
    true -> hd(row)
    false -> 0
  end
end)
|> Enum.sum()
|> IO.inspect()
