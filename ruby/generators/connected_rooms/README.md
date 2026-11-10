# Connected Rooms

Ruby port of this dungeon generator: https://gist.github.com/ctsrc/fef3006e1d728bb7271cff0656eb0280#file-dungeon-c

## Ruby Versions

**connected_rooms.ex**

Can take additional optional parameters to `new`.

## Usage

```ruby
require './connected_rooms/connected_rooms'
cr = ConnectedRooms.new debug: nil, cave_width: 20, cave_height: 15, solo_level: 10
cr.generate
```