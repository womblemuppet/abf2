class ValidityChecker
  def initialize(log: [], print_level: 0)
    @log = log
    @print_level = print_level
    @number_of_tests = 0
    @number_of_valid_boards = 0
  end

  def puts_and_log(*msg, print_level: 0)
    @log = [*@log, *msg]
    puts msg if print_level <= @print_level
  end
  
  def run_validate(board)
    @number_of_tests += 1
    board_validation_result = validate(board)

    if board_validation_result[:valid]
      @number_of_valid_boards += 1
    else
      puts_and_log("#{@number_of_tests}:\n#{board}#{board_validation_result[:msg]}\n", print_level: 1)
    end

    return board_validation_result[:valid]
  end

  def report_start
    "#{@number_of_valid_boards} out of #{@number_of_tests} valid\n"
  end

  def get_log
    [report_start, *@log]
  end

  def validate(board)
    return { valid: false, msg: "No start square found" } unless board.find { |square, _x, _y| square == "X" }
    
    corner_squares = [
      board.get(0, 0),
      board.get(0, board.rows - 1),
      board.get(board.columns - 1, 0),
      board.get(board.columns - 1, board.rows - 1)
    ]

    all_corners_are_margins = corner_squares.all? { |square| square == "M" }

    return { valid: false, msg: "Corners are not margins: #{corner_squares.inspect} #{board.columns} #{board.rows}" } unless all_corners_are_margins

    board.any? do |square, _x, _y|
      return { valid: false, msg: "Nil square" } if square.nil?
      return { valid: false, msg: "Unrecognised square: #{square.inspect}" } unless square.in?(Board::ALL_SQUARES)
    end

    return { valid: true, msg: "Board is valid" }
  end

end