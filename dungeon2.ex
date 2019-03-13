# port of this to Elixir: https://gist.github.com/ctsrc/fef3006e1d728bb7271cff0656eb0280#file-dungeon-c
# Implement with a map instead of list
defmodule Dungeon2 do
  @room_min_height  3
  @room_max_height  9
  @room_min_width   5
  @room_max_width  15

  @cave_height     40
  @cave_width      80

  @doors           '+\''
  @entities        Enum.to_list(?A..?|)

  def generate() do
    map = Enum.to_list(0..(@cave_height * @cave_width - 1)) |> Enum.reduce(%{}, fn(i, acc) -> Map.put(acc, i, ?\s) end) 
    {:good_room, coords} = try_generating_room_coordinates(map)
    map = _plop_room(map, coords, ?@)

    _generate(map, 1000)
    |> _map_to_charlist
    |> _replace_corners
    |> _render
    nil
  end

  defp _generate(map, 0), do: map
  defp _generate(map, n) do
    case try_generating_room_coordinates(map) do
      {:good_room, coords} ->
        # IO.puts inspect coords
        entities = @entities |> Enum.shuffle |> Enum.take(_rand_range(1,6))
        _plop_room(map, coords, entities)
        |> _generate(n - 1)
      {:bad_room} ->
        _generate(map, n - 1)
    end
  end

  def try_generating_room_coordinates(map) do
    w = _rand_range(@room_min_width,  @room_max_width)
    h = _rand_range(@room_min_height, @room_max_height)

    # -2 for the outer walls
    top_left_col = _rand_range(0, (@cave_width  - 2) - w)
    top_left_row = _rand_range(0, (@cave_height - 2) - h)

    bottom_right_col = top_left_col + w + 1
    bottom_right_row = top_left_row + h + 1

    if(Enum.any?(
              for(col <- top_left_col..bottom_right_col, do:
                for(row <- top_left_row..bottom_right_row, do:
                  _tile_at(map, col, row) == ?.
              )) |> Enum.concat,
              fn floor_tile -> floor_tile end
       )) do
      {:bad_room}
    else
      {:good_room, %{top_left_col: top_left_col, top_left_row: top_left_row, bottom_right_col: bottom_right_col, bottom_right_row: bottom_right_row}}
    end
  end

  defp _rand_range(min, max), do: :rand.uniform(max - min + 1) + min - 1

  defp _tile_at(map, col, row) do
    map[row * @cave_width + col]
  end

  defp _replace_tile_at(map, col, row, new_tile) do
    # IO.puts "#{col} #{row} #{[new_tile]}"
    Map.put(map, row * @cave_width + col, new_tile)
  end

  defp _map_to_charlist(map) do
    map
    |> Map.to_list
    |> Enum.sort(fn({k1, _}, {k2, _}) -> k1 < k2 end)
    |> Enum.map(fn({_, v}) -> v end)
  end

  defp _replace_corners([]), do: []
  defp _replace_corners([head | tail]) when head == 0, do: [?# | _replace_corners(tail)]
  defp _replace_corners([head | tail]), do: [head | _replace_corners(tail)]

  defp _add_door(map, {col, row}) do
    _replace_tile_at(map, col, row, Enum.random(@doors))
  end

  defp _add_entities(map, [], _coords), do: map
  defp _add_entities(map, [entity | entities], coords = %{top_left_col: tlc, top_left_row: tlr, bottom_right_col: brc, bottom_right_row: brr}) do
    _replace_tile_at(map, _rand_range(tlc + 1, brc - 1), _rand_range(tlr + 1, brr - 1), _maybe_treasure_instead(entity))
    |> _add_entities(entities, coords)
  end

  defp _maybe_treasure_instead(entity) do
    if _rand_range(1,4) == 1 do
      ?$
    else
      entity
    end
  end

  defp _plop_room(map, coords = %{top_left_col: tlc, top_left_row: tlr, bottom_right_col: brc, bottom_right_row: brr}, ?@) do
    _corners_and_walls(map, coords)
    |> _replace_tile_at(_rand_range(tlc + 1, brc - 1), _rand_range(tlr + 1, brr - 1), ?@)
  end

  defp _plop_room(map, coords = %{top_left_col: tlc, top_left_row: tlr, bottom_right_col: brc, bottom_right_row: brr}, entities) do
    case _door_candidates(map, coords) do
      [] -> 
        map
      door_coords ->
        _corners_and_walls(map, coords)
        |> _add_door(Enum.random(door_coords))
        |> _add_entities(entities, coords)
    end
  end

  defp _corners_and_walls(map, coords = %{top_left_col: tlc, top_left_row: tlr, bottom_right_col: brc, bottom_right_row: brr}) do
    map =
      for col <- tlc..brc do
        for row <- tlr..brr do
          vertical_wall   = (col == tlc || col == brc)
          horizontal_wall = (row == tlr || row == brr)
          new_tile = cond do
                       vertical_wall && horizontal_wall ->  0
                       vertical_wall || horizontal_wall -> ?#
                       true -> ?.
                     end
          {col, row, new_tile}
        end
      end
      |> Enum.concat
      |> _replace_tiles(map) 
    map
  end

  defp _door_candidates(map, coords = %{top_left_col: tlc, top_left_row: tlr, bottom_right_col: brc, bottom_right_row: brr}) do
    for [cols,rows] <- [ [[tlc, brc], Enum.to_list((tlr+1)..(brr-1))], [Enum.to_list((tlc+1)..(brc-1)), [tlr,brr]] ] do
      for col <- cols do
        for row <- rows do
          {col, row}
        end
      end
    end
    |> Enum.concat
    |> Enum.concat
    |> Enum.filter(fn({col, row}) -> map[row * @cave_width + col] == ?# end)
  end

  defp _replace_tiles([], map), do: map
  defp _replace_tiles([{col, row, new_tile} | tail], map), do: _replace_tiles(tail, _replace_tile_at(map, col, row, new_tile))

  defp _render(map) do
    Enum.chunk(map, @cave_width) |> Enum.map(&(to_string(&1))) |> Enum.join("\n") |> IO.puts
  end
end
