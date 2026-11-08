# Binary Space Partition Rooms and Tunnels

Elixir implementation of a binary space partition algorithm to generate
connected rooms and tunnels.

The basic algorithm takes a rectangle and splits it. A corridor will connect
the center point of each rectangle. Then each child rectangle is also split,
and each child pair is connected in a similar manner; corridor from each
center point.

The splitting stops after N iterators, or when a child rectangle is at or below a
certian size.

Then go over each of the small rectangles. Each has a high chance of getting
a room (90% in this implementation). The room might not be connected or on
a corridor route, so extend the corridor to the room if needed.

If a rooms wall runs adjacent to a corridor, that corridor becomes part of
the room.

## Elixir Versions

**rooms_and_tunnels_bsp.ex**

Pulled from https://github.com/callahat/dungeon_crawl/blob/master/lib/dungeon_crawl/dungeon_generation/map_generators/rooms_and_tunnels_bsp.ex
Can take additional optional parameters to the `generate` function.

## Usage

```elixir
RoomsAndTunnelsBsp.generate(%{debug: true, solo_level: 1})
```
