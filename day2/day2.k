/ Implemented in Shakti K7.

data:`i$","\:*0:`input  / read code from input
data[1 2]:45 59  / magic #s for part 2

/ halts the program
/ halt:{` 0:,","/:$data;."\\\\"}  / this version prints all the data on halt
halt:{` 0:,$*data;."\\\\"}

cmds:1 2 99!(+;*;halt)
/ exec[] executes the commands in data
exec:{{data[a 3]:cmds[*a]/data@1_3#a:4#x_data}'4*!1+_(#data)%4}

exec[]
