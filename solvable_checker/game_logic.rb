module GameLogic
  def start_game(game_state)
    navigate_add_stop(game_state.start_x, game_state.start_y, game_state)
  end

  def navigate_terminate_and_check_if_solved(game_state)
    if board_is_solved?(game_state)
      add_to_success_boards(game_state)
      increment_successes()

      puts_and_log("success".blue, print_level: 2)

      if @lazy
        puts "solution was found".blue
        exit 1 
      end
    else
      add_to_fail_boards(game_state)
      increment_fails()

      puts "fail".red  if @print_level > 0
    end
  end

  def navigate_add_stop(xx, yy, current_game_state)
    # puts_and_log("caller.length = #{caller.length}")
    # if caller.length > 500
    #   puts local_variables.each_with_object({}) { |key, hash| hash[key] = eval(key.to_s) }
    #   raise "crash me" 
    # end
    updated_game_state = GameState.set_value(current_game_state, xx, yy, "0")
  
    puts_and_log("Setting value xx #{xx} yy #{yy} to 0", print_level: 1)
    updated_game_state.print() if @print_level > 1
    puts_and_log("nav add stop xx = #{xx} yy = #{yy}".green, print_level: 2)
    
    if any_moves_allowed?(xx, yy, updated_game_state)
      ["R","U","L","D"].each do |direction|
        unless move_is_allowed?(updated_game_state, xx, yy, xx + dx[direction], yy + dy[direction])
          puts "nav add stop #{direction} not allowed from #{xx} #{yy} on board #{updated_game_state.id}".green  if @print_level > 0
          next
        end

        updated_board_after_timer = increment_timers(updated_game_state)

        timer_result = any_expired_timers?(updated_board_after_timer)
        if timer_result[:expired]
          case timer_result[:type]
          when "POISON_TRIGGERED"
            puts "poison triggered trying to go #{direction}".red if @print_level > 1
            navigate_terminate_and_check_if_solved(updated_board_after_timer)
            next
          else
            raise "Unexpected resolution of timer"
          end
        end

        puts_and_log("moving #{direction} from STOP on board #{updated_board_after_timer.id}  xx = #{xx} yy = #{yy}".cyan, print_level: 1)
        navigate_move_player(xx + dx[direction], yy + dy[direction], updated_board_after_timer, direction: direction)
      end
    else
      puts_and_log("no potential moves from nav add STOP  xx=#{xx} yy=#{yy}", print_level: 1)
      navigate_terminate_and_check_if_solved(updated_game_state)
    end
  end

  def navigate_move_player(start_x, start_y, current_game_state, direction: nil)
    # puts_and_log("copying current_game_state #{current_game_state.id} in preparation for activate move:", print_level: 1)
    # current_game_state.print() if @print_level > 1

    current_game_state = current_game_state.add_input(direction) if direction
    puts_and_log("nav bf MOVE start_x = #{start_x} start_y = #{start_y}".yellow, print_level: 2)

    activation_result = navigate_activate_square!(start_x, start_y, current_game_state)

    case activation_result[:result]
    when "STOPPED"
      puts_and_log("nav bf move stopped at #{activation_result[:end_x]}  #{activation_result[:end_y]}", print_level: 1)
      activation_result[:game_state].print() if @print_level > 1

      navigate_add_stop(activation_result[:end_x], activation_result[:end_y], activation_result[:game_state])
    when "TELEPORTING"
      updated_board = GameState.set_value(activation_result[:game_state], activation_result[:end_x], activation_result[:end_y], "0")

      find_result = find_other_teleport(updated_board.board_array)

      if find_result[:success]
        target_x = find_result[:column]
        target_y = find_result[:row]
      else
        target_x = activation_result[:end_x]
        target_y = activation_result[:end_y]
      end

      navigate_add_stop(target_x, target_y, updated_board)
    when "POISONING"
      updated_board = GameState.set_value(activation_result[:game_state], activation_result[:end_x], activation_result[:end_y], "0")

      navigate_add_stop(activation_result[:end_x], activation_result[:end_y], updated_board)
    when "STAR"
      game_state_after_star = square_special_star(activation_result[:end_x], activation_result[:end_y], activation_result[:game_state])
      increment_times_hit_star()

      navigate_terminate_and_check_if_solved(game_state_after_star)
    when "CROSS"
      game_state_after_cross = square_special_cross(activation_result[:end_x], activation_result[:end_y], activation_result[:game_state])
      increment_times_hit_cross()

      navigate_terminate_and_check_if_solved(game_state_after_cross)
    when "REVIVER"
      game_state_after_reviver = square_special_reviver(activation_result[:end_x], activation_result[:end_y], activation_result[:game_state], @starting_game_state)
      increment_times_hit_reviver()

      navigate_add_stop(activation_result[:end_x], activation_result[:end_y], game_state_after_reviver)
    else
      raise "Unexpected resolution of bf_move! - #{activation_result[:result]}"
    end
  end

  def navigate_activate_square!(xx, yy, current_game_state)
    # On reaching a special action square, returns result hash
    # Else, transforms the board array in-place and calls itself recursively if the player is to keep moving
    # Result hash has the resultant position of the player, the board, and what finally stopped it

    current_square_type = current_game_state.get(xx, yy)

    case current_square_type
    when "S"
      return { end_x: xx, end_y: yy, game_state: current_game_state, result: "STAR" }
    when "C"
      return { end_x: xx, end_y: yy, game_state: current_game_state, result: "CROSS" }
    when "A"
      return { end_x: xx, end_y: yy, game_state: current_game_state, result: "REVIVER" }
    when "P"
      return { end_x: xx, end_y: yy, game_state: current_game_state.poison_player(), result: "POISONING" }
    when "T"
      return { end_x: xx, end_y: yy, game_state: current_game_state, result: "TELEPORTING" }
    when "_"
      return { end_x: xx, end_y: yy, game_state: current_game_state, result: "STOPPED" } 
    when "M"
      raise "Move activated starting on margin!"
    end

    raise "Unexpected current square type #{current_square_type}" unless current_square_type.in?(Board::NORMAL_SQUARES)

    target_x = xx + dx[current_square_type]
    target_y = yy + dy[current_square_type]

    unless move_is_allowed?(current_game_state, xx, yy, target_x, target_y)
      puts_and_log("Activating dx #{dx[current_square_type]} dy #{dy[current_square_type]} move from #{xx} #{yy} to #{target_x} #{target_y} not allowed"  ,print_level: 1)

      return { end_x: xx, end_y: yy, game_state: current_game_state, result: "STOPPED" } 
    end

    new_square_type = current_game_state.get(target_x, target_y)
    updated_game_state = GameState.set_value(current_game_state, xx, yy, "0")

    if is_not_opposite(current_square_type, new_square_type)
      puts_and_log("MOVED DX #{dx[current_square_type]} DY #{dy[current_square_type]} from x #{xx} y #{yy}", print_level: 1)

      return navigate_activate_square!(target_x, target_y, updated_game_state)
    else
      puts_and_log("REVERSE FOUND AFTER dx #{dx[current_square_type]} dy #{dy[current_square_type]} from xx #{xx} yy #{yy}", print_level: 1)
      increment_reverse_moves_counter()

      return { end_x: target_x, end_y: target_y, game_state: updated_game_state, result: "STOPPED" }
    end
  end

  def increment_timers(game_state)
    return game_state if game_state.additional_state[:poison_turns_left].nil?

    new_poison_turns = game_state.additional_state[:poison_turns_left] - 1
    return GameState.new(game_state.board_array, additional_state: game_state.additional_state.merge(poison_turns_left: new_poison_turns))
  end

  def any_expired_timers?(game_state)
    if game_state.additional_state[:poison_turns_left] && game_state.additional_state[:poison_turns_left] < 1
      return { expired: true, type: "POISON_TRIGGERED" }
    end

    return { expired: false }
  end
  
  def board_is_solved?(current_board)
    current_board.all? { |square| square.in? ["M", "0"] }
  end
  
  def any_moves_allowed?(start_x, start_y, game_state)
    move_is_allowed?(game_state, start_x, start_y, start_x - 1, start_y) ||
    move_is_allowed?(game_state, start_x, start_y, start_x + 1, start_y) ||
    move_is_allowed?(game_state, start_x, start_y, start_x, start_y - 1) ||
    move_is_allowed?(game_state, start_x, start_y, start_x, start_y + 1)
  end 

  def move_is_allowed?(game_state, _start_x, _start_y, new_x, new_y)
    target = game_state.get(new_x, new_y)
    return false unless target

    return false if target.in?(Board::ILLEGAL_SQUARES) || target == "0"

    return true
  end

end