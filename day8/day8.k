/ Implemented in Shakti K7.

/ format of input: (input data;width;height)
/ input:(`i$'"123456789012";3;2)
input:(`i$'*0:`input;25;6)

/ layers[input;width;height] separate the input image into layers of dimensions width x height
layers:{(-1;z)#(-1;y)#x}

/ fzd[layers] find layer with fewest zero digits
fzd:{x@*<+/'~x}

/ ckl[layer] find the layer's checksum (# of 1 digits * # of 2 digits)
ckl:(*/+//'1 2=\:)

/ shape[mat] shape of a 2d matrix as (rows;cols)
shape:{(#x),#*x}

/ dil[layers] decode the image represented by the given layers
dil:{(shape@*x)#{x@*&~2=x}'+,/'x}

part1:{ckl fzd layers . input}
part2:{dil layers . input}
