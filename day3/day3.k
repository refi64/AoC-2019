/ wires:","\:'("R75,D30,R83,U83,L12,D49,R71,U7,L72";"U62,R66,U55,R34,D71,R55,D58,R83")
/ wires:","\:'("R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51"
/              "U98,R91,D20,R16,D67,R40,U7,R15,U6,R7")
/ wires:","\:'("R8,U5,L5,D3";"U7,R6,D4,L4")
wires:","\:'0:`input

moves:"UDLR"!(0,;0,-:;|0,-:;|0,)
/ tracestep[move] list of all steps the move consists of
tracestep:{1_+_(&/a%d)*!1+a:abs d:moves[*x]`i$1_x}

/ tracewire[wire] list of all steps the wire will take
tracewire:1_(,0 0){x,(last x)+/:tracestep y}/

/ shared[a;b] get shared elements between a and b
shared:{y@&~(#x)=x?y}

/ idist[wires] shortest distance from origin to closest intersection
idist:(&/+/'abs shared . tracewire')

/ {t@'+|(,!:'x),,!2}'(t)?\:/:abs shared . t:tracewire'wires
isteps:{&/+/'1+t?\:/:shared . t:tracewire'x}

part1:{idist wires}
part2:{isteps wires}

/ golfed:
/ part1:
/ &/+/'abs{y@&~(#x)=x?y}.(1_(,0 0){x,(*-1#x)+/:1_+_(&/a%d)*!1+a:abs d:("UDLR"!(0,;0,-:;|0,-:;|0,))[*y]`i$1_y}/)'","\:'0:`input
/ part2:
/ &/+/'1+t?\:/:{y@&~(#x)=x?y}. t:(1_(,0 0){x,(*-1#x)+/:1_+_(&/a%d)*!1+a:abs d:("UDLR"!(0,;0,-:;|0,-:;|0,))[*y]`i$1_y}/)'","\:'0:`input
