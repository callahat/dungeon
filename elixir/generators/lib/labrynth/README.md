# dungeon

Elixir implementation of a labyrinth maze generation algorithm (https://en.wikipedia.org/wiki/Kruskal's_algorithm)

## Elixir Versions

**drunkards_walk.ex**

Pulled from https://github.com/callahat/dungeon_crawl/blob/master/lib/dungeon_crawl/dungeon_generation/map_generators/labrynth.ex
Can take additional optional parameters to the `generate` function.

## Usage

```elixir
Labrynth.generate(%{debug: true, solo_level: 1})
```
