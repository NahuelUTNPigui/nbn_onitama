import madelinete
import uct
import math
import std/sequtils
import parseutils

    

proc humano_strategy(j:Juego):Move=
    let mvs=moves(j.player_actual,j.tablero)
    let idxs=mvs.map(proc(x:Move):int=maxIndex(x.mv))
    for idxs_i in countup(0,idxs.len-1,1):
        let idx=idxs[idxs_i]
        let idx_init=idx div 9
        let idx_fin = idx mod 9
        let init_x=idx_init div 3
        let init_y = idx_init mod 3
        let fin_x=idx_fin div 3
        let fin_y = idx_fin mod 3
        echo "Opcion: " & $idxs_i
        echo "(x inicio: " & $init_x & ", y inicio: " & $init_y & ")"
        echo "(x fin: " & $fin_x & ", y fin: " & $fin_y & ")"
    #Eliga
    echo "Elija la opcion: "
    var inp:int
    let linea=readLine(stdin)
    let res=parseInt(linea,inp,0)
    mvs[inp]

proc elija_jugador():int=
    echo "Elija jugador 1 o 2"
    var j:int
    var linea=readLine(stdin)
    var res=parseInt(linea,j,0)
    while res != 1 and res != 2:
        echo "Deber ser 1 o 2"
        linea=readLine(stdin)
        res=parseInt(linea,j,0)
    j
proc elija_dificultad():int=
    echo "Elija dificultad 1 , 2 o 3"
    var j:int
    var linea=readLine(stdin)
    var res=parseInt(linea,j,0)
    while res != 1 and res != 2 and res!=3:
        echo "Deber ser 1 o 2 o 3"
        linea=readLine(stdin)
        res=parseInt(linea,j,0)
    if j == 1:
        return 50
    elif j == 2:
        return 200
    else:
        return 500

proc main()=  
    echo "Main juego"
    let humano_cod=elija_jugador()
    let dif=elija_dificultad()
    let compu_cod = if humano_cod == 1: 2 else: 1
    echo  humano_cod
    echo compu_cod
    var j = newJuego()
    var m:Move=nil
    let uct_config = Uct_config(iteraciones:dif,cte:sqrt(2.0)/2)
    while not endGame(j.tablero,1)[0]:
        
        if j.player_actual==compu_cod:
            #m=rnd_move(j)
            m= uct(j,uct_config,compu_cod)
            applymove(j.player_actual,j.tablero,m)
            echo j
            j.player_actual=humano_cod
        else:
            echo j
            m=humano_strategy(j)
            applymove(j.player_actual,j.tablero,m)
            j.player_actual=compu_cod
        let idx=maxIndex(m.mv)
        echo "( " & $(idx div 9) & ", " & $(idx mod 9) & ")"
main()