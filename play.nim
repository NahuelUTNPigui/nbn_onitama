import neo
var v = makeMatrix(2,1,proc(i,j:int):float=1.0)
echo v*v.t
echo v * 2.0 