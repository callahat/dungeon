# dungeon

Various ports of this dungeon generator: https://gist.github.com/ctsrc/fef3006e1d728bb7271cff0656eb0280#file-dungeon-c

## Javascript Version

**dungeon.html** 

Written by someone else; though I added some querystring configuration

## Elixir Versions

**dungeon.ex** 

Implementation of the generator using a `List` as the structure that holds the dungeon being generated. A list is not good for random access and very slow for this problem.

**dungeon2.ex** 

Similar, but instead of a `List` a `Map` is used. Much faster than the List version as only certain specific elements need checked/changed (ie, much faster with the random access)


