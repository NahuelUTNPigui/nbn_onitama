import onitama
import oni_uct
import math
import std/sequtils
import parseutils

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

proc selectMove(mvs:seq[Move],p=1):Move=
    for i in countup(0,mvs.len-1,1):
        echo "Opcion: " & $i & ", Move:" & show(mvs[i],p)
    echo "Elija la opcion: "
    var inp:int
    var linea=readLine(stdin)
    var res=parseInt(linea,inp,0)
    while res<0 or res >= mvs.len-1:
        linea=readLine(stdin)
        res=parseInt(linea,inp,0)
    mvs[inp]

proc main()=  
    echo "Main juego"
    let humano_cod=elija_jugador()
    let dif=elija_dificultad()
    let compu_cod = if humano_cod == 1: 2 else: 1
    echo  "hum_cod: " & $humano_cod
    echo "compu_cod: " & $compu_cod
    var j = newJuego()
    var m:Move=nil
    let uct_config = Uct_config(iteraciones:dif,cte:sqrt(2.0)/2)
    while not endGame(j.tablero,1)[0]:
        
        if j.player_actual==compu_cod:
            #m=rnd_move(j)
            m= uct(j,uct_config,compu_cod)
            echo "Compu"
            echo j
            applyMove(j.player_actual,j.tablero,m)
            j.player_actual=humano_cod
        else:
            echo "Humano"
            echo j
            let mvs=moves(j.tablero,j.player_actual)
            m=selectMove(mvs,humano_cod)
            applyMove(j.player_actual,j.tablero,m)
            j.player_actual=compu_cod
        
        echo m
    if j.player_actual==compu_cod:
        echo "Gano humano"
    else:
        echo "Gano compu"
    echo j
main()

