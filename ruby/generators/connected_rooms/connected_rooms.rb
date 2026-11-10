class ConnectedRooms
  ROOM_MIN_HEIGHT =    3
  ROOM_MAX_HEIGHT =    9
  ROOM_MIN_WIDTH  =    5
  ROOM_MAX_WIDTH  =   15
  ITERATIONS      = 1000

  CAVE_HEIGHT = 40
  CAVE_WIDTH  = 80

  DOORS       = %w{ + ' }
  CORNER      = "%"
  WALL        = "#"
  FLOOR       = "."
  ROCK        = " "
  PLAYER      = "@"
  STAIRS_UP   = "▟"

  DEBUG_OK    = "?"
  DEBUG_BAD   = "x"

  TREASURES = %w{ ä $ ♦ ♥ € }
  ENTITIES = ('A'..'z').to_a + TREASURES

  attr_reader :cave_height, :cave_width, :debug, :solo_level, :map, :iterations, :room_coords

  def initialize(cave_height: CAVE_HEIGHT, cave_width: CAVE_WIDTH, debug: false, solo_level: nil)
    @cave_height = cave_height
    @cave_width = cave_width
    @debug = debug
    @solo_level = solo_level
  end

  def self.generate(**args)
    new(**args).generate
  end

  def generate
    @iterations = ITERATIONS
    @map = Array.new(cave_height) { Array.new(cave_width, ROCK) }
    @room_coords = []

    # first room can always be placed
    (tlr, tlc, brr, brc) = generate_room_coords
    plop_room(tlr, tlc, brr, brc)

    keep_generating(iterations)
    replace_corners

    if solo_level
      place_stairs
      add_entities
    end

    puts_map_debugging_whole_map true
  end

  private

  def keep_generating(iterations)
    coords = generate_room_coords
    if coords
      (tlr, tlc, brr, brc) = coords
      door_candidates = door_candidates(tlr, tlc, brr, brc)

      if door_candidates.length > 0
        plop_room(tlr, tlc, brr, brc)
        (row, col) = door_candidates.sample
        map[row][col] = DOORS.sample
        puts_map_debugging_whole_map
      end
    end

    keep_generating(iterations - 1) unless iterations < 1
  end

  def replace_corners
    cave_height.times do |row|
      cave_width.times do |col|
        map[row][col] = WALL if map[row][col] == CORNER
      end
    end
  end

  def place_stairs
    col = rand ROOM_MIN_WIDTH..ROOM_MAX_WIDTH
    row = rand ROOM_MIN_HEIGHT..ROOM_MAX_HEIGHT

    if map[row][col] == FLOOR
      map[row][col] = STAIRS_UP
    else
      place_stairs
    end
  end

  def add_entities
    max_entities = [solo_level * 2 + 14, room_coords.length * 11].min
    min_entities = [solo_level + 5, max_entities].min
    entities = rand(min_entities..max_entities).times.map { ENTITIES.sample }

    # 5% chance this map has a treasure room
    add_treasure_room if rand(20) == 1
    return unless room_coords.length > 0

    entities.each do |entity|
      (tlr, tlc, brr, brc) = room_coords.sample

      col = rand (tlc + 1)..(brc - 1) - 1
      row = rand (tlr + 1)..(brr - 1) - 1

      # the entity is thrown out if not a floor; this
      # guarantees the loop will end rather than continue
      # forever if there are no floors left
      map[row][col] = entity if map[row][col] == FLOOR
    end
  end

  def add_treasure_room
    treasure_room_coords = room_coords.shuffle!.pop
    (tlr, tlc, brr, brc) = treasure_room_coords

    Range.new(tlr+1, brr-1).all? do |row|
      Range.new(tlc+1, brc-1).all? do |col|
        map[row][col] = TREASURES.sample if map[row][col] == FLOOR
      end
    end
  end

  def generate_room_coords
    w = rand ROOM_MIN_WIDTH..ROOM_MAX_WIDTH
    h = rand ROOM_MIN_HEIGHT..ROOM_MAX_HEIGHT

    # -2 for the outer walls
    top_left_col = rand 0..((cave_width  - 2) - w)
    top_left_row = rand 0..((cave_height - 2) - h)

    bottom_right_col = top_left_col + w + 1
    bottom_right_row = top_left_row + h + 1

    puts_map_debugging_maybe_room top_left_row, top_left_col, bottom_right_row, bottom_right_col

    return nil unless valid_room_location? top_left_row, top_left_col, bottom_right_row, bottom_right_col

    [top_left_row, top_left_col, bottom_right_row, bottom_right_col]
  end

  def door_candidates tlr, tlc, brr, brc
    [].tap do |candidates|
      [tlr, brr].each do |row|
        Range.new(tlc+1, brc-1).each do |col|
          candidates << [row, col] if map[row][col] == WALL
        end
      end
      Range.new(tlr+1, brr-1).each do |row|
        [tlc, brc].each do |col|
          candidates << [row, col] if map[row][col] == WALL
        end
      end
    end
  end

  def plop_room tlr, tlc, brr, brc
    room_coords << [tlr, tlc, brr, brc]
    # corners
    [tlr, brr].each do |row|
      [tlc, brc].each do |col|
        map[row][col] = CORNER
      end
    end

    # walls
    [tlr, brr].each do |row|
      Range.new(tlc+1, brc-1).each do |col|
        map[row][col] = WALL
      end
    end
    Range.new(tlr+1, brr-1).each do |row|
      [tlc, brc].each do |col|
        map[row][col] = WALL
      end
    end

    # floors
    Range.new(tlr+1, brr-1).all? do |row|
      Range.new(tlc+1, brc-1).all? do |col|
        map[row][col] = FLOOR
      end
    end
  end

  def valid_room_location? tlr, tlc, brr, brc
    Range.new(tlr, brr).all? do |row|
      Range.new(tlc, brc).all? do |col|
        map[row][col] != FLOOR
      end
    end
  end

  def puts_map_debugging_maybe_room tlr, tlc, brr, brc
    return unless debug

    puts "`" * (cave_width + 2)
    cave_height.times do |row|
      print "`"
      cave_width.times do |col|
        if row > tlr and row < brr and col > tlc and col < brc
          print map[row][col] == ROCK ?  DEBUG_OK : DEBUG_BAD
        else
          print map[row][col] || "-"
        end
      end
      print "`\n"
    end
    puts "`" * (cave_width + 2)
  end

  def puts_map_debugging_whole_map(show = debug)
    return unless show

    puts "`" * (cave_width + 2)
    cave_height.times do |row|
      print "`"
      cave_width.times do |col|
        print map[row][col]
      end
      print "`\n"
    end
    puts "`" * (cave_width + 2)
  end
end