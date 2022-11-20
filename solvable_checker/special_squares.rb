module SpecialSquares
  def three_by_three
    Enumerator.new do |yielder|
      (-1..1).each do |x|
        (-1..1).each do |y|
          yielder << [x, y]
        end
      end
    end
  end

  def square_special_star(xx, yy, game_state)
    new_board = GameState.clone_board_array(game_state.board_array)


    (-1..1).each do |dx|
      (-1..1).each do |dy|
        target_x = xx + dx
        target_y = yy + dy

        if pos_within_margins?(target_x, target_y, game_state) && game_state.get(target_x, target_y) != "M"
          new_board[target_y][target_x] = "0" 
        end
      end
    end

    return GameState.new(new_board, additional_state: game_state.additional_state)
  end

  def square_special_cross(xx, yy, game_state)
    new_board = GameState.clone_board_array(game_state.board_array)
    
    [[0, 0], [-1, 0], [1, 0], [0, -1], [0, 1]].each do |dx, dy|
      target_x = xx + dx
      target_y = yy + dy

      if pos_within_margins?(target_x, target_y, game_state) && game_state.get(target_x, target_y) != "M"
        new_board[target_y][target_x] = "0" 
      end
    end

    return GameState.new(new_board, additional_state: game_state.additional_state)
  end

  def square_special_reviver(xx, yy, game_state, starting_game_state)
    starting_game_state ||= @starting_game_state

    target_starting_squares = three_by_three.map do |dx, dy|
      target_x = xx + dx
      target_y = yy + dy
    
      next nil unless pos_within_margins?(target_x, target_y, starting_game_state)      
      next starting_game_state.get(target_x, target_y)
    end

    teleports_in_target = target_starting_squares.count { |square| square == "T" }

    make_teleports_blank =  if teleports_in_target == 2
      false
    else
      (game_state.count { |square| square == "T" } == 0)
    end

    new_board = GameState.clone_board_array(game_state.board_array)

    three_by_three.each do |dx, dy|
      target_x = xx + dx
      target_y = yy + dy

      if pos_within_margins?(target_x, target_y, game_state)
        original_square_type = starting_game_state.get(target_x, target_y)

        blank = original_square_type == "X" || (make_teleports_blank && original_square_type == "T")

        new_type = blank ? "_" : original_square_type
        
        new_board[target_y][target_x] = new_type
      end
    end

    return GameState.new(new_board, additional_state: game_state.additional_state)
  end
end