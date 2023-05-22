import std/sequtils
#Quiero crear estructuras tal que si le pregunto por su padre me dicen true o false
type
    Peso = object
        valor : int
#El grafo se representa con una matriz de adyacencia
#Yo soy mi propio padre o mi padre es el n-padre de mi padre
proc setParent(padres:var seq[seq[int]],son:int,o:int,config:seq[seq[int]])=
    let linea = config[son]
    for son_son in linea:
        if son_son != son:
            if not any(padres[son_son],proc(x:int):bool=x==o):
                setParent(padres,son_son,o,config)
    if not any(padres[son],proc(x:int):bool=x==o):    
        padres[son].add(o)
proc isParent(padres:seq[seq[int]],son:int,o:int):bool=
    any(padres[son],proc(x:int):bool=x==o)
proc play1()=
    let config = @[
        @[0],
        @[1,0],
        @[2,1,0],
        @[3,0],
        @[4,2]
    ]
    var pesos:seq[seq[Peso]]= newSeq[seq[Peso]](config.len)
    var padres:seq[seq[int]]=newSeq[seq[int]](config.len)
    let output= @[4,3]

    for i in countup(0,config.len-1,1):
        pesos[i]=newSeq[Peso](config.len)
        padres[i] = @[]
        for j in countup(0,config.len-1,1):
            pesos[i][j]=Peso(valor:0)
        for inp in countup(1,config[i].len-1,1):
            pesos[i][config[i][inp]]=Peso(valor:1)

    for o in output:
        let linea = config[o]
        for son in linea:
            if son != o:
                if not any(padres[son],proc(x:int):bool=x==o):
                    setParent(padres,son,o,config)
            else:
                padres[o].add(o)
    #[
    for fila in pesos:
        echo fila
    ]#
    var i=0
    for fila in padres:
        echo i
        echo fila
        i += 1
    
proc play2()=
    let config = @[
        @[0],
        @[1],
        @[2,0],
        @[3,1],
        @[4,3,2,1],
        @[5,2,0]
    ]
    var pesos:seq[seq[Peso]]= newSeq[seq[Peso]](config.len)
    var padres:seq[seq[int]]=newSeq[seq[int]](config.len)
    let output= @[4,5]

    for i in countup(0,config.len-1,1):
        pesos[i]=newSeq[Peso](config.len)
        padres[i] = @[]
        for j in countup(0,config.len-1,1):
            pesos[i][j]=Peso(valor:0)
        for inp in countup(1,config[i].len-1,1):
            pesos[i][config[i][inp]]=Peso(valor:1)

    for i in countdown(config.len-1,0,1):
        let linea = config[i]
        for son in linea:
            if not any(padres[son],proc(x:int):bool=x==linea[0]):
                setParent(padres,son,linea[0],config)



    #[
    for o in output:
        let linea = config[o]
        for son in linea:
            if son != o:
                if not any(padres[son],proc(x:int):bool=x==o):
                    setParent(padres,son,o,config)
            else:
                padres[o].add(o)
    ]#
    echo "pesos"
    for fila in pesos:
        echo fila
    
    echo "Padres"
    var i=0
    for fila in padres:
        echo i
        echo fila
        i += 1

    echo "test"
    echo isParent(padres,0,5)
    echo isParent(padres,1,4)
    echo isParent(padres,3,5)

play2()