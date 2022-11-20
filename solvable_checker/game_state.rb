require 'active_support/all'
require_relative '../board_creation/board'

class GameState
  include Enumerable
  
  @id = 0
  
  def self.id
    @id
  end

  def self.id=(val)
    @id = val
  end

  attr_reader :start_x, :start_y, :board_array, :columns, :rows, :id, :additional_state

  def self.clone_board_array(old_array)
    height = old_array.length
    width = old_array.first.length

    return Array.new(height) do |y|
      Array.new(width) do |x|
        next old_array[y][x]
      end
    end
  end

  def self.set_value(game_state, target_x, target_y, new_value)
    unless game_state && target_x && target_y && new_value
      raise "nil value passed to set_value game_state: #{game_state} x: #{target_x} y: #{target_y} new_value: new_value" 
    end

    new_board_array = GameState.clone_board_array(game_state.board_array)
    new_board_array[target_y][target_x] = new_value

    new_board = GameState.new(new_board_array, additional_state: game_state.additional_state)

    return new_board
  end

  def initialize(board_array, additional_state: nil )
    @board_array = board_array

    @rows = board_array.length
    @columns = board_array.first.length

    @id = GameState.id
    GameState.id += 1

    @additional_state = additional_state || {
      poison_turns_left: nil,
      inputs: nil
    }

    # Find start coods
    board_array.find.with_index do |row_array, y|
      row_array.find.with_index do |square, x|
        if square == "X"
          @start_x = x
          @start_y = y
          next true
        end
      end
    end
  end

  def each(&block)
    raise "Cannot iterate over blank board array" unless @board_array

    @board_array.each do |row_array|
      row_array.each do |square|
        block.call(square)
      end
    end
  end

  def [](index)
    @board_array[index]
  end

  def get(xx, yy)
    return nil if xx < 0 || yy < 0
    return nil unless @board_array[yy]
    return @board_array[yy][xx]
  end

  def print()
    @board_array.each do |row_array|
      row_array_str = row_array.sum("") do |square|
        case square
        when "X"
          square.green
        when "T"
          square.magenta
        when "0"
          square.blue
        when "P"
          square.red
        when "S", "C"
          square.yellow
        when "M"
          square.border
        else
          square
        end
      end

      # Weirdly, simply having puts before row_array.sum loses colouring
      puts row_array_str
    end
  end

  def add_input(direction)
    return GameState.new(
      @board_array,
      additional_state: @additional_state.merge(inputs: [*@additional_state[:inputs], direction])
    )
  end

  def poison_player
    # raise "cannot double poison" unless @additional_state[:poison_turns_left].nil?
    
    return GameState.new(@board_array, additional_state: @additional_state.merge(poison_turns_left: 4))
  end

end
