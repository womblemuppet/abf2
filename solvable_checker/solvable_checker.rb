require_relative 'game_logic'
require_relative 'game_state'
require_relative 'square_logic'
require_relative 'special_squares'
require_relative 'terminal_colouring'

class SolvableChecker
  attr_reader :fail_success_ratio, :starting_game_state, :successes, :fails, :times_hit_cross, :times_hit_star, :log, :id

  include GameLogic
  include SpecialSquares
  include SquareLogic

  @id = 0
  
  def self.id
    @id
  end

  def self.id=(val)
    @id = val
  end

  def puts_and_log(*msg, print_level: 0)
    @log = [*@log, *msg]
    puts msg if print_level <= @print_level
  end

  def initialize(starting_game_state, print_level: 0, lazy: false, log: [])
    @starting_game_state = starting_game_state
    @print_level = print_level
    @lazy = lazy
    @successes = 0.0
    @fails = 0.0
    @reverse_moves = 0

    @times_hit_star = 0
    @times_hit_cross = 0
    @times_hit_reviver = 0

    @fail_success_ratio = nil
    @success_boards = []
    @fail_boards = []
    @log = log

    @id = SolvableChecker.id
    SolvableChecker.id += 1
  end

  def initiate
    start_time = Time.now
    puts_and_log("Starting solvable check for #{id}:", print_level: 2)
    @starting_game_state.print() if @print_level > 2

    begin
      start_game(@starting_game_state)
    rescue => e
      puts_and_log("\nERROR:\n#{e}")
      raise
    end

    if @print_level > 1
      puts "Success boards:"
      @success_boards.each { |b| b.print() }

      puts "Fail boards:"
      @fail_boards.each { |b| b.print() }
    end

    puts_and_log("\nSuccesses #{@successes}", print_level: 1)
    puts_and_log("Fails #{@fails}", print_level: 1)
    puts_and_log("Reverse moves #{@reverse_moves}", print_level: 1)
    puts_and_log("Times hit star #{@times_hit_star}", print_level: 1)
    puts_and_log("Times hit cross #{@times_hit_cross}", print_level: 1)

    @fail_success_ratio = if @successes == 0 
      100
    elsif @fails == 0
      0
    else
      @fails / @successes
    end

    puts_and_log("Fail to Success ratio #{@fail_success_ratio}", print_level: 1)
  
    elapsed_time = Time.now - start_time
    puts_and_log("Total time taken: #{elapsed_time}", print_level: 2)
  end

  def passed_test?
    raise "Must first initiate test" if @success_boards.empty? && @fail_boards.empty?
    
    @success_boards.size > 0
  end

  def calculate_stats
    total_attempts = @fails + @successes
    @average_reverse_moves = @reverse_moves / total_attempts if total_attempts !=0
  end

  def increment_reverse_moves_counter
    @reverse_moves += 1
  end

  def increment_times_hit_star
    @times_hit_star += 1
  end

  def increment_times_hit_cross
    @times_hit_cross += 1
  end

  def increment_times_hit_reviver
    @times_hit_reviver += 1
  end

  def increment_fails
    @fails += 1
  end

  def increment_successes
    @successes += 1
  end

  def add_to_success_boards(new_game_state)
    # binding.pry
    @success_boards = [ *@success_boards, new_game_state ]
  end

  def add_to_fail_boards(new_game_state)
    @fail_boards = [ *@fail_boards, new_game_state ]
  end

end
