module SquareLogic
  def dx
    { "R" => 1, "U" => 0, "L"=> -1, "D" => 0 }
  end

  def dy
    { "R" => 0, "U" => -1, "L" => 0, "D" => 1 }
  end

  def is_not_opposite(start_type, end_type)
    return false if start_type == "L" && end_type == "R"
    return false if start_type == "U" && end_type == "D"
    return false if start_type == "R" && end_type == "L"
    return false if start_type == "D" && end_type == "U"

    return true
  end

  def pos_within_margins?(xx, yy, game_state)
    xx >= 0                      &&
    xx < game_state.columns      &&
    yy >= 0                      &&
    yy < game_state.rows
  end

  def find_other_teleport(board_array)
    game_state = GameState.new(board_array)

    number_of_teleports = game_state.count { |square| square == "T" }

    raise "Too many teleports" if number_of_teleports > 1
    return { success: false } if number_of_teleports == 0

    row = board_array.find_index { |row_array| row_array.include?("T") }
    column = board_array.find { |row_array| row_array.include?("T") }.find_index { |square| square == "T" }

    return { column: column, row: row, success: true }
  end

end