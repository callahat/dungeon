# dungeon

Elixir implementation of a labyrinth maze generation algorithm (https://en.wikipedia.org/wiki/Kruskal's_algorithm) (https://en.wikipedia.org/wiki/Prim's_algorithm).
The variation here picks a random space and adds it as a starting point to the
"frontier" list. Then randomly grabs a space from the "frontier" and adds it to the maze,
adding adjacent squares not in the map to the "frontier" list, and repeats
until there are no more frontier squares.

## Elixir Versions

**drunkards_walk.ex**

Pulled from https://github.com/callahat/dungeon_crawl/blob/master/lib/dungeon_crawl/dungeon_generation/map_generators/labrynth.ex
Can take additional optional parameters to the `generate` function.

## Usage

```elixir
Labrynth.generate(%{debug: true, solo_level: 1})
```
