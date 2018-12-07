defmodule Aoc.Day06 do
  import Aoc

  @doc """
  --- Day 6: Chronal Coordinates ---

  The device on your wrist beeps several times, and once again you feel like
  you're falling.

  "Situation critical," the device announces. "Destination indeterminate.
  Chronal interference detected. Please specify new target coordinates."

  The device then produces a list of coordinates (your puzzle input). Are they
  places it thinks are safe or dangerous? It recommends you check manual page
  729. The Elves did not give you a manual.

  If they're dangerous, maybe you can minimize the danger by finding the
  coordinate that gives the largest distance from the other points.

  Using only the Manhattan distance, determine the area around each coordinate
  by counting the number of integer X,Y locations that are closest to that
  coordinate (and aren't tied in distance to any other coordinate).

  Your goal is to find the size of the largest area that isn't infinite. For
  example, consider the following list of coordinates:

  1, 1
  1, 6
  8, 3
  3, 4
  5, 5
  8, 9

  If we name these coordinates A through F, we can draw them on a grid, putting
  0,0 at the top left:

  ..........
  .A........
  ..........
  ........C.
  ...D......
  .....E....
  .B........
  ..........
  ..........
  ........F.

  This view is partial - the actual grid extends infinitely in all directions.
  Using the Manhattan distance, each location's closest coordinate can be
  determined, shown here in lowercase:

  aaaaa.cccc
  aAaaa.cccc
  aaaddecccc
  aadddeccCc
  ..dDdeeccc
  bb.deEeecc
  bBb.eeee..
  bbb.eeefff
  bbb.eeffff
  bbb.ffffFf

  Locations shown as . are equally far from two or more coordinates, and so
  they don't count as being closest to any.

  In this example, the areas of coordinates A, B, C, and F are infinite - while
  not shown here, their areas extend forever outside the visible grid. However,
  the areas of coordinates D and E are finite: D is closest to 9 locations, and
  E is closest to 17 (both including the coordinate's location itself).
  Therefore, in this example, the size of the largest area is 17.

  What is the size of the largest area that isn't infinite?
  """
  def part_one do
    load_input(6) |> largest_area()
  end

  @doc """
  --- Part Two ---

  On the other hand, if the coordinates are safe, maybe the best you can do is
  try to find a region near as many coordinates as possible.

  For example, suppose you want the sum of the Manhattan distance to all of the
  coordinates to be less than 32. For each location, add up the distances to
  all of the given coordinates; if the total of those distances is less than
  32, that location is within the desired region. Using the same coordinates as
  above, the resulting region looks like this:

  ..........
  .A........
  ..........
  ...###..C.
  ..#D###...
  ..###E#...
  .B.###....
  ..........
  ..........
  ........F.

  In particular, consider the highlighted location 4,3 located at the top
  middle of the region. Its calculation is as follows, where abs() is the
  absolute value function:

      Distance to coordinate A: abs(4-1) + abs(3-1) =  5
      Distance to coordinate B: abs(4-1) + abs(3-6) =  6
      Distance to coordinate C: abs(4-8) + abs(3-3) =  4
      Distance to coordinate D: abs(4-3) + abs(3-4) =  2
      Distance to coordinate E: abs(4-5) + abs(3-5) =  3
      Distance to coordinate F: abs(4-8) + abs(3-9) = 10
      Total distance: 5 + 6 + 4 + 2 + 3 + 10 = 30

  Because the total distance to all coordinates (30) is less than 32, the
  location is within the region.

  This region, which also includes coordinates D and E, has a total size of 16.

  Your actual region will need to be much larger than this example, though,
  instead including all locations with a total distance of less than 10000.

  What is the size of the region containing all locations which have a total
  distance to all given coordinates of less than 10000?
  """
  def part_two do
    coordinates = load_input(6) |> coordinates()

    coordinates
    |> all_positions()
    |> Enum.map(&total_distance(&1, coordinates))
    |> Enum.filter(&(&1 < 10_000))
    |> Enum.count()
  end

  defp all_positions(coordinates) do
    {{min_x, _}, {max_x, _}} = Enum.min_max_by(coordinates, &elem(&1, 0), &elem(&1, 0))
    {{_, min_y}, {_, max_y}} = Enum.min_max_by(coordinates, &elem(&1, 1), &elem(&1, 1))

    for x <- min_x..max_x, y <- min_y..max_y, do: {x, y}
  end

  defp total_distance(point, coordinates) do
    coordinates
    |> Stream.map(&distance(&1, point))
    |> Enum.sum()
  end

  @doc ~S"""
  Find the largest area:

      iex> Aoc.Day06.largest_area("1, 1\n1, 6\n8, 3\n3, 4\n5, 5\n8, 9")
      17
  """
  def largest_area(input) when is_binary(input) do
    input
    |> coordinates()
    |> mark_nearest_point()
    |> Enum.group_by(&(&1))
    |> Enum.map(fn {_, val} -> length(val) end)
    |> Enum.max()
  end

  defp coordinates(input) do
    input
    |> String.split("\n")
    |> Enum.map(&line_to_point/1)
  end

  defp line_to_point(line) do
    line
    |> String.split(", ")
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple()
  end

  defp mark_nearest_point(coordinates) do
    named_coordinates = Enum.with_index(coordinates)

    coordinates
    |> all_positions()
    |> Enum.map(&closest_coordinate(&1, named_coordinates))
  end

  defp closest_coordinate(point_1, named_coordinates) do
    named_coordinates
    |> Enum.map(fn {point_2, id} -> {distance(point_1, point_2), id} end)
    |> Enum.sort_by(&elem(&1, 0))
    |> closest_id()
  end

  defp distance({x1, y1}, {x2, y2}), do: abs(x1 - x2) + abs(y1 - y2)

  defp closest_id([{dist, _}, {dist, _} | _]), do: -1
  defp closest_id([{_dist, id} | _]), do: id
end
