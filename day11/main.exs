{:ok, input} = File.read("input_2.txt")

defmodule Cache do
  def start() do
    Agent.start_link(fn -> %{} end, name: MyAgent)
  end

  def put(key, value) do
    Agent.update(MyAgent, fn cache -> Map.put(cache, key, value) end)
  end

  def get(key) do
    Agent.get(MyAgent, &Map.get(&1, key))
  end

  def dump() do
    Agent.get(MyAgent, &(&1))
  end
end

defmodule EtsCache do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_) do
    :ets.new(
      __MODULE__,
      [:named_table, :public, :set, write_concurrency: true]
    )

    {:ok, nil}
  end

  def insert(key, value) do
    :ets.insert(__MODULE__, {key, value})
    value
  end

  def fetch(key) do
    case :ets.lookup(__MODULE__, key) do
       [{^key, value}] -> value
       [] -> nil
    end
  end
end

defmodule Solver do
  def num_len(num) when num === 0 do 1 end
  def num_len(num) do trunc(:math.floor(:math.log10(abs(num))) + 1) end

  # https://stackoverflow.com/a/32016977
  def split_stone(stone) do
    len = Solver.num_len(stone)
    left = div(stone, trunc(:math.pow(10, div(len, 2))))
    right = trunc(stone - left * :math.pow(10, div(len, 2)))
    {left, right}
  end

  def blink(stones) do
    Enum.reduce(stones, [], fn stone, acc ->
      if stone === 0 do
        [ 1 | acc ]
      else
        if rem(Solver.num_len(stone), 2) === 0 do
          {left, right} = Solver.split_stone(stone)
          [ left, right | acc ]
        else
          [ stone * 2024 | acc ]
        end
      end
    end)
  end

  def solve(stones, target_count, count \\ 0) do
    # IO.inspect(length(stones), label: "stone count")
    # IO.inspect(count, label: "blinking count")
    if count < target_count do

      # Chunking seems to make it faster
      # but makes it run out of memory (faster?)
      Enum.chunk_every(stones, 1_000_000)
      |> Enum.map(fn chunk ->
          Task.async(fn -> Solver.blink(chunk) end)
      end)
      |> Enum.flat_map(&Task.await(&1))
      # |> tap(&(IO.inspect(&1, pretty: false, limit: :infinity)))
      # Solver.blink(stones)
      |> Solver.solve(target_count, count + 1)
    else stones end
  end

  def blink_fast(stone, target, count \\ 0) do
    if count === target do 1 else
      if stone === 0 do
        blink_fast(1, target, count + 1)
      else
        if rem(Solver.num_len(stone), 2) === 0 do
          {left, right} = Solver.split_stone(stone)
          blink_fast(left, target, count + 1) + blink_fast(right, target, count + 1)
        else
          blink_fast(stone * 2024, target, count + 1)
        end
      end
    end
  end

  def blink_faster(stone, target, count \\ 0)
  def blink_faster(_stone, target, count) when target == count, do: 1

  def blink_faster(stone, target, count) when stone === 0 do
    case EtsCache.fetch({stone, count}) do
       nil ->
         result = blink_faster(1, target, count + 1)
         EtsCache.insert({stone, count}, result)
       cached -> cached
    end
  end

  def blink_faster(stone, target, count) do
    # TODO: try to refactor using `with` to see how that feels
    case EtsCache.fetch({stone, count}) do
      nil ->
        if rem(Solver.num_len(stone), 2) === 0 do
          {left, right} = Solver.split_stone(stone)
          result = blink_faster(left, target, count + 1) + blink_faster(right, target, count + 1)
          EtsCache.insert({stone, count}, result)
        else
          result = blink_faster(stone * 2024, target, count + 1)
          EtsCache.insert({stone, count}, result)
        end

      cached ->
        cached
    end
  end
end

EtsCache.start_link()

{time, result} = :timer.tc(fn ->
input
  |> String.trim("\n")
  |> String.split(" ")
  |> Enum.map(&String.to_integer/1)
  |> Enum.map(fn stone ->
    Task.async(fn ->
      Solver.blink_faster(stone, 75)
    end)
  end)
  |> Task.await_many(:infinity)
  |> Enum.sum()
end)

IO.inspect("#{result} (#{time / 1_000}ms)", label: "Result")
