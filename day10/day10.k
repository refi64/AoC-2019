input:"#"=0:`input.test2

/ astrs[map] find the coords of all asteroids on the map
astrs:{,/x{(&x@y),\:y}/:!#x}

/ rem[x;y] negative-friendly x mod y
rem:{x-y*_x%y}

/ sign[x] sign (+1 or -1) of x
sign:{(abs x)/x}

/ gcd[xa xb] greatest common divisor
gcd:*(last)({(y,rem[x;y])}.)/

/ nr[x] like !, but handles negative numbers by stepping down
/ e.g. 0 -1 -2~nr -3  / => 1
nr:{(a/x)*!a:abs x}

/ reduce[xa xb] reduce the fraction xa/xb to its simplest form
reduce:{x{y/x}\:1+*|&~(|/x{y\x}\:)'1+!abs &/x}

/ steps[xa xb;ya yb] return list of every point touched going from (xa,xb) to (ya,yb)
/ (including (ya,yb))
steps:{(x+(_d%g)*)'(sign g)+nr g:gcd d:y-x}

/ xrayview[astrs;astr] returns the other asteroids visible from various angles of the
/ given one, even if they're hidden behind others
/ returns a list of lists, each child list represents a direction and its elements
/ are the asteroids in that direction, all in order of closest to furthest
/ xrayview:{x{y@&y in x}/:y steps/:x^y}
xrayview:{x{y@&y in x}/:p@. last'=*:'p:asc y steps/:x^y}

/ eyeview[astrs;astr] returns the asteroid *directly* visible from the given one
eyeview:{?*:'xrayview[x;y]}

/ bestview[astrs] returns the asteroid with the most other asteroids in its direct
/ line of sight
bestview:{x@*>#:'x eyeview/:x}

part1:{#eyeview[a;bestview a:astrs input]}

/ atan[x] inverse tan(x)
/ (from https://ieeexplore.ieee.org/document/1628884)
atan:{(x*π%4)-(x*-1+a)*0.2447+0.0663*a:abs x}

/ atan2[x;y]
atan2:{p:π*-1 exp y<0;$[x;(p*x<0)+atan y%x;y;p%2;0f]}
/ prot[xa xb;r] rotate point (xa,xb) about the origin by r radians
prot:{(-/x*t;+/x*|t:(cos;sin)@\:y)}

/ protrel[xa xb;x0a x0b;r] rotate point (xa,xb) about (x0a,x0b) by r radians
protrel:{y+prot[x-y;z]}

/ convert a negative radians value to positive
radabs:{x+(2*π*x<0)}

/ ordview[astrs;astr] xrayview but ordered clockwise
ordview:{v@<y{radabs atan2 . protrel[*y;x;π%2]-x}/:v:xrayview[x;y]}

/ flatordview[astrs;astr] ordview but flatenned in order of destruction
flordview:{r@&*:'~Ø=r:,/v{x[;y]}/:!|/#:'v:ordview[x;y]}

/ {,/v{x[;y]}/:!|/#:'v:ordview[a;2]}
