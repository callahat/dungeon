class Labyrinth
  CAVE_HEIGHT    = 29
  CAVE_WIDTH     = 79

  WALL           = "#"
  FLOOR          = "."
  ROCK           = " "
  STAIRS_UP      = "▟"

  DEBUG_FRONTIER = "?"

  ADJACENT_LOCATION_DELTAS = [[-2, 0], [2, 0], [0, -2], [0, 2]]
  ADJACENT_STEP_DELTAS     = ADJACENT_LOCATION_DELTAS.map {|(r,c)| [ r/2, c/2]}

  TREASURES = %w{ ä $ ♦ ♥ € }
  ENTITIES = ('A'..'z').to_a + TREASURES

  attr_reader :cave_height, :cave_width, :debug, :solo_level, :map, :frontier, :dead_ends

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
    @map = Array.new(cave_height) { Array.new(cave_width, WALL) }
    @frontier = []
    @dead_ends = []

    # starting frontier and location
    add_to_frontier([ rand(cave_height / 2) * 2 + 1, rand(cave_width / 2) * 2 + 1 ])

    keep_generating
    put_stairs
    put_entities

    puts_map_debugging
  end

  private

  def keep_generating
    pick_a_location

    # each direction has a 75% chance of connecting to the nearby eligible frontier
    ADJACENT_LOCATION_DELTAS.each do |(row_delta, col_delta)|
      maybe_dig(row_delta, col_delta)
    end

    add_to_frontier [@current_row, @current_col]

    update_valid_frontier

    puts_map_debugging

    keep_generating unless @frontier == []
  end

  def add_to_frontier row_col
    @frontier << row_col
  end

  def pick_a_location
    (@current_row, @current_col) = @frontier.shuffle!.pop
  end

  def maybe_dig(row_delta, col_delta)
    return unless rand(4) != 0 and is_wall?(@current_row + row_delta, @current_col + col_delta)

    map[@current_row + row_delta  ][@current_col + col_delta  ] = FLOOR
    map[@current_row + row_delta/2][@current_col + col_delta/2] = FLOOR

    add_to_frontier([@current_row + row_delta, @current_col + col_delta])
  end

  def in_bounds(row, col)
    row >= 0 and row < cave_height and
      col >= 0 and col < cave_width
  end

  def is_wall?(row, col)
    in_bounds(row, col) and map[row][col] == WALL
  end

  def invalid_frontier?(row, col)
    !in_bounds(row, col) or map[row][col] != WALL
  end

  def update_valid_frontier
    @frontier.reject! do |(row, col)|
      adjacent_locations(row, col).none? { |row, col| is_wall?(row, col) }.tap do |no_frontier|
        # keep track of the dead ends, these are safe places to put things that might block traversal
        # of the map such as boulders or stairs
        @dead_ends << [row, col] if no_frontier and only_one_conection?(row, col)
      end
    end
  end

  def only_one_conection?(row, col)
    adjacent_steps(row,col).one? do |(r, c)|
      in_bounds(r, c) and map[r][c] == FLOOR
    end
  end

  def adjacent_locations(row, col)
    ADJACENT_LOCATION_DELTAS.map{ |row_d, col_d| [row + row_d, col + col_d]}
  end

  def adjacent_steps(row, col)
    ADJACENT_STEP_DELTAS.map{ |row_d, col_d| [row + row_d, col + col_d]}
  end

  def put_stairs
    (stair_row, stair_col) = @dead_ends.shuffle!.pop
    map[stair_row][stair_col] = STAIRS_UP
  end

  def put_entities
    max_entities = [solo_level * 3, (cave_height * cave_width * 0.15).round].min
    min_entities = [solo_level + 5, max_entities].min
    entities = rand(min_entities..max_entities)

    @dead_ends.sample(entities).each do |(row,col)|
      map[row][col] = ENTITIES.sample
    end
  end


  def puts_map_debugging
    return unless debug

    puts "`" * (cave_width + 2)
    cave_height.times do |row|
      print "`"
      cave_width.times do |col|
        if @frontier.member? [row, col]
          print DEBUG_FRONTIER
        else
          print map[row][col] || "-"
        end
      end
      print "`\n"
    end
    puts "`" * (cave_width + 2)

    sleep 0.1
  end

end
