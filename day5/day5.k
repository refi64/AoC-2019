/ Implemented in Shakti K7.
/ UNFINISHED

data:`i$","\:*0:`input  / read code from input

/ ioffs[data] find all instruction first offsets
ioffs:{1_({y,(~i=99)#,n+!2+2*3>*|10\:i:x@n:1+*|*|y}x)/,-1}

/ {*|10\:*x}'data'ioffs data

/ {2 -1#a,(-#a:1_x)#(4#0),-1_o:10\:*i:data@x}'ioffs data
/ {(,(-#a)#(4#0),-1_o:10\:*i),,a:1_i:data@x}'ioffs data
/ {(**(data@;).,:')'+(,(-#a)#(4#0),-1_o:10\:*i),,a:1_i:data@x}'ioffs data

/ {2 div -1+*d:|10\:*data@x}'ioffs data
/ {if[~3=*d:|(4#0),10\:*i:data@x;i:@[i;1+&|2_(#x)#d;data@]];i}'ioffs data

/ ***
/ cmds:({data[z]:x+y})
/ {if[~3=*d:|(4#0),10\:*i:data@x;i:@[i;1+&~|(1+3>*d)#2_d;data@]];i}'ioffs data
/ {@[i;(2*3=*d)_1+&~(1+3>*d)#2_d:|(4#0),10\:*i:data@x;data@]}'ioffs data
/ {[x]v:((+;*;{`i$1:`};(` 0:$,))@c-1).(-1*c<3)_i:@[1_i;(2*3=c)_&~(1+3>c:*d)#2_d:|(4#0),10\:*i:data@x;data@];if[~c=3;data[*|i]:v];0}'ioffs data

/ process:{[x]v:((+;*;{`i$1:`};{` 0:$,x})@c-1).(-1*c<3)_@[1_i;(2*3=c)_&~(1+3>c:*o)#2_o:|(4#0),10\:*i:data@x;data@];if[~c=4;data[*|i]:v]}'ioffs data;

/ {[x]v:((+;*;{`i$1:`};{` 0:$,x})@c-1).(-1*c<3)_1_@[i;(0<#m)+m:(2*3=c)_&~(1+3>c:*o)#2_o:|(4#0),10\:*i:data@x;data@];if[~c=4;data[*|i]:v]}'ioffs data;

/ golfed {[x]v:((+;*;{`i$1:`};{` 0:$,x})@c-1).(-1*c<3)_i:@[1_i;(2*3=c)_&~(1+3>c:*o)#2_o:|(4#0),10\:*i:d@x;d@];if[~c=4;d[*|i]:v]}';
