# dungeon

Elixir implementation of a binary space partition algorithm to generate
connected rooms and tunnels.

## Elixir Versions

**rooms_and_tunnels_bsp.ex**

Pulled from https://github.com/callahat/dungeon_crawl/blob/master/lib/dungeon_crawl/dungeon_generation/map_generators/rooms_and_tunnels_bsp.ex
Can take additional optional parameters to the `generate` function.

## Usage

```elixir
RoomsAndTunnelsBsp.generate(%{debug: true, solo_level: 1})
```
