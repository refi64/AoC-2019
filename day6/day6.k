/ input:(!).+(|")"\:)'0:`input.test
input:(!).+(|")"\:)'0:`input

/ porb[input;planet] list of all planets that the given planet orbits
porb:{1_-1_x\y}

/ tnorb[input] total number of all counted orbits in input
tnorb:{+//#:'(porb x)'!x}

/ shared[a;b] get shared elements between a and b
shared:{y@&y in x}

/ ntr[input;a;b] # of transfers from planets a to b required
ntr:{+/o?\:*shared . o:(porb x)'(y;z)}

part1:{tnorb input}
part2:{ntr[input;"YOU";"SAN"]}

/ golfed:

/ part1:+//#:'(1_-1_i\)'!i:(!).+(|")"\:)'0:`input
/ part2:+/o?\:*(*o)@&(in). o:(1_-1_((!).+(|")"\:)'0:`input)\)'("SAN";"YOU")
