class DrunkardsWalk
  EDGE_BUFFER = 5

  CAVE_HEIGHT = 40
  CAVE_WIDTH  = 80

  WALL        = "#"
  FLOOR       = "."
  ROCK        = " "
  STAIRS_UP   = "▟"

  TREASURES = %w{ ä $ ♦ ♥ € }
  ENTITIES = ('A'..'z').to_a + TREASURES

  attr_reader :map, :cave_height, :cave_width, :solo_level, :debug

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
    @map = Array.new(cave_height) { Array.new(cave_width, ROCK) }

    (@current_row, @current_col) = [ cave_height/2 + rand(-4..4), cave_width/2 + rand(-4..4) ]
    @floor_needed = (cave_height * cave_width * (rand(30..45) / 100.0)).floor
    @iterations = @floor_needed * 5
    @spaces = 0
    @facing = [0, 0]
    @sober = false
    @floors = []

    try_placing_floor
    generate_drunk rand(10..300)
    wallify

    if solo_level
      put_stairs
      put_entities
    end

    puts_map_debugging_whole_map true
  end

  private

  def generate_drunk steps
    return if @floor_needed < 1 || @iterations < 1

    if steps == 0
      generate_sober
    else
      turn
      walk 1
      generate_drunk steps - 1
    end
  end

  def generate_sober
    return if @floor_needed < 1 || @iterations < 1
    walk rand(5..10)
    generate_drunk rand(10..300)
  end

  def turn
    @facing = ([[0, 1], [0, -1], [1, 0], [-1,0]] - @facing).sample
  end

  def walk steps
    @iterations -= 1
    puts_map_debugging_whole_map debug, @facing
    return unless steps > 0

    face_away_from_edge if near_edge

    # in case of diagonal facing, steps must be orthogonal
    (first_step, next_step) = [ [@facing[0], 0], [0, @facing[1]]].shuffle

    @current_row += first_step[0]
    @current_col += first_step[1]
    try_placing_floor

    @current_row += next_step[0]
    @current_col += next_step[1]
    try_placing_floor

    walk steps - 1
  end

  def try_placing_floor
    return unless map[@current_row][@current_col] == ROCK

    @floor_needed -= 1
    @spaces += 1
    @floors << [@current_row, @current_col]
    map[@current_row][@current_col] = FLOOR
  end

  def near_edge
    @current_row <= 2 && @facing[0] == -1 ||
      @current_row >= cave_height - 3 && @facing[0] == 1 ||
      @current_col <= 2 && @facing[1] == -1 ||
      @current_col >= cave_width - 3 && @facing[1] == 1
  end

  def face_away_from_edge
    # if within 5 from an edge, face away. if there aer two edges, face away from both, 20% chance to pick only one
    dr = oppose_edge(@cave_height, @current_row, EDGE_BUFFER)
    dc = oppose_edge(@cave_width, @current_col, EDGE_BUFFER)

    @facing = [dr, dc]
    return if dr == 0 || dc == 0

    case rand(1..10)
    when 10; @facing = [dr, 0]
    when 9; @facing = [0, dc]
    else; @facing = [dr,dc]
    end
  end

  def oppose_edge max_dimension, current_position, buffer_distance
    if  buffer_distance > current_position
      1
    elsif max_dimension - 2 - buffer_distance < current_position
      -1
    else
      0
    end
  end

  def wallify
    cave_height.times do |row|
      cave_width.times do |col|
        map[row][col] = WALL if should_be_wall?(row, col)
      end
    end
  end

  def should_be_wall?(row, col)
    map[row][col] == ROCK &&
      [
        [row+1,col],
        [row+1,col+1],
        [row+1,col-1],
        [row-1,col],
        [row-1,col+1],
        [row-1,col-1],
        [row,col-1],
        [row,col+1]
      ].any? { |(row, col)| row >= 0 && col >= 0 && map.dig(row, col) == FLOOR }
  end

  def put_stairs
    (stair_row, stair_col) = @floors.shuffle!.pop
    map[stair_row][stair_col] = STAIRS_UP
  end

  def put_entities
    max_entities = [solo_level * 3, (cave_height * cave_width * 0.15).round].min
    min_entities = [solo_level + 5, max_entities].min
    entities = rand(min_entities..max_entities)

    @floors.sample(entities).each do |(row,col)|
      map[row][col] = ENTITIES.sample
    end
  end

  def puts_map_debugging_whole_map(show = debug, facing = nil)
    return unless show

    add_facing(facing) if facing

    puts "`" * (cave_width + 2)
    cave_height.times do |row|
      print "`"
      cave_width.times do |col|
        print map[row][col]
      end
      print "`\n"
    end
    puts "`" * (cave_width + 2)

    restore_current_position_tile
    puts "spaces: #{@spaces}, floors needed: #{@floor_needed}; iterations left: #{@iterations}"
    sleep 0.1
  end

  def save_current_position_tile
    @current_pos_tile = map[@current_row][@current_col]
  end

  def add_facing facing
    save_current_position_tile

    char = case facing
           when [ 1, 0]; "2"
           when [ 0, 1]; "6"
           when [-1, 0]; "8"
           when [ 0,-1]; "4"
           when [ 1, 1]; "3"
           when [ 1,-1]; "1"
           when [-1, 1]; "9"
           when [-1,-1]; "7"
           else; "x"
           end
    map[@current_row][@current_col] = char
  end

  def restore_current_position_tile
    map[@current_row][@current_col] = @current_pos_tile if @current_pos_tile
    @current_pos_tile = nil
  end
end
