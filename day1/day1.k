/ Implemented in Shakti K7.

modules:`i$0:`input  / read modules from input

fuel:{0|-2+_x%3}  / get fuel for module mass (minimum fuel is 0)

part1:sum fuel modules
part2:sum/1_fuel\modules  / fuel for each mass until 0, then drop the initial value and sum

` 0:,"part 1: ",$part1;
` 0:,"part 2: ",$part2;
\\
