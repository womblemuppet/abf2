require 'rspec'
require_relative '../solvable_checker'
require_relative '../../validity_checker'

# Stub logs
def log(*args)
  return
end


describe GameState do
  before do
    solvable_board_array_1 = [
      ["M","M","M","M","M","M"],
      ["M","R","L","U","D","M"],
      ["M","L","U","L","D","M"],
      ["M","R","U","X","L","M"],
      ["M","L","D","S","D","M"],
      ["M","M","M","M","M","M"]
    ]

    @solvable_board_1 = GameState.new(solvable_board_array_1)

    solvable_board_array_2 = [
      ["M","M","M","M","M","M"],
      ["M","R","L","D","D","M"],
      ["M","R","U","R","D","M"],
      ["M","R","R","X","R","M"],
      ["M","U","R","L","U","M"],
      ["M","M","M","M","M","M"]
    ]

    @solvable_board_2 = GameState.new(solvable_board_array_2)
  end

  context "when getting a square" do
    it "gets the right value (0,0)" do
      expect(@solvable_board_1.get(0, 0)).to eq("M")
    end

    it "gets the right value (1,1)" do
      expect(@solvable_board_1.get(1, 1)).to eq("R")
    end

    it "gets the right value (2,3)" do
      expect(@solvable_board_1.get(2, 3)).to eq("U")
    end

    it "gets the right value (3,4)" do
      expect(@solvable_board_1.get(3, 4)).to eq("S")
    end
  end

  context "when validating a board (1)" do
    before do
      @validity_checker = ValidityChecker.new()
    end

    it "returns true on a normal board" do
      result = @validity_checker.run_validate(@solvable_board_1)  
      expect(result).to eq(true)
    end

    it "returns true on a normal board (2)" do
      result = @validity_checker.run_validate(@solvable_board_2)  
      expect(result).to eq(true)
    end

    it "returns false on a board without a start" do
      no_start_square_board_array = [
        ["M","M","M","M","M","M"],
        ["M","R","R","R","R","M"],
        ["M","U","L","L","L","M"],
        ["M","R","R","R","R","M"],
        ["M","U","L","L","U","M"],
        ["M","M","M","M","M","M"]
      ]
      @no_start_square_board = GameState.new(no_start_square_board_array)

      result = @validity_checker.run_validate(@no_start_square_board)  
      expect(result).to eq(false)
    end
    
    it "returns false on a board with a nil square" do
      nil_square_board_array = [
        ["M","M","M","M","M","M"],
        ["M","R","R","R","R","M"],
        ["M","U","X","L","L","M"],
        ["M","R","R","R","R","M"],
        ["M","U",nil,"L","U","M"],
        ["M","M","M","M","M","M"]
      ]
      @nil_square_board = GameState.new(nil_square_board_array)

      result = @validity_checker.run_validate(@nil_square_board)  
      expect(result).to eq(false)
    end

    it "returns false on a board with a non-valid square" do
      q_square_board_array = [
        ["M","M","M","M","M","M"],
        ["M","R","R","R","R","M"],
        ["M","U","X","L","L","M"],
        ["M","R","R","R","R","M"],
        ["M","U","R","L","U","M"],
        ["M","M","M","M","M","q"]
      ]
      @q_square_board = GameState.new(q_square_board_array)

      result = @validity_checker.run_validate(@q_square_board)  
      expect(result).to eq(false)
    end
    
  end

  context "when finding the start position in a board array" do
    before do
      no_start_square_board_array = [
        ["M","M","M","M","M","M"],
        ["M","R","R","R","R","M"],
        ["M","U","L","L","L","M"],
        ["M","R","R","R","R","M"],
        ["M","U","L","L","U","M"],
        ["M","M","M","M","M","M"]
      ]
      @no_start_square_board = GameState.new(no_start_square_board_array)

      start_square_board_array = [
        ["M","M","M","M","M","M"],
        ["M","R","X","R","R","M"],
        ["M","U","L","L","L","M"],
        ["M","R","R","R","R","M"],
        ["M","U","L","L","U","M"],
        ["M","M","M","M","M","M"]
      ]
      @start_square_board = GameState.new(start_square_board_array)
    end

    it "finds start_x in a board array" do
      expect(@start_square_board.start_x).to be(2)
    end
     
    it "finds start_y in a board array" do
      expect(@start_square_board.start_y).to be(1)
    end

    it "does not find start_x when there is no start square in a board array" do
      expect(@no_start_square_board.start_x).to be(nil)
    end

    it "does not find start_y when there is no start square in a board array" do
      expect(@no_start_square_board.start_y).to be(nil)
    end
  end
end

describe SolvableChecker do
  before do
    solvable_board_array_1 = [
      ["M","M","M","M","M","M"],
      ["M","R","R","R","R","M"],
      ["M","U","L","L","L","M"],
      ["M","R","R","R","R","M"],
      ["M","U","L","X","L","M"],
      ["M","M","M","M","M","M"]
    ]

    @solvable_board_1 = GameState.new(solvable_board_array_1)
  end

  let(:game_logic_class) { Class.new { extend GameLogic } }
  let(:special_squares_class) { Class.new { extend SpecialSquares; extend SquareLogic } }
  

  context "checking if a board state is solved" do
    it "identifies unsolved boards" do
      expect(game_logic_class.board_is_solved?(@solvable_board_1)).to be(false)
    end

    it "identifies solved boards" do
      solved_board_array_1 = [
        ["M","0","M","M","M","M"],
        ["M","0","0","M","M","0"],
        ["M","0","0","0","M","M"],
        ["M","0","0","M","M","M"],
        ["M","0","0","0","M","M"],
        ["M","0","M","0","M","M"]
      ]
      solved_board_1 = GameState.new(solved_board_array_1)

      expect(game_logic_class.board_is_solved?(solved_board_1)).to be(true)
    end
  end

  context "checking movement eligibility" do
    it "allows a player to move to a normal square" do
      expect(game_logic_class.move_is_allowed?(@solvable_board_1, 4 ,4 ,3, 4)).to be(true)
    end

    it "doesn't allow a player to move to a margin" do
      expect(game_logic_class.move_is_allowed?(@solvable_board_1, 4 ,4 ,5, 4)).to be(false)
    end

    it "doesn't allow a player to move to a used square" do
      test_board_array_with_zero = [
        ["M","R","R","R","R","M"],
        ["M","U","L","L","L","M"],
        ["M","R","R","R","L","M"],
        ["M","R","R","R","R","M"],
        ["M","U","L","0","X","M"],
        ["M","R","R","R","R","M"]
      ]
      test_board_with_zero = GameState.new(test_board_array_with_zero)

      expect(game_logic_class.move_is_allowed?(test_board_with_zero, 4, 4, 3, 4)).to be(false)
    end
  end

  context "cloning board array" do
    before do
      @test_board_array = [
        ["M","R","R","R","R","M"],
        ["M","U","L","L","L","M"],
        ["M","R","R","R","L","M"],
        ["M","R","R","R","R","M"],
        ["M","U","L","L","X","M"],
        ["M","R","R","R","R","M"]
      ]
    end

    it "should create a new board array" do
      expect(GameState.clone_board_array(@test_board_array)).not_to equal(@test_board_array)
    end
    
    it "should create a board array with the same data" do
      expect(GameState.clone_board_array(@test_board_array)).to match_array(@test_board_array)
    end
  end

  context "setting a board array value" do
    before do
      @print_level = 0
    end

    it "sets a value inside a board array" do 
      updated_board = GameState.set_value(@solvable_board_1, 2, 2, "A")
      expect(updated_board.board_array[2][2]).to eq("A")
    end

    it "sets a value inside a board array" do 
      updated_board = GameState.set_value(@solvable_board_1, 2, 4, "B")
      expect(updated_board.board_array[4][2]).to eq("B")
    end

    it "sets a value inside a board array" do 
      updated_board = GameState.set_value(@solvable_board_1, 0, 5, "C")
      expect(updated_board.board_array[5][0]).to eq("C")
    end
  end

  context "checking if a board if solvable" do
    before do
      @test_inst = SolvableChecker.new(@solvable_board_1, print_level: 1)
    end

    it "checks if a board is solvable without erroring" do
      expect { @test_inst.initiate() }.not_to raise_error
    end
  end

  context "activating a star" do
    before do
      @before_star_array = [
        ["M","M","M","M","M","M"],
        ["M","R","R","R","R","M"],
        ["M","U","L","L","L","M"],
        ["M","R","R","R","R","M"],
        ["M","U","L","X","L","M"],
        ["M","M","M","M","M","M"]
      ]

      @before_board = GameState.new(@before_star_array)

      @before_star_array_two = [
        ["M","M","M","M","M","M"],
        ["M","0","0","0","0","M"],
        ["M","0","0","L","0","M"],
        ["M","0","0","0","0","M"],
        ["M","L","D","L","D","M"],
        ["M","M","M","M","M","M"]
      ]

      @before_board_two = GameState.new(@before_star_array_two)
    end
  
    it "hits the correct squares in a 3 by 3 shape" do
      expected_after_board_array = [
        ["M","M","M","M","M","M"],
        ["M","0","0","0","R","M"],
        ["M","0","0","0","L","M"],
        ["M","0","0","0","R","M"],
        ["M","U","L","X","L","M"],
        ["M","M","M","M","M","M"]
      ]

      after_board = special_squares_class.square_special_star(2, 2, @before_board)
      after_star_array = after_board.board_array
      expect(after_star_array).to eq(expected_after_board_array)
    end

    it "hits the correct squares in a 3 by 3 shape (two)" do
      expected_after_board_array_two = [
        ["M","M","M","M","M","M"],
        ["M","0","0","0","0","M"],
        ["M","0","0","L","0","M"],
        ["M","0","0","0","0","M"],
        ["M","L","0","0","0","M"],
        ["M","M","M","M","M","M"]
      ]

      after_board = special_squares_class.square_special_star(3, 4, @before_board_two)
      after_star_array = after_board.board_array
      expect(after_star_array).to eq(expected_after_board_array_two)
    end
    
    it "does not raise out of bounds error when exploding on margin" do
      expect { special_squares_class.square_special_star(6, 6, @before_board) }.not_to raise_error
    end
  end
  
  context "activating a cross" do
    before do
      @before_cross_array = [
        ["M","M","M","M","M","M"],
        ["M","R","R","R","R","M"],
        ["M","U","L","L","L","M"],
        ["M","R","R","R","R","M"],
        ["M","U","L","X","L","M"],
        ["M","M","M","M","M","M"]
      ]

      @before_board = GameState.new(@before_cross_array)

      @before_cross_array_two = [
        ["M","M","M","M","M","M"],
        ["M","0","0","0","0","M"],
        ["M","0","0","L","0","M"],
        ["M","0","0","0","0","M"],
        ["M","L","D","S","D","M"],
        ["M","M","M","M","M","M"]
      ]

      @before_board_two = GameState.new(@before_cross_array_two)
    end
  
    it "hits the correct squares in a 3 by 3 shape" do
      expected_after_board_array = [
        ["M","M","M","M","M","M"],
        ["M","R","0","R","R","M"],
        ["M","0","0","0","L","M"],
        ["M","R","0","R","R","M"],
        ["M","U","L","X","L","M"],
        ["M","M","M","M","M","M"]
      ]

      after_board = special_squares_class.square_special_cross(2, 2, @before_board)
      after_cross_array = after_board.board_array
      expect(after_cross_array).to eq(expected_after_board_array)
    end

    it "hits the correct squares in a 3 by 3 shape (two)" do
      expected_after_board_array_two = [
        ["M","M","M","M","M","M"],
        ["M","0","0","0","0","M"],
        ["M","0","0","L","0","M"],
        ["M","0","0","0","0","M"],
        ["M","L","0","0","0","M"],
        ["M","M","M","M","M","M"]
      ]

      after_board = special_squares_class.square_special_cross(3, 4, @before_board_two)
      after_cross_array = after_board.board_array
      expect(after_cross_array).to eq(expected_after_board_array_two)
    end
    
    it "does not raise out of bounds error when exploding on margin" do
      expect { special_squares_class.square_special_cross(6, 6, @before_board) }.not_to raise_error
    end
  end



  context "activating a reviver" do
    before do
      before_reviver_array = [
        ["M","M","M","M","M","M"],
        ["M","R","R","R","R","M"],
        ["M","T","T","L","L","M"],
        ["M","R","R","R","R","M"],
        ["M","U","L","X","L","M"],
        ["M","M","M","M","M","M"]
      ]

      @original_game_state = GameState.new(before_reviver_array)

      before_reviver_array_two = [
        ["L","R","L","T"],
        ["R","D","D","P"],
        ["R","L","X","L"],
        ["D","T","U","D"],
        ["M","M","L","M"]
      ]

      @original_game_state_two = GameState.new(before_reviver_array_two)

      before_reviver_array_one_tele = [
        ["M","M","M","M","M","M"],
        ["M","R","R","R","R","M"],
        ["M","U","T","L","L","M"],
        ["M","R","R","R","R","M"],
        ["M","U","L","X","L","M"],
        ["M","M","M","M","M","M"]
      ]

      @original_game_state_one_tele = GameState.new(before_reviver_array_one_tele)
    end
  
    it "revives in a 3 by 3 shape" do
      board_array = GameState.clone_board_array(@original_game_state.board_array)
      
      board_array[1][1] = "0"
      board_array[1][2] = "0"
      board_array[1][3] = "0"
      
      board_array[2][1] = "0"
      board_array[2][2] = "0"
      board_array[2][3] = "0"

      board_array[3][1] = "0"
      board_array[3][2] = "0"
      board_array[3][3] = "0"

      current_game_state = GameState.new(board_array)

      expected_after_board_array = [
        ["M","M","M","M","M","M"],
        ["M","R","R","R","R","M"],
        ["M","T","T","L","L","M"],
        ["M","R","R","R","R","M"],
        ["M","U","L","X","L","M"],
        ["M","M","M","M","M","M"]
      ]

      after_board = special_squares_class.square_special_reviver(2, 2, current_game_state, @original_game_state)
      after_reviver_array = after_board.board_array

      expect(after_reviver_array).to eq(expected_after_board_array)
    end
     
    it "revives in a 3 by 3 shape (2)" do
      board_array = GameState.clone_board_array(@original_game_state_two.board_array)
      
      board_array[3][1] = "0"
      board_array[3][2] = "0"
      board_array[3][3] = "0"

      board_array[4][2] = "0"

      current_game_state = GameState.new(board_array)

      expected_after_board_array = [
        ["L","R","L","T"],
        ["R","D","D","P"],
        ["R","L","X","L"],
        ["D","T","U","D"],
        ["M","M","L","M"]
      ]

      after_board = special_squares_class.square_special_reviver(2, 4, current_game_state, @original_game_state_two)
      after_reviver_array = after_board.board_array

      expect(after_reviver_array).to eq(expected_after_board_array)
    end

    it "turns a lone teleport into a blank square" do
      board_array = GameState.clone_board_array(@original_game_state.board_array)
      
      board_array[1][1] = "0"
      board_array[1][2] = "0"
      board_array[1][3] = "0"
      
      board_array[2][1] = "0"
      board_array[2][2] = "0"
      board_array[2][3] = "0"

      board_array[3][1] = "0"
      board_array[3][2] = "0"
      board_array[3][3] = "0"

      current_game_state = GameState.new(board_array)

      expected_after_board_array = [
        ["M","M","M","M","M","M"],
        ["M","R","R","R","R","M"],
        ["M","U","_","L","L","M"],
        ["M","R","R","R","R","M"],
        ["M","U","L","X","L","M"],
        ["M","M","M","M","M","M"]
      ]

      after_board = special_squares_class.square_special_reviver(2, 2, current_game_state, @original_game_state_one_tele)
      after_reviver_array = after_board.board_array

      expect(after_reviver_array).to eq(expected_after_board_array)
    end

    it "does not raise out of bounds error when exploding on margin" do
      current_game_state = @original_game_state
      expect { special_squares_class.square_special_reviver(6, 6, current_game_state, @original_game_state) }.not_to raise_error
    end
  end

  context "finding a teleport square" do
    before do
      @single_teleport_board_array = [
        ["M","M","M","M","M","M"],
        ["M","R","R","R","R","M"],
        ["M","U","L","T","L","M"],
        ["M","R","R","R","R","M"],
        ["M","U","L","X","L","M"],
        ["M","M","M","M","M","M"]
      ]

      @double_teleport_board_array = [
        ["M","M","M","M","M","M"],
        ["M","R","R","R","R","M"],
        ["M","U","L","T","T","M"],
        ["M","R","R","R","R","M"],
        ["M","U","L","X","L","M"],
        ["M","M","M","M","M","M"]
      ]

      @no_teleport_board_array = [
        ["M","M","M","M","M","M"],
        ["M","R","R","R","R","M"],
        ["M","U","L","L","L","M"],
        ["M","R","R","R","R","M"],
        ["M","U","L","X","L","M"],
        ["M","M","M","M","M","M"]
      ]
    end

    it "finds a single teleport" do
      result = special_squares_class.find_other_teleport(@single_teleport_board_array)
      expect(result[:row]).to eq(2)
      expect(result[:column]).to eq(3)
    end

    it "returns nil if no teleport" do
      result = special_squares_class.find_other_teleport(@no_teleport_board_array)
      expect(result[:success]).to eq(false)
    end

    it "raises an error on more than one teleport" do
      expect { special_squares_class.find_other_teleport(@double_teleport_board_array) }.to raise_error(RuntimeError)
    end
  end

  context "evaluating whether a square chains" do
    it "chains from L to U" do
      expect(special_squares_class.is_not_opposite("L","U")).to eq(true)
    end
    
    it "doesn't chain from L to R" do
      expect(special_squares_class.is_not_opposite("L", "R")).to eq(false)
    end
    
    it "chains from L to D" do
      expect(special_squares_class.is_not_opposite("L", "D")).to eq(true)
    end

    it "doesn't chain from D to U" do
      expect(special_squares_class.is_not_opposite("D", "U")).to eq(false)
    end

    it "chains from D to R" do
      expect(special_squares_class.is_not_opposite("D", "R")).to eq(true)
    end
  end

  context "activating a square" do
    before do
      big_chain_array = [
        ["M","M","M","M","M","M"],
        ["M","R","R","R","R","M"],
        ["M","R","L","L","L","M"],
        ["M","R","R","U","U","M"],
        ["M","U","L","L","X","M"],
        ["M","M","M","M","M","M"]
      ]
      @big_chain_board = GameState.new(big_chain_array)

      big_chain_array_two = [
        ["M","M","M","M","M","M"],
        ["M","D","L","L","X","M"],
        ["M","R","R","D","L","M"],
        ["M","R","R","D","L","M"],
        ["M","U","L","R","U","M"],
        ["M","M","M","M","M","M"]
      ]
      @big_chain_board_two = GameState.new(big_chain_array_two)
    end

    it "chains movements squares and then stop on a reverse square at the correct x coordinate" do
      test_inst = SolvableChecker.new(@big_chain_board, print_level: 2)
      result = test_inst.navigate_activate_square!(3, 4, @big_chain_board)
      expect(result[:end_x]).to eq(1)
    end
    
    it "chains movements squares and then stop on a reverse square at the correct y coordinate" do
      test_inst = SolvableChecker.new(@big_chain_board, print_level: 1)
      result = test_inst.navigate_activate_square!(3, 4, @big_chain_board)
      expect(result[:end_y]).to eq(2)
    end

    it "sets used squares to '0' while chaining" do
      test_inst = SolvableChecker.new(@big_chain_board, print_level: 1)
      game_state = test_inst.navigate_activate_square!(3, 4, @big_chain_board)[:game_state]
      expect(game_state.get(3, 4)).to eq("0")
    end

    it "chains movements squares and then stop on a reverse square at the correct x coordinate" do
      test_inst = SolvableChecker.new(@big_chain_board_two, print_level: 1)
      result = test_inst.navigate_activate_square!(3, 1, @big_chain_board_two)
      expect(result[:end_x]).to eq(4)
    end
    
    it "chains movements squares and then stop on a reverse square at the correct y coordinate" do
      test_inst = SolvableChecker.new(@big_chain_board_two, print_level: 1)
      result = test_inst.navigate_activate_square!(3, 1, @big_chain_board_two)
      expect(result[:end_y]).to eq(3)
    end
    
    it "chains movements squares and then stop on a reverse square at the correct x coordinate" do
      test_inst = SolvableChecker.new(@big_chain_board_two, print_level: 1)
      result = test_inst.navigate_activate_square!(1, 4, @big_chain_board_two)
      expect(result[:end_x]).to eq(4)
    end
    
    it "chains movements squares and then stop on a reverse square at the correct y coordinate" do
      test_inst = SolvableChecker.new(@big_chain_board_two, print_level: 1)
      result = test_inst.navigate_activate_square!(1, 4, @big_chain_board_two)
      expect(result[:end_y]).to eq(3)
    end

  end

  context "activating a poison square" do
    before do
      poison_array = [
        ["M","M","M","M","M","M"],
        ["M","D","L","L","L","M"],
        ["M","R","S","R","U","M"],
        ["M","R","R","U","M","M"],
        ["M","U","L","L","P","M"],
        ["M","M","M","M","M","M"]
      ]

      @big_chain_board = GameState.new(poison_array)
    end

    it "sets poison turns to 4 after activating a poison square" do
      test_inst = SolvableChecker.new(@big_chain_board, print_level: 1)
      result = test_inst.navigate_activate_square!(4, 4, @big_chain_board)
  
      puts result
      expect(result[:result]).to eq("POISONING")
      expect(result[:game_state].additional_state[:poison_turns_left]).to eq(4)
    end

    it "doesn't kill the player when being moved" do
      test_inst = SolvableChecker.new(@big_chain_board, print_level: 2)
      result = test_inst.navigate_move_player(4, 4, @big_chain_board)
  
      puts result.inspect
      puts test_inst.inspect

      expect(test_inst.fails).to eq(0)
      expect(test_inst.successes).to eq(1)
      expect(test_inst.times_hit_star).to eq(1)
    end

    it "kills the player after 3 turns" do
      poison_tele_array = [
        ["M","M","M","M","M","M"],
        ["M","D","R","R","D","M"],
        ["M","D","M","L","L","M"],
        ["M","S","M","M","M","M"],
        ["M","D","D","D","P","M"],
        ["M","M","M","M","M","M"]
      ]

      poison_tele_board = GameState.new(poison_tele_array)

      test_inst = SolvableChecker.new(poison_tele_board, print_level: 2)
      test_inst.navigate_move_player(4, 4, poison_tele_board)
  
      # puts result.inspect
      # puts test_inst.inspect

      expect(test_inst.successes).to eq(0)
      expect(test_inst.fails).to eq(1)
      expect(test_inst.times_hit_star).to eq(0)
    end

    it "kills the player in not less than 3 turns" do
      poison_tele_array = [
        ["M","M","M","M","M","M"],
        ["M","M","M","M","M","M"],
        ["M","M","M","M","M","M"],
        ["M","D","M","M","M","M"],
        ["M","S","D","D","P","M"],
        ["M","M","M","M","M","M"]
      ]

      poison_tele_board = GameState.new(poison_tele_array)

      test_inst = SolvableChecker.new(poison_tele_board, print_level: 2)
      test_inst.navigate_move_player(4, 4, poison_tele_board)

      expect(test_inst.successes).to eq(1)
      expect(test_inst.fails).to eq(0)
      expect(test_inst.times_hit_star).to eq(1)
    end

    it "kills the player in 3 turns with a teleport being used" do
      poison_tele_array = [
        ["M","M","M","M","M","M"],
        ["M","M","M","M","M","M"],
        ["M","S","M","L","L","M"],
        ["M","D","M","M","M","M"],
        ["M","D","T","T","P","M"],
        ["M","M","M","M","M","M"]
      ]

      poison_tele_board = GameState.new(poison_tele_array)

      test_inst = SolvableChecker.new(poison_tele_board, print_level: 2)
      test_inst.navigate_move_player(4, 4, poison_tele_board)

      expect(test_inst.successes).to eq(0)
      expect(test_inst.fails).to eq(1)
      expect(test_inst.times_hit_star).to eq(0)
    end

    it "doesn't kill the player in 4 turns with a teleport being used" do
      poison_tele_array = [
        ["M","M","M","M","M","M"],
        ["M","M","M","M","M","M"],
        ["M","D","M","M","M","M"],
        ["M","S","M","M","M","M"],
        ["M","D","T","T","P","M"],
        ["M","M","M","M","M","M"]
      ]

      poison_tele_board = GameState.new(poison_tele_array)

      test_inst = SolvableChecker.new(poison_tele_board, print_level: 2)
      test_inst.navigate_move_player(4, 4, poison_tele_board)

      expect(test_inst.successes).to eq(1)
      expect(test_inst.fails).to eq(0)
      expect(test_inst.times_hit_star).to eq(1)
    end
  end

end