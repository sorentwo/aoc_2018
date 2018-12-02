defmodule Aoc.Day02 do
  @moduledoc false

  @doc """
  --- Day 2: Inventory Management System ---

  You stop falling through time, catch your breath, and check the screen on the
  device. "Destination reached. Current Year: 1518. Current Location: North
  Pole Utility Closet 83N10." You made it! Now, to find those anomalies.

  Outside the utility closet, you hear footsteps and a voice. "...I'm not sure
  either. But now that so many people have chimneys, maybe he could sneak in
  that way?" Another voice responds, "Actually, we've been working on a new
  kind of suit that would let him fit through tight spaces like that. But, I
  heard that a few days ago, they lost the prototype fabric, the design plans,
  everything! Nobody on the team can even seem to remember important details of
  the project!"

  "Wouldn't they have had enough fabric to fill several boxes in the warehouse?
  They'd be stored together, so the box IDs should be similar. Too bad it would
  take forever to search the warehouse for two similar box IDs..." They walk
  too far away to hear any more.

  Late at night, you sneak to the warehouse - who knows what kinds of paradoxes
  you could cause if you were discovered - and use your fancy wrist device to
  quickly scan every box and produce a list of the likely candidates (your
  puzzle input).

  To make sure you didn't miss any, you scan the likely candidate boxes again,
  counting the number that have an ID containing exactly two of any letter and
  then separately counting those with exactly three of any letter. You can
       multiply those two counts together to get a rudimentary checksum and
       compare it to what your device predicts.

  For example, if you see the following box IDs:

  - abcdef contains no letters that appear exactly two or three times.
  - bababc contains two a and three b, so it counts for both.
  - abbcde contains two b, but no letter appears exactly three times.
  - abcccd contains three c, but no letter appears exactly two times.
  - aabcdd contains two a and two d, but it only counts once.
  - abcdee contains two e.
  - ababab contains three a and three b, but it only counts once.

  Of these box IDs, four of them contain a letter which appears exactly twice,
  and three of them contain a letter which appears exactly three times.
  Multiplying these together produces a checksum of 4 * 3 = 12.

  What is the checksum for your list of box IDs?
  """
  def solve_part_01 do
    load_input() |> checksum()
  end

  @doc """
  --- Part Two ---

  Confident that your list of box IDs is complete, you're ready to find the
  boxes full of prototype fabric.

  The boxes will have IDs which differ by exactly one character at the same
  position in both strings. For example, given the following box IDs:

  abcde
  fghij
  klmno
  pqrst
  fguij
  axcye
  wvxyz

  The IDs abcde and axcye are close, but they differ by two characters (the
  second and fourth). However, the IDs fghij and fguij differ by exactly one
  character, the third (h and u). Those must be the correct boxes.

  What letters are common between the two correct box IDs? (In the example
  above, this is found by removing the differing character from either ID,
  producing fgij.)
  """
  def solve_part_02 do
    load_input() |> common()
  end

  @doc """
  Checksum the list of box addresses.

      iex> Aoc.Day02.checksum(~w(abcdef bababc abbcde abcccd aabcdd abcdee ababab))
      12
  """
  def checksum(addresses) do
    {twice, thrice} =
      addresses
      |> Enum.map(&address_to_map/1)
      |> Enum.reduce({0, 0}, fn map, {tw, th} ->
        new_tw = if Map.has_key?(map, 2), do: tw + 1, else: tw
        new_th = if Map.has_key?(map, 3), do: th + 1, else: th

        {new_tw, new_th}
      end)

    twice * thrice
  end

  @doc """
  Find the common characters for the addresses with the highest overlap.

      iex> Aoc.Day02.common(~w(abcde fghij klmno pqrst fguij axcye wvxyz))
      "fgij"
  """
  def common(addresses) do
    pairings = for add_a <- addresses, add_b <- addresses, add_a != add_b, do: {add_a, add_b}

    Enum.reduce_while(pairings, nil, fn {add_a, add_b}, _ ->
      case String.myers_difference(add_a, add_b) do
        [eq: _, del: << char :: size(8) >>, ins: _, eq: _] ->
          {:halt, String.replace(add_a, IO.chardata_to_string([char]), "")}

        _ -> {:cont, nil}
      end
    end)
  end

  defp address_to_map(address) do
    address
    |> String.graphemes()
    |> Enum.reduce(%{}, fn char, acc -> Map.update(acc, char, 1, &(&1 + 1)) end)
    |> Enum.into(%{}, fn {key, val} -> {val, key} end)
  end

  defp load_input do
    :code.priv_dir(:aoc)
    |> Path.join("day_02_input.txt")
    |> File.read!()
    |> String.trim()
    |> String.split(~r/\s/)
  end
end
