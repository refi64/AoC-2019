input:`i$"-"\:*0:`input

/ irange[x;y] inclusive range [x,y]
irange:{x+!1+y-x}
/ valids[d] is d a valid password according to the part 1 rules (older version)
valids:(*|{x&~y}':|/'+(0>;0=).\:/:-':10\:)

/ sorted[x] is x sorted
sorted:{x~^x}

/ runof2[x] does x have a run of at least 2 digits
runof2:(|/1<#:'.=:)
/ or: runof2:(|/1<. freq)
/ valid[x] is d a valid password according to the part 1 rules (newer version)
valid:(&/(sorted;runof2)@\:10\:)

/ runof2x[x] does x have a run of *exactly* 2 digits
runof2x:(2 in#:'.=:)
/ or: runof2x:(2 in . freq)
/ valid[x] is d a validx password according to the part 2 rules
validx:(&/(sorted;runof2x)@\:10\:)

/ slower, older part 1
part1s:{#&valids'irange . input}
/ faster part 1
part1f:{#&valid'irange . input}
/ part 2
part2:{#&validx'irange . input}

/ golfed:
/ part1s: #&(*|{x&~y}':|/'+(0>;0=).\:/:-':10\:)'{x+!1+y-x}.`i$"-"\:*0:`input
/ part1f: #&(&/({x~^x};(|/1<#:'.=:))@\:10\:)'{x+!1+y-x}.`i$"-"\:*0:`input
/ part2: #&(&/({x~^x};(2 in#:'.=:))@\:10\:)'{x+!1+y-x}.`i$"-"\:*0:`input
