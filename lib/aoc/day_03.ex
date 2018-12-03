defmodule Aoc.Day03 do
  @doc """
  --- Day 3: No Matter How You Slice It ---

  The Elves managed to locate the chimney-squeeze prototype fabric for Santa's
  suit (thanks to someone who helpfully wrote its box IDs on the wall of the
  warehouse in the middle of the night). Unfortunately, anomalies are still
  affecting them - nobody can even agree on how to cut the fabric.

  The whole piece of fabric they're working on is a very large square - at
  least 1000 inches on each side.

  Each Elf has made a claim about which area of fabric would be ideal for
  Santa's suit. All claims have an ID and consist of a single rectangle with
  edges parallel to the edges of the fabric. Each claim's rectangle is defined
  as follows:

      The number of inches between the left edge of the fabric and the left edge of the rectangle.
      The number of inches between the top edge of the fabric and the top edge of the rectangle.
      The width of the rectangle in inches.
      The height of the rectangle in inches.

  A claim like #123 @ 3,2: 5x4 means that claim ID 123 specifies a rectangle 3
  inches from the left edge, 2 inches from the top edge, 5 inches wide, and 4
  inches tall. Visually, it claims the square inches of fabric represented by #
  (and ignores the square inches of fabric represented by .) in the diagram
  below:

  ...........
  ...........
  ...#####...
  ...#####...
  ...#####...
  ...#####...
  ...........
  ...........
  ...........

  The problem is that many of the claims overlap, causing two or more claims to
  cover part of the same areas. For example, consider the following claims:

  #1 @ 1,3: 4x4
  #2 @ 3,1: 4x4
  #3 @ 5,5: 2x2

  Visually, these claim the following areas:

  ........
  ...2222.
  ...2222.
  .11XX22.
  .11XX22.
  .111133.
  .111133.
  ........

  The four square inches marked with X are claimed by both 1 and 2. (Claim 3,
  while adjacent to the others, does not overlap either of them.)

  If the Elves all proceed with their own plans, none of them will have enough
  fabric. How many square inches of fabric are within two or more claims?
  """
  def solve_part_01 do
    load_input() |> overlap()
  end

  @doc """
  --- Part Two ---

  Amidst the chaos, you notice that exactly one claim doesn't overlap by even a
  single square inch of fabric with any other claim. If you can somehow draw
  attention to it, maybe the Elves will be able to make Santa's suit after all!

  For example, in the claims above, only claim 3 is intact after all claims are
  made.

  What is the ID of the only claim that doesn't overlap?
  """
  def solve_part_02 do
    claims = Enum.map(load_input(), &to_claim/1)
    claim_map = claims_per_square_inch(claims)

    claims
    |> Enum.find(&solo_point?(&1, claim_map))
    |> Map.get(:id)
    |> String.to_integer()
  end

  defp solo_point?(%{points: points}, claim_map) do
    Enum.all?(points, fn point -> claim_map[point] == 1 end)
  end

  @doc """
  Compute the overlap between claims.

      iex> Aoc.Day03.overlap(["#1 @ 1,3: 4x4", "#2 @ 3,1: 4x4", "#3 @ 5,5: 2x2"])
      4
  """
  def overlap(input) do
    input
    |> Enum.map(&to_claim/1)
    |> claims_per_square_inch()
    |> Enum.count(fn {_, size} -> size >= 2 end)
  end

  defp claims_per_square_inch(claims) do
    Enum.reduce(claims, %{}, fn %{points: points}, acc ->
      Enum.reduce(points, acc, fn point, acc -> Map.update(acc, point, 1, &(&1 + 1)) end)
    end)
  end

  defp to_claim("#" <> input) do
    [id, _at, point, dimms] = String.split(input, " ")

    [x, y] = split_point(point)
    [w, h] = split_dimms(dimms)

    points = for xp <- x..(x + w - 1), yp <- y..(y + h - 1), do: {xp, yp}

    %{id: id, points: points}
  end

  defp split_point(point) do
    point
    |> String.split(",")
    |> Enum.map(fn x ->
      x
      |> String.replace(":", "")
      |> String.to_integer()
    end)
  end

  defp split_dimms(dimms) do
    dimms
    |> String.split("x")
    |> Enum.map(&String.to_integer/1)
  end

  defp load_input do
    :code.priv_dir(:aoc)
    |> Path.join("day_03_input.txt")
    |> File.read!()
    |> String.trim()
    |> String.split(~r/\n/)
  end
end
