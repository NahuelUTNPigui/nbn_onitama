import std/sequtils
import std/hashes
import random
randomize()
type

    #Son 3 matrices 3x3, la primero refleja la posicion de los cositos de 1, la segunda los cositos de 2 y el tercero los lugares impasables
    Tablero* = object
        player_one : seq[seq[int]]
        player_two : seq[seq[int]]
        impasable : seq[seq[int]]
    # El vector representa todos los movimientos posibles 
    # Es un ref object
    Move* = ref object
        mv* : seq[float]
    #[
        A cada celda se le asigna un numero del 0 al 8
        Mas facil pero los x,x nunca pasan
        Hay 9x9 = 81 elemento en la lista 
        idx_lista: (idx div 9 ,idx mod 9)
        idx div 9 , idx mod 9

    ]#
    Juego* = object
        tablero*:Tablero
        player_actual*:int

proc hash*(x: Move): Hash =
  ## Computes a Hash from `x`.
  var h: Hash = 0
  h = h !& hash(maxIndex(x.mv)*3343 + 7517)
  result = !$h  
proc to_vec*(tabl:Tablero):seq[float]=
    var vec=newSeq[float](27)
    var idx=0
    for i in countup(0,2,1):
        for j in countup(0,2,1):
            vec[idx]=tabl.player_one[i][j].toFloat
            idx += 1
    for i in countup(0,2,1):
        for j in countup(0,2,1):
            vec[idx]=tabl.player_two[i][j].toFloat
            idx += 1
    for i in countup(0,2,1):
        for j in countup(0,2,1):
            vec[idx]=tabl.impasable[i][j].toFloat
            idx += 1
    vec
proc to_vec_player*(tabl:Tablero,player:int):seq[float]=
    var vec=newSeq[float](27)
    var idx=0
    for i in countup(0,2,1):
        for j in countup(0,2,1):
            vec[idx]=tabl.player_one[i][j].toFloat
            idx += 1
    for i in countup(0,2,1):
        for j in countup(0,2,1):
            vec[idx]=tabl.player_two[i][j].toFloat
            idx += 1
    for i in countup(0,2,1):
        for j in countup(0,2,1):
            vec[idx]=if player==1: 1.0 else: 0.0
            idx += 1
    vec   
proc `$`*(juego:Juego):string=
    var res=" p: " & $juego.player_actual & "\n|"
    
    let p=juego.player_actual
    let t_1 = juego.tablero.player_one
    let t_2 = juego.tablero.player_two
    for i in countup(0,2,1):
        for j in countup(0,2,1):
            let c=if p==1: t_1[i][j] - t_2[i][j] else: t_2[i][j] - t_1[i][j]
            
            res &= (if c >= 0: " " & $c else: $c)
            res &= "|"
        res &= "\n|"
    res

proc newTablero*():Tablero=
    var p_1 = @[
        @[1,0,0],
        @[0,0,1],
        @[1,0,0],
    ]
    var p_2 = @[
        @[0,0,1],
        @[1,0,0],
        @[0,0,1],
    ]
    var imp = @[
        @[0,1,0],
        @[0,0,0],
        @[0,1,0],
    ]
    Tablero(player_one:p_1,player_two:p_2,impasable:imp)
proc newJuego*():Juego=
    var tab=newTablero()
    Juego(tablero:tab,player_actual:1)
proc ciertoJuego(p_1:seq[seq[int]],p_2:seq[seq[int]],p:int):Juego =
    
    var imp = @[
        @[0,1,0],
        @[0,0,0],
        @[0,1,0],
    ]
    let t=Tablero(player_one:p_1,player_two:p_2,impasable:imp)
    Juego(tablero:t,player_actual:p)
    
proc copyJuego*(juego:Juego):Juego=
    let p=juego.player_actual
    var p_1 = @[
        @[1,0,0],
        @[0,0,1],
        @[1,0,0],
    ]
    var p_2 = @[
        @[0,0,1],
        @[1,0,0],
        @[0,0,1],
    ]
    var imp = @[
        @[0,1,0],
        @[0,0,0],
        @[0,1,0],
    ]
    for i in countup(0,2,1):
        for j in countup(0,2,1):
            p_1[i][j] = juego.tablero.player_one[i][j]
            p_2[i][j] = juego.tablero.player_two[i][j]
    let t=Tablero(player_one:p_1,player_two:p_2,impasable:imp)
    Juego(tablero:t,player_actual:p)
proc copyTablero*(tablero:Tablero):Tablero=
    var p_1 = @[
        @[1,0,0],
        @[0,0,1],
        @[1,0,0],
    ]
    var p_2 = @[
        @[0,0,1],
        @[1,0,0],
        @[0,0,1],
    ]
    var imp = @[
        @[0,1,0],
        @[0,0,0],
        @[0,1,0],
    ]
    for i in countup(0,2,1):
        for j in countup(0,2,1):
            p_1[i][j] = tablero.player_one[i][j]
            p_2[i][j] = tablero.player_two[i][j]
    Tablero(player_one:p_1,player_two:p_2,impasable:imp)
proc idx_2_move(idx_init,idx_fin:int):Move=
    var move=newSeq[float](81)
    let idx = idx_init * 9 + idx_fin
    move[idx]=1.0
    Move(mv:move)

proc estaVacio(i,j:int, tab:Tablero):bool=
    tab.player_one[i][j]==0 and tab.player_two[i][j]==0 and tab.impasable[i][j]==0
#Calcular todos los movimientos posibles
proc moves*(player:int,tab:Tablero):seq[Move]=
    var pegs_find=0
    var mvs=newSeq[Move]()
    
    for i in countup(0,2,1):
        for j in countup(0,2,1):
            if (player==1 and tab.player_one[i][j]==1) or (player==2 and tab.player_two[i][j]==1):
                pegs_find += 1
                for ii in countup(-1,1,1):
                    for jj in countup(-1,1,1):
                        if i+ii<=2 and i+ii>=0 and j+jj<=2 and j+jj>=0 and estaVacio(i+ii,j+jj,tab) :
                            mvs.add(idx_2_move(i*3+j,(i+ii)*3+(j+jj)))
                if ((i*3 + j) == 6) and estaVacio(2,2,tab):
                    mvs.add(idx_2_move(6,8))
                if  ((i*3 + j) == 8) and estaVacio(2,0,tab):
                    mvs.add(idx_2_move(8,6))
    mvs
proc applymove*(player:int,tab:var Tablero,mv:Move)=
    let idx=maxIndex(mv.mv)
    let idx_init=idx div 9
    let idx_fin = idx mod 9
    let init_x=idx_init div 3
    let init_y = idx_init mod 3
    let fin_x=idx_fin div 3
    let fin_y = idx_fin mod 3
    if player==1:
        tab.player_one[init_x][init_y]=0
        tab.player_one[fin_x][fin_y]=1
    else:
        tab.player_two[init_x][init_y]=0
        tab.player_two[fin_x][fin_y]=1
proc getTablero*(player:int,tablero:Tablero,mv:Move):Tablero=
    var tab = copyTablero(tablero)
    let idx=maxIndex(mv.mv)
    let idx_init=idx div 9
    let idx_fin = idx mod 9
    let init_x=idx_init div 3
    let init_y = idx_init mod 3
    let fin_x=idx_fin div 3
    let fin_y = idx_fin mod 3
    if player==1:
        tab.player_one[init_x][init_y]=0
        tab.player_one[fin_x][fin_y]=1
    else:
        tab.player_two[init_x][init_y]=0
        tab.player_two[fin_x][fin_y]=1
    tab
#Devuelve si esta terminado y quien perdio
#Siempre el jugador 1 maximiza y el 2 minimiza
proc endGame*(tab:Tablero,jugador:int):(bool,int)=
    let mvs_1 = moves(1,tab)
    let mvs_2 = moves(2,tab)
    if mvs_1.len==0:
        return (true, -1 * (if jugador==2: -1 else: 1))
    elif mvs_2.len==0:
        return (true, 1 * (if jugador==2: -1 else: 1))
    else:
        return (false,0)    
proc play()=
    var juego = newJuego()
    #let mvs= moves(juego.player_actual,juego.tablero)
    #let max_idx=mvs.map(proc(m:Move):int= maxIndex(m.mv))
    #echo max_idx
    for _ in countup(0,10,1):
        echo juego
        let mvs= moves(juego.player_actual,juego.tablero)
        let m=mvs[rand(mvs.len-1)]
        applymove(juego.player_actual,juego.tablero,m)
        if juego.player_actual==1:
            juego.player_actual=2
        else:
            juego.player_actual=1

proc play2()=
    var p_1 = @[
        @[0,0,0],
        @[1,0,1],
        @[0,0,1],
    ]
    var p_2 = @[
        @[1,0,1],
        @[0,1,0],
        @[0,0,0],
    
    ]   
    let j = ciertoJuego(p_1,p_2,1)
    #let j = newJuego()
    let mvs=moves(1,j.tablero)
    let idx_mvs=mvs.map(proc(m:Move):int=maxIndex(m.mv))
    echo idx_mvs
#play2()