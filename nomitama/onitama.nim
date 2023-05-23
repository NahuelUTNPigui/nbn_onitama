import std/sequtils
import std/hashes
import random
import parseutils
randomize()
const
  eps = 1.0e-7 ## Epsilon used for float comparisons.

proc `=~` *(x, y: float): bool =
  result = abs(x - y) < eps
type
    Mazo = object
        #Una lista de las cartas posibles del onitmaa
        cartas:seq[seq[seq[float]]]
    Tablero = object
        #El primer numero es el jugador el segundo la carta
        carta_1_1 : seq[seq[float]]
        carta_1_2 : seq[seq[float]]
        carta_2_1 : seq[seq[float]]
        carta_2_2 : seq[seq[float]]
        #La carta que debe ser intercambiada
        carta_idle:seq[seq[float]]
        #Peones del jugardor 1
        white_pawns : seq[seq[float]]
        #Peones del jugador 2
        black_pawns : seq[seq[float]]
        #Rey del jugador 1
        white_king : seq[seq[float]]
        #Rey del jugador 2
        black_king : seq[seq[float]]
        
    Move* = ref object
        #Es una lista de 25*25*2, los primeros 25*25 son de la primera carta, y los demas de la segunda carta
        #0 a 624 primera carta, 625 a 1249 segunda carta
        mv*: seq[float]
    Juego* = ref object
        # Uno empieza arriba
        # Dos empieza abajo
        player_actual* : int
        tablero* : Tablero


proc doubleInversCardShow(card1:seq[seq[float]],card2:seq[seq[float]]):string=
    var s = ""
    for i in countdown(4,0,1):
        
        for j in countdown(4,0,1):
            s &= "| "
            
            if card1[i][j] =~ 1.0:
                s &= "o "
            else:
                if i==2 and j == 2:
                    s &= "x "
                else:
                    s &= "_ "
        s &= "|"
        s &= "\t"
        for j in countdown(4,0,1):
            s &= "| "
            
            if card2[i][j] =~ 1.0:
                s &= "o "
            else:
                if i==2 and j == 2:
                    s &= "x "
                else:
                    s &= "_ "
        s &= "|"
        s &= "\n"
    s
proc doubleCardShow(card1:seq[seq[float]],card2:seq[seq[float]]):string=
    var s = ""
    for i in countup(0,4,1):
        
        for j in countup(0,4,1):
            s &= "| "
            
            if card1[i][j] =~ 1.0:
                s &= "o "
            else:
                if i==2 and j == 2:
                    s &= "x "
                else:
                    s &= "_ "
        s &= "|"
        s &= "\t"
        for j in countup(0,4,1):
            s &= "| "
            
            if card2[i][j] =~ 1.0:
                s &= "o "
            else:
                if i==2 and j == 2:
                    s &= "x "
                else:
                    s &= "_ "
        s &= "|"
        s &= "\n"
    s
proc horizontalCardShow(card:seq[seq[float]]):string=
    var s = ""
    for i in countup(0,4,1):
        
        for j in countup(0,4,1):
            s &= "| "
            
            if card[i][j] =~ 1.0:
                s &= "x "
            else:
                if i==2 and j == 2:
                    s &= "p "
                else:
                    s &= "o "
    s
proc idxGirado(i,j:int):(int,int)=
    (0,0)
proc `$`*(juego:Juego):string=
    var s = ""
    if juego.player_actual == 1:
        s &= "Carta 1: \t        Carta 2:"
        s &= "\n"
        s &= doubleInversCardShow(juego.tablero.carta_1_1,juego.tablero.carta_1_2)
        s &= "\n"
        s &= "\tTablero:             \tCarta 3\n"
        for i in countup(0,4,1):
            s &= "\t"
            for j in countup(0,4,1):
                s &= "|"
                if juego.tablero.white_pawns[i][j] =~ 1.0:
                    s &= " p "
                elif juego.tablero.white_king[i][j] =~ 1.0:
                    s &= " R "
                elif juego.tablero.black_pawns[i][j] =~ 1.0:
                    s &= "-p "
                elif juego.tablero.black_king[i][j] =~ 1.0:
                    s &= "-R "
                else:
                    s &= " _ "
            s &= "|"
            s &= "\t"
            for j in countdown(4,0,1):
                s &= "|"
                if juego.tablero.carta_idle[4-i][j] =~ 1.0:
                    s &= "o "
                else:
                    if i==2 and j == 2:
                        s &= "x "
                    else:
                        s &= "_ "
            s &= "|"
            s &= "\n"
        s &= "\n"
        s &= "Carta 4: \t        Carta 5:"
        s &= "\n"  
        s &= doubleCardShow(juego.tablero.carta_2_1,juego.tablero.carta_2_2)
    else:     
        s &= "Carta 1: \t          \tCarta 2:"
        s &= "\n"               
        s &= doubleInversCardShow(juego.tablero.carta_1_1,juego.tablero.carta_1_2)
        s &= "\n"
        s &= "\tTablero:             \tCarta 3\n"
        for i in countup(0,4,1):
            s &= "\t"
            for j in countup(0,4,1):
                s &= "|"
                if juego.tablero.black_pawns[i][j] =~ 1.0:
                    s &= " p "
                elif juego.tablero.black_king[i][j] =~ 1.0:
                    s &= " R "
                elif juego.tablero.white_pawns[i][j] =~ 1.0:
                    s &= "-p "
                elif juego.tablero.white_king[i][j] =~ 1.0:
                    s &= "-R "
                else:
                    s &= " _ "
            s &= "|"
            s &= "\t"
            for j in countup(0,4,1):
                s &= "|"
                if juego.tablero.carta_idle[i][j] =~ 1.0:
                    s &= "o "
                else:
                    if i==2 and j == 2:
                        s &= "x "
                    else:
                        s &= "_ "
            s &= "|"
            s &= "\n"
        s &= "\n"
        s &= "Carta 4: \t        Carta 5:"
        s &= "\n"
        s &= doubleCardShow(juego.tablero.carta_2_1,juego.tablero.carta_2_2)
    return s

proc `$`*(m:Move):string=
    let idx=maxIndex(m.mv) 
    let carta = idx div 625
    let pos = idx mod 625
    let idx_fin = pos div 25 
    let idx_init = pos mod 25
    let idx_init_x = idx_init mod 5
    let idx_init_y = idx_init div 5
    let idx_fin_x = idx_fin mod 5
    let idx_fin_y = idx_fin div 5    
    "(carta: " & $carta & " , init: " & $idx_init & " , fin: " & $idx_fin & ")"
proc show*(m:Move,p:int):string=
    let idx=maxIndex(m.mv) 
    var carta = idx div 625
    if p==1:
        carta += 1
    else:
        carta += 4
    let pos = idx mod 625
    let idx_fin = pos div 25 
    let idx_init = pos mod 25
    let idx_init_x = idx_init mod 5
    let idx_init_y = idx_init div 5
    let idx_fin_x = idx_fin mod 5
    let idx_fin_y = idx_fin div 5    
    #Esta al reves lo se pero es lo que hay oh
    "{carta: " & $carta & " , desde : (x:" & $idx_init_y & " , y: " & $idx_init_x & ") , hasta: (x: " & $idx_fin_y & " , y:" & $idx_fin_x & ") }"
proc newMazo():Mazo=
    var cards:seq[seq[seq[float]]]= @[]
    #tieger
    let c1 = @[
            @[0.0,0,1,0,0],
            @[0.0,0,0,0,0],
            @[0.0,0,0,0,0],
            @[0.0,0,1,0,0],
            @[0.0,0,0,0,0],
    ]
    cards.add(c1)
    #dragon
    let c2 = @[
            @[0.0,0,0,0,0],
            @[1.0,0,0,0,1],
            @[0.0,0,0,0,0],
            @[0.0,1,0,1,0],
            @[0.0,0,0,0,0],
    ]
    cards.add(c2)
    #frog
    let c3 = @[
            @[0.0,0,0,0,0],
            @[0.0,1,0,0,0],
            @[1.0,0,0,0,0],
            @[0.0,0,0,1,0],
            @[0.0,0,0,0,0],
    ]
    cards.add(c3)
    #rabbit
    let c4 = @[
            @[0.0,0,0,0,0],
            @[0.0,0,0,1,0],
            @[0.0,0,0,0,1],
            @[0.0,1,0,0,0],
            @[0.0,0,0,0,0],
    ]
    cards.add(c4)
    #crab
    let c5 = @[
            @[0.0,0,0,0,0],
            @[0.0,0,1,0,0],
            @[1.0,0,0,0,1],
            @[0.0,0,0,0,0],
            @[0.0,0,0,0,0],
    ]
    cards.add(c5)
    #elephanr
    let c6 = @[
            @[0.0,0,0,0,0],
            @[0.0,1,0,1,0],
            @[0.0,1,0,1,0],
            @[0.0,0,0,0,0],
            @[0.0,0,0,0,0],
    ]
    cards.add(c6)
    #goose
    let c7 = @[
            @[0.0,0,0,0,0],
            @[0.0,1,0,0,0],
            @[0.0,1,0,0,0],
            @[0.0,0,0,1,0],
            @[0.0,0,0,1,0],
    ]
    cards.add(c7)
    #roster
    let c8 = @[
            @[0.0,0,0,0,0],
            @[0.0,0,0,1,0],
            @[0.0,0,0,1,0],
            @[0.0,1,0,0,0],
            @[0.0,1,0,0,0],
    ]
    cards.add(c8)
    #monkey
    let c9 = @[
            @[0.0,0,0,0,0],
            @[0.0,1,0,1,0],
            @[0.0,0,0,0,0],
            @[0.0,1,0,1,0],
            @[0.0,0,0,0,0],
    ]
    cards.add(c9)
    #mantis
    let c10 = @[
            @[0.0,0,0,0,0],
            @[0.0,1,0,1,0],
            @[0.0,0,0,0,0],
            @[0.0,0,1,0,0],
            @[0.0,0,0,0,0],
    ]
    cards.add(c10)
    #horse
    let c11 = @[
            @[0.0,0,0,0,0],
            @[0.0,0,1,0,0],
            @[0.0,1,0,0,0],
            @[0.0,0,1,0,0],
            @[0.0,0,0,0,0],
    ]
    cards.add(c11)
    #ox
    let c12 = @[
            @[0.0,0,0,0,0],
            @[0.0,0,1,0,0],
            @[0.0,0,0,1,0],
            @[0.0,0,1,0,0],
            @[0.0,0,0,0,0],
    ]
    cards.add(c12)
    #crane
    let c13 = @[
            @[0.0,0,0,0,0],
            @[0.0,0,1,0,0],
            @[0.0,0,0,0,0],
            @[0.0,1,0,1,0],
            @[0.0,0,0,0,0],
    ]
    cards.add(c13)
    #boar
    let c14 = @[
            @[0.0,0,0,0,0],
            @[0.0,0,1,0,0],
            @[0.0,1,0,1,0],
            @[0.0,0,0,0,0],
            @[0.0,0,0,0,0],
    ]
    cards.add(c14)
    #eel
    let c15 = @[
            @[0.0,0,0,0,0],
            @[0.0,1,0,0,0],
            @[0.0,0,0,1,0],
            @[0.0,1,0,0,0],
            @[0.0,0,0,0,0],
    ]
    cards.add(c15)
    #cobra
    let c16 = @[
            @[0.0,0,0,0,0],
            @[0.0,0,0,1,0],
            @[0.0,1,0,0,0],
            @[0.0,0,0,1,0],
            @[0.0,0,0,0,0],
    ]
    cards.add(c16)
    Mazo(cartas:cards)

proc newTablero():Tablero=
    let mazo=newMazo()
    var wp = @[
        @[1.0,1,0,1,1],
        @[0.0,0,0,0,0],
        @[0.0,0,0,0,0],
        @[0.0,0,0,0,0],
        @[0.0,0,0,0,0],
    ]
    var wk = @[
        @[0.0,0,1,0,0],
        @[0.0,0,0,0,0],
        @[0.0,0,0,0,0],
        @[0.0,0,0,0,0],
        @[0.0,0,0,0,0],
    ]
    var bp = @[
        @[0.0,0,0,0,0],
        @[0.0,0,0,0,0],
        @[0.0,0,0,0,0],
        @[0.0,0,0,0,0],
        @[1.0,1,0,1,1],
    ]
    var bk = @[
        @[0.0,0,0,0,0],
        @[0.0,0,0,0,0],
        @[0.0,0,0,0,0],
        @[0.0,0,0,0,0],
        @[0.0,0,1,0,0],
    ]
    let c_1_idx:int=rand(mazo.cartas.len-1)
    var c_2_idx =rand(mazo.cartas.len-1)
    while c_2_idx == c_1_idx:
        c_2_idx =rand(mazo.cartas.len-1)
    var c_3_idx =rand(mazo.cartas.len-1)
    while c_3_idx == c_1_idx or c_3_idx == c_2_idx:
        c_3_idx =rand(mazo.cartas.len-1)
    var c_4_idx =rand(mazo.cartas.len-1)
    while c_4_idx == c_1_idx or c_4_idx == c_2_idx or c_4_idx == c_3_idx:
        c_4_idx =rand(mazo.cartas.len-1)
    var c_5_idx =rand(mazo.cartas.len-1)
    while c_5_idx == c_1_idx or c_5_idx == c_2_idx or c_5_idx == c_3_idx or c_5_idx == c_4_idx:
        c_5_idx =rand(mazo.cartas.len-1)
    
    Tablero(
        carta_1_1:mazo.cartas[c_1_idx],
        carta_1_2:mazo.cartas[c_2_idx],
        carta_2_1:mazo.cartas[c_3_idx],
        carta_2_2:mazo.cartas[c_4_idx],
        carta_idle:mazo.cartas[c_5_idx],
        white_pawns:wp,
        white_king:wk,
        black_pawns:bp,
        black_king:bk
    )

proc newJuego*():Juego=
    var tablero = newTablero()
    Juego(tablero:tablero,player_actual:1)

proc newMove(carta,i_init,j_init,i_fin,j_fin:int):Move=   
    var mv:seq[float] = newSeq[float](1250)
    let idx=i_init + 5 * j_init + 25 * i_fin + 125 * j_fin + 625 * carta 
    mv[idx] = 1.0
    Move(mv:mv)


proc encontrarPeones(peones:seq[seq[float]]):seq[(int,int)]=
    var peones_idx:seq[(int,int)] = @[]
    for i in countup(0,4,1):
        for j in countup(0,4,1):
            if peones[i][j] == 1:
                peones_idx.add((i,j))
    peones_idx

proc estaVacio(i,j:int,peones_idx:seq[(int,int)],rey:(int,int)):bool=
    for p_idx in peones_idx:
        if p_idx[0] == i and p_idx[1] == j:
            return false
    if rey[0] == i and rey[1] == j:
        return false
    return true

proc encontrarRey(rey:seq[seq[float]]):(int,int)=
    for i in countup(0,4,1):
        for j in countup(0,4,1):
            if rey[i][j] == 1:
                return (i,j)
proc dentroCancha(i,j:int):bool=
    i <= 4 and i >= 0 and j <= 4 and j >= 0

proc vectorMove(i,j:int):(int,int)=
    (i-2,j-2)
proc negVectorMove(vec:(int,int)):(int,int)=
    (-vec[0],-vec[1])

# Mucha repeticion de codigo
proc moves*(tablero:Tablero,player:int):seq[Move]=
    var mvs:seq[Move] = @[]
    # Estan invertidas las cartas
    if player == 1:
        let p_idxs = encontrarPeones(tablero.white_pawns)
        let rey_idx = encontrarRey(tablero.white_king)
        for i in countup(0,4,1):
            for j in countup(0,4,1):
                if tablero.carta_1_1[i][j] == 1:
                    var vn=vectorMove(i,j)
                    vn=negVectorMove(vn)
                    for p_idx in p_idxs:
                        if dentroCancha(p_idx[0]+vn[0],p_idx[1]+vn[1]) and estaVacio(p_idx[0]+vn[0],p_idx[1]+vn[1],p_idxs,rey_idx):
                            mvs.add(newMove(0,p_idx[0],p_idx[1],p_idx[0]+vn[0],p_idx[1]+vn[1]))
                    if dentroCancha(rey_idx[0]+vn[0],rey_idx[1]+vn[1]) and estaVacio(rey_idx[0]+vn[0],rey_idx[1]+vn[1],p_idxs,rey_idx):
                        mvs.add(newMove(0,rey_idx[0],rey_idx[1],rey_idx[0]+vn[0],rey_idx[1]+vn[1]))
                    
                if tablero.carta_1_2[i][j] == 1:
                    let vn=vectorMove(i,j)
                    for p_idx in p_idxs:
                        if dentroCancha(p_idx[0]+vn[0],p_idx[1]+vn[1]) and estaVacio(p_idx[0]+vn[0],p_idx[1]+vn[1],p_idxs,rey_idx):
                            mvs.add(newMove(1,p_idx[0],p_idx[1],p_idx[0]+vn[0],p_idx[1]+vn[1]))
                    if dentroCancha(rey_idx[0]+vn[0],rey_idx[1]+vn[1]) and estaVacio(rey_idx[0]+vn[0],rey_idx[1]+vn[1],p_idxs,rey_idx):
                        mvs.add(newMove(1,rey_idx[0],rey_idx[1],rey_idx[0]+vn[0],rey_idx[1]+vn[1]))
    else:
        let p_idxs = encontrarPeones(tablero.black_pawns)
        let rey_idx = encontrarRey(tablero.black_king)
        for i in countup(0,4,1):
            for j in countup(0,4,1):
                if tablero.carta_2_1[i][j] == 1:
                    let vn=vectorMove(i,j)
                    for p_idx in p_idxs:
                        if dentroCancha(p_idx[0]+vn[0],p_idx[1]+vn[1]) and estaVacio(p_idx[0]+vn[0],p_idx[1]+vn[1],p_idxs,rey_idx):
                            mvs.add(newMove(0,p_idx[0],p_idx[1],p_idx[0]+vn[0],p_idx[1]+vn[1]))
                    if dentroCancha(rey_idx[0]+vn[0],rey_idx[1]+vn[1]) and estaVacio(rey_idx[0]+vn[0],rey_idx[1]+vn[1],p_idxs,rey_idx):
                        mvs.add(newMove(0,rey_idx[0],rey_idx[1],rey_idx[0]+vn[0],rey_idx[1]+vn[1]))
                if tablero.carta_2_2[i][j] == 1:
                    let vn=vectorMove(i,j)
                    for p_idx in p_idxs:
                        if dentroCancha(p_idx[0]+vn[0],p_idx[1]+vn[1]) and estaVacio(p_idx[0]+vn[0],p_idx[1]+vn[1],p_idxs,rey_idx):
                            mvs.add(newMove(1,p_idx[0],p_idx[1],p_idx[0]+vn[0],p_idx[1]+vn[1]))
                    if dentroCancha(rey_idx[0]+vn[0],rey_idx[1]+vn[1]) and estaVacio(rey_idx[0]+vn[0],rey_idx[1]+vn[1],p_idxs,rey_idx):
                        mvs.add(newMove(1,rey_idx[0],rey_idx[1],rey_idx[0]+vn[0],rey_idx[1]+vn[1]))
    mvs


proc hasZero(mtx:seq[seq[float]]):bool=
    for i in countup(0,4,1):
        for j in countup(0,4,1):
            if mtx[i][j] =~ 1.0:
                return false
    return true
proc endGame*(tablero:Tablero,player:int):(bool,int)=
    let wk_death=hasZero(tablero.white_king)
    if wk_death:
        return (true, if player==1 : -1 else: 1)
    let bk_death=hasZero(tablero.black_king)
    if bk_death:
        return (true, if player==1 : 1 else: -1)
    if tablero.black_king[0][2] =~ 1.0:
        return (true, if player==1 : -1 else: 1)
    if tablero.white_king[4][2] =~ 1.0:
        return (true, if player==1 : 1 else: -1)
    return (false,1)

proc copyCard(carta:seq[seq[float]]):seq[seq[float]]=
    var copia = @[
            @[0.0,0,0,0,0],
            @[0.0,0,0,0,0],
            @[0.0,0,0,0,0],
            @[0.0,0,0,0,0],
            @[0.0,0,0,0,0],        
    ]
    for i in countup(0,4,1):
        for j in countup(0,4,1):
            if carta[i][j] =~ 1.0:
                copia[i][j]=1.0
    return copia
proc getTablero(player:int,tab: var Tablero, mv:Move):Tablero=
    Tablero()
proc copyJuego*(j:Juego):Juego=
    let carta_1_1 = copyCard(j.tablero.carta_1_1)
    let carta_1_2 = copyCard(j.tablero.carta_1_2)
    let carta_2_1 = copyCard(j.tablero.carta_2_1)
    let carta_2_2 = copyCard(j.tablero.carta_2_2)
    let carta_idle = copyCard(j.tablero.carta_idle)
    let wp = copyCard(j.tablero.white_pawns)
    var wk = copyCard(j.tablero.white_king)
    var bp = copyCard(j.tablero.black_pawns)
    var bk = copyCard(j.tablero.black_king)
    let t = Tablero(
        carta_1_1 : carta_1_1,
        carta_1_2 : carta_1_2,
        carta_2_1 : carta_2_1,
        carta_2_2 : carta_2_2,
        carta_idle : carta_idle,
        white_pawns:wp,
        white_king:wk,
        black_pawns:bp,
        black_king:bk
    )
    Juego(tablero:t,player_actual:j.player_actual)
# player 1 es el white
proc applyMove*(player:int,tab: var Tablero, mv:Move,verbose=false)=
    let idx=maxIndex(mv.mv) 
    let carta = idx div 625
    let pos = idx mod 625
    let idx_fin = pos div 25 
    let idx_init = pos mod 25
    let idx_init_x = idx_init mod 5
    let idx_init_y = idx_init div 5
    let idx_fin_x = idx_fin mod 5
    let idx_fin_y = idx_fin div 5
    if player == 1:
        if tab.white_pawns[idx_init_x][idx_init_y] =~ 1:
            tab.white_pawns[idx_init_x][idx_init_y] = 0.0
            tab.white_pawns[idx_fin_x][idx_fin_y] = 1.0
            tab.black_pawns[idx_fin_x][idx_fin_y] = 0.0
            tab.black_king[idx_fin_x][idx_fin_y] = 0.0
            if carta == 0:
                let new_idle = copyCard(tab.carta_1_1)
                tab.carta_1_1=tab.carta_idle
                tab.carta_idle=new_idle
                if verbose:
                    echo "new idle: " & $new_idle
                    echo ""
                    echo "carta 11: " & $tab.carta_1_1
                    echo ""
                    echo "carta idle: " & $tab.carta_idle
                    echo ""
            else:
                let new_idle = copyCard(tab.carta_1_2)
                tab.carta_1_2=tab.carta_idle
                tab.carta_idle=new_idle
                if verbose:
                    echo "new idle: " & $new_idle
                    echo ""
                    echo "carta 12: " & $tab.carta_1_2
                    echo ""
                    echo "carta idle: " & $tab.carta_idle
                    echo ""
        else:
            tab.white_king[idx_init_x][idx_init_y] = 0.0
            tab.white_king[idx_fin_x][idx_fin_y] = 1.0
            tab.black_pawns[idx_fin_x][idx_fin_y] = 0.0
            tab.black_king[idx_fin_x][idx_fin_y] = 0.0
            if carta == 0:
                let new_idle = copyCard(tab.carta_1_1)
                tab.carta_1_1=tab.carta_idle
                tab.carta_idle=new_idle
            else:
                let new_idle = copyCard(tab.carta_1_2)
                tab.carta_1_2=tab.carta_idle
                tab.carta_idle=new_idle
    else:
        if tab.black_pawns[idx_init_x][idx_init_y] =~ 1:
            tab.black_pawns[idx_init_x][idx_init_y] = 0.0
            tab.black_pawns[idx_fin_x][idx_fin_y] = 1.0
            tab.white_pawns[idx_fin_x][idx_fin_y] = 0.0
            tab.white_king[idx_fin_x][idx_fin_y] = 0.0
            if carta == 0:
                let new_idle = copyCard(tab.carta_2_1)
                tab.carta_2_1=tab.carta_idle
                tab.carta_idle=new_idle
            else:
                let new_idle = copyCard(tab.carta_2_2)
                tab.carta_2_2=tab.carta_idle
                tab.carta_idle=new_idle
        else:
            tab.black_king[idx_init_x][idx_init_y] = 0.0
            tab.black_king[idx_fin_x][idx_fin_y] = 1.0
            tab.white_pawns[idx_fin_x][idx_fin_y] = 0.0
            tab.white_king[idx_fin_x][idx_fin_y] = 0.0
            if carta == 0:
                let new_idle = copyCard(tab.carta_2_1)
                tab.carta_2_1=tab.carta_idle
                tab.carta_idle=new_idle
            else:
                let new_idle = copyCard(tab.carta_2_2)
                tab.carta_2_2=tab.carta_idle
                tab.carta_idle=new_idle

proc selectMove(mvs:seq[Move]):Move=
    for i in countup(0,mvs.len-1,1):
        echo "Opcion: " & $i & ", Move:" & $mvs[i]
    echo "Elija la opcion: "
    var inp:int
    var linea=readLine(stdin)
    var res=parseInt(linea,inp,0)
    while res<0 or res >= mvs.len-1:
        linea=readLine(stdin)
        res=parseInt(linea,inp,0)
    mvs[inp]

proc play()=
    var j = newJuego()
    for _ in countup(0,20,1):
        echo j
        if j.player_actual == 1:
            let mvs=moves(j.tablero,j.player_actual)
            let m=mvs[rand(mvs.len-1)]
            echo m
            applyMove(j.player_actual,j.tablero,m)
            j.player_actual=2
        else:
            let mvs=moves(j.tablero,j.player_actual)
            let m=selectMove(mvs)
            echo m
            applyMove(j.player_actual,j.tablero,m)
            j.player_actual=1


#play()
        
