defmodule Aoc do
  def load_input(day) do
    day = if day < 10, do: "0#{day}", else: day

    :code.priv_dir(:aoc)
    |> Path.join("day_#{day}_input.txt")
    |> File.read!()
    |> String.trim()
  end
end
