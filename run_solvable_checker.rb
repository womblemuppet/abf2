require_relative 'solvable_checker/solvable_checker'
require 'pry'

solvable_board_array_1 = [
  ["L","R","L","T"],
  ["R","D","D","P"],
  ["R","L","X","L"],
  ["D","T","U","D"],
  ["M","M","A","M"]
]

@solvable_board_1 = GameState.new(solvable_board_array_1)

test_inst = SolvableChecker.new(@solvable_board_1, print_level: 2)
test_inst.initiate()

# ["R", "D", "L", "D", "U", "L", "L", "U", "U", "L", "U", "R", "R", "D", "L"]
# ["R", "D", "L", "D", "U", "L", "L", "U", "U", "L", "U", "R", "D", "R", "U"]