# dungeon

Elixir implementation of the drunkards walk maze generation algorithm.
Start at a coordinate, and randomly move to an adjacent coordinate and mark it. Repeat.
Periodically sober up, and pick a direction to walk a straight line in for a distance. Then
return to stumbling about for another number of steps.
Continue until a certain percentage of the coordinates have been marked or an upper bound
of steps have been taken.

## Elixir Versions

**drunkards_walk.ex**

Pulled from https://github.com/callahat/dungeon_crawl/blob/master/lib/dungeon_crawl/dungeon_generation/map_generators/drunkards_walk.ex
Can take additional optional parameters to the `generate` function.

## Usage

```elixir
DrunkardsWalk.generate(%{debug: true, solo_level: 1})
```