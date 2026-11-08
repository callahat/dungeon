# Nethack Style

Elixir implementation of a nethack style maze generation algorithm

[Nethack Wiki](https://nethackwiki.com/wiki/Source:NetHack_3.4.3/src/mklev.c#Top_of_file)

https://www.tumblr.com/procedural-generation/157578222372/nethack1

Just the rooms and tunnels, cut out the "arboreal" stuff to make things more simple.

This algorithm generates a classic nethack/roguelike maze.

There are a few main phases.

Phase 1, generate rooms. To do this, it starts with a big rectangle
where a room could be placed and randomly drops one within that boundary.
Then it breaks the big rectangle into smaller ones where a room could
be placed (left, right, up, down, and up left, up right, etc) - possibly
8 sub rectangles. Rectangles too small for a room are discarded.

This repeats for each of the rectangles big enough to get a room.

Rooms are then sorted (ie, top left most to bottom rightmost),
each room gets a "number" for coloring purposes, which is used to
determine what rooms are connected to the greater cluster (and are reachable
from each other)

Phase 2, connect corridors to rooms. There are three passes. First pass has a 50%
chance of stopping early. It attempts to connect adjacent rooms. The second pass
attempts to connect each room with a room two away (in the sort order).
The third pass attempts to connect rooms that have not been connected
to the rest of the rooms.

Corridors attempt to connect rooms by finding the closest wall and starting
a walked that take a path (but not necessairly a straight nor most direct
path - it prefers moving in a vector that is most direct to the target but there's
a slight chance it will go a different direction which makes the Nethack corridors
look so interesting). The closest wall in the target room gets a target "door" that the walker
attempts to reach. The walker fails (and throws away the corridor) if it
goes out of bounds or the map or takes a set number of steps and has not reached
the target door.

If successful though, all the steps the walker took get commited as corridor.

Phase 3, flavor. Here some random coordinates are picked adjacent to rooms
to put a "closet" - a single space connected to the room via a door. Also
here stairs are placed, entities are added, and random gems are placed
deep in the rock outside of direct line of sight of a player (should walls/
rock block vision in a top down view).

## Elixir Versions

**nethack_style.ex**

Pulled from https://github.com/callahat/dungeon_crawl/blob/master/lib/dungeon_crawl/dungeon_generation/map_generators/nethack_style.ex
Can take additional optional parameters to the `generate` function.

## Usage

```elixir
NethackStyle.generate(%{debug: true, solo_level: 1})
```
