defmodule Aoc.Day05 do
  import Aoc

  @doc """
  --- Day 5: Alchemical Reduction ---

  You've managed to sneak in to the prototype suit manufacturing lab. The Elves
  are making decent progress, but are still struggling with the suit's size
  reduction capabilities.

  While the very latest in 1518 alchemical technology might have solved their
  problem eventually, you can do better. You scan the chemical composition of
  the suit's material and discover that it is formed by extremely long polymers
  (one of which is available as your puzzle input).

  The polymer is formed by smaller units which, when triggered, react with each
  other such that two adjacent units of the same type and opposite polarity are
  destroyed. Units' types are represented by letters; units' polarity is
  represented by capitalization. For instance, r and R are units with the same
  type but opposite polarity, whereas r and s are entirely different types and
  do not react.

  For example:

      In aA, a and A react, leaving nothing behind.
      In abBA, bB destroys itself, leaving aA. As above, this then destroys itself, leaving nothing.
      In abAB, no two adjacent units are of the same type, and so nothing happens.
      In aabAAB, even though aa and AA are of the same type, their polarities match, and so nothing happens.

  Now, consider a larger example, dabAcCaCBAcCcaDA:

  dabAcCaCBAcCcaDA  The first 'cC' is removed.
  dabAaCBAcCcaDA    This creates 'Aa', which is removed.
  dabCBAcCcaDA      Either 'cC' or 'Cc' are removed (the result is the same).
  dabCBAcaDA        No further actions can be taken.

  After all possible reactions, the resulting polymer contains 10 units.

  How many units remain after fully reacting the polymer you scanned? (Note: in
  this puzzle and others, the input is large; if you copy/paste your input,
  make sure you get the whole thing.)
  """
  def solve_part_01 do
    load_input(5) |> react()
  end

  @doc """
  --- Part Two ---

  Time to improve the polymer.

  One of the unit types is causing problems; it's preventing the polymer from
  collapsing as much as it should. Your goal is to figure out which unit type
  is causing the most problems, remove all instances of it (regardless of
  polarity), fully react the remaining polymer, and measure its length.

  For example, again using the polymer dabAcCaCBAcCcaDA from above:

      Removing all A/a units produces dbcCCBcCcD. Fully reacting this polymer produces dbCBcD, which has length 6.
      Removing all B/b units produces daAcCaCAcCcaDA. Fully reacting this polymer produces daCAcaDA, which has length 8.
      Removing all C/c units produces dabAaBAaDA. Fully reacting this polymer produces daDA, which has length 4.
      Removing all D/d units produces abAcCaCBAcCcaA. Fully reacting this polymer produces abCBAc, which has length 6.

  In this example, removing all C/c units was best, producing the answer 4.

  What is the length of the shortest polymer you can produce by removing all
  units of exactly one type and fully reacting the result?
  """
  def solve_part_02 do
    load_input(5) |> smallest()
  end

  @doc """
  Distil a polymer down to where it has no reactions.

    iex> Aoc.Day05.react("dabAcCaCBAcCcaDA")
    10
  """
  def react(input) when is_binary(input) do
    input |> react([]) |> byte_size()
  end

  def react(<<let_a, rest::binary>>, [let_b | acc]) when abs(let_a - let_b) == 32,
    do: react(rest, acc)

  def react(<<let, rest::binary>>, acc), do: react(rest, [let | acc])

  def react(<<>>, acc), do: acc |> Enum.reverse() |> List.to_string()

  @doc """
  Find the smallest distillation with a letter removed.

    iex> Aoc.Day05.smallest("dabAcCaCBAcCcaDA")
    4
  """
  def smallest(input) when is_binary(input) do
    ?A..?Z
    |> Task.async_stream(fn char -> discard_and_react(input, char, char + 32) |> byte_size() end)
    |> Stream.map(&elem(&1, 1))
    |> Enum.min()
  end

  defp discard_and_react(input, let_a, let_b) when is_binary(input),
    do: discard_and_react(input, [], let_a, let_b)

  defp discard_and_react(<<let, rest::binary>>, acc, dis_a, dis_b)
       when let == dis_a
       when let == dis_b,
       do: discard_and_react(rest, acc, dis_a, dis_b)

  defp discard_and_react(<<let_a, rest::binary>>, [let_b | acc], dis_a, dis_b)
       when abs(let_a - let_b) == 32,
       do: discard_and_react(rest, acc, dis_a, dis_b)

  defp discard_and_react(<<let, rest::binary>>, acc, dis_a, dis_b),
    do: discard_and_react(rest, [let | acc], dis_a, dis_b)

  defp discard_and_react(<<>>, acc, _dis_a, _dis_b), do: acc |> Enum.reverse() |> List.to_string()
end
