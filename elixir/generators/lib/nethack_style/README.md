# dungeon

Elixir implementation of a nethack style maze generation algorithm (https://nethackwiki.com/wiki/Source:NetHack_3.4.3/src/mklev.c#Top_of_file) (https://www.tumblr.com/procedural-generation/157578222372/nethack1)
Just the rooms and tunnels, cut out the "arboreal" stuff to make things more simple.

## Elixir Versions

**nethack_style.ex**

Pulled from https://github.com/callahat/dungeon_crawl/blob/master/lib/dungeon_crawl/dungeon_generation/map_generators/nethack_style.ex
Can take additional optional parameters to the `generate` function.

## Usage

```elixir
NethackStyle.generate(%{debug: true, solo_level: 1})
```
