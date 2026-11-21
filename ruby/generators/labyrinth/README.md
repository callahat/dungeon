# dungeon

Ruby implementation of a labyrinth maze generation algorithm (https://en.wikipedia.org/wiki/Kruskal's_algorithm) (https://en.wikipedia.org/wiki/Prim's_algorithm).
The variation here picks a random space and adds it as a starting point to the
"frontier" list. Then randomly grabs a space from the "frontier" and adds it to the maze,
adding adjacent squares not in the map to the "frontier" list, and repeats
until there are no more frontier squares.

## Elixir Versions

**labyrinth.rb**

## Usage

```bash
require './labyrinth/labyrinth'
lab=Labyrinth.new cave_height: 9, cave_width: 19, solo_level: 1, debug: true
lab.generate
```
