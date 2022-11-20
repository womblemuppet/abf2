class Board
  include Enumerable
  attr_accessor :board_array, :rows, :columns

  ILLEGAL_SQUARES = ["M"] # Player can not move to these positions
  NORMAL_SQUARES = ["L", "U", "R", "D"]
  SPECIAL_SQUARES = ["S", "T", "X", "C", "P", "A", "_"]
  ALL_SQUARES = [*NORMAL_SQUARES, *SPECIAL_SQUARES, *ILLEGAL_SQUARES]

  @@coordinate = Struct.new(:x, :y)
  def self.coordinate
    @@coordinate
  end

  def initialize(board_array)
    @board_array = board_array

    raise "Empty board array given!" if board_array.empty?

    @rows = board_array.length
    @columns = board_array.first.length
  end

  def each(&block)
    @board_array.each.with_index do |row_array, y|
      row_array.each.with_index do |square, x|
        block.call(square, x, y)
      end
    end
  end

  def [](index)
    @board_array[index]
  end

  def get(xx, yy)
    raise "#{xx} #{yy} out of bounds for board of size r#{@rows} c#{@columns}" unless @board_array[yy] && @board_array[yy][xx]
    
    return @board_array[yy][xx]
  end

  def set(xx, yy, value)
    @board_array[yy][xx] = value
  end

  def to_s
    @board_array.sum("") { |row_array| row_array.join() + "\n" }
  end

  def all_square_coordinates
    inject([]) { |acc, (square, x, y)| [*acc, @@coordinate.new(x, y)] }
  end
  
end