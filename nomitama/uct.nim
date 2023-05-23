import math
import random
import onitama
import std/sequtils
import std/tables
randomize()
type
    Uct_config* = object
        iteraciones*:int
        cte*:float
    NodeUCT = ref object
        #Quien debe jugar
        estado:Juego
        to_play:int
        prior:float
        puntos:float
        visitas:float
        parent:NodeUCT
        accion:Move
        posibles_acciones:seq[Move]
        hijos:seq[NodeUCT]
proc value_uct(v:NodeUCT,visits_padre:float,cte:float):float=
    v.puntos/v.visitas + cte * sqrt(2 * ln(visits_padre)/v.visitas)
proc otroJugador(p:int):int=
    if p==1: 2 else: 1
proc esTerminal(node:NodeUCT):bool=
    let (final,x)=endGame(node.estado.tablero,1)
    final
proc fully_expanded(node:NodeUCT):bool=
    node.posibles_acciones.len==0
proc newNodeUCT(estado:Juego,parent:NodeUCT,accion:Move):NodeUCT=
    var mvs=moves(estado.tablero,estado.player_actual)
    NodeUCT(estado:estado,to_play:estado.player_actual,prior:0.0,puntos:0.0,visitas:0.0,parent:parent, hijos: @[],accion:accion,posibles_acciones:mvs)
proc expand(node:var NodeUCT):NodeUCT=
    if node.posibles_acciones.len == 1:
        #Esta tambien
        let m = node.posibles_acciones[0]
        var j = copyJuego(node.estado)
        applyMove(j.player_actual,j.tablero,m)
        let otro=otroJugador(j.player_actual)
        j.player_actual = otro
        #Esta linea cambia nomas
        node.posibles_acciones = @[]
        let hijo = newNodeUCT(j,node,m)
        node.hijos.add(hijo)
        return hijo 

    let idx=rand(node.posibles_acciones.len-1)

    if idx == 0:
        #Esta tambien
        let m = node.posibles_acciones[0]
        var j = copyJuego(node.estado)
        applyMove(j.player_actual,j.tablero,m)
        let otro=otroJugador(j.player_actual)
        j.player_actual = otro
        #Esta linea cambia nomas
        node.posibles_acciones = node.posibles_acciones[1..node.posibles_acciones.len-1]
        let hijo = newNodeUCT(j,node,m)
        node.hijos.add(hijo)
        return hijo 
    else:
        #Esta tambien
        let m = node.posibles_acciones[idx]
        var j = copyJuego(node.estado)
        applyMove(j.player_actual,j.tablero,m)
        let otro=otroJugador(j.player_actual)
        j.player_actual = otro
        let slice_1=node.posibles_acciones[0..idx-1]
        let slice_2=node.posibles_acciones[idx+1..node.posibles_acciones.len-1]
        #Esta linea cambia nomas
        node.posibles_acciones = slice_1 & slice_2
        let hijo = newNodeUCT(j,node,m)
        node.hijos.add(hijo)
        return hijo 
proc best_child(v:NodeUCT,uct_config:Uct_config):NodeUCT=

    var mejor_hijo=v.hijos[0]
    var mejor_puntos=v.hijos[0].value_uct(v.visitas,uct_config.cte)
    for h_i in countup(1,v.hijos.len-1,1):
        let puntos=v.hijos[h_i].value_uct(v.visitas,uct_config.cte)
        if puntos>=mejor_puntos:
            mejor_puntos=puntos
            mejor_hijo=v.hijos[h_i]
    mejor_hijo
proc tree_policy(n:NodeUCT,uct_config:Uct_config):NodeUCT=
    var v = n
    
    while not v.esTerminal():
        
        if not v.fully_expanded():
            
            return v.expand()
        else:
            return best_child(v,uct_config)
    v
proc default_policy(v:NodeUCT,player:int):int=
    var juego=v.estado
    while not endGame(juego.tablero,player)[0]:
        let mvs= moves(juego.tablero,juego.player_actual)
        let m=mvs[rand(mvs.len-1)]
        applymove(juego.player_actual,juego.tablero,m)
        if juego.player_actual==1:
            juego.player_actual=2
        else:
            juego.player_actual=1
    endGame(juego.tablero,player)[1]
proc backup(v:var NodeUCT,res_final:int)=
    var n=v
    var puntos=   res_final.toFloat 
    while not isNil(n):
        n.visitas += 1
        n.puntos += puntos
        puntos *= - 1
        n=n.parent
proc uct*(juego:Juego,uct_config:Uct_config,player:int):Move=
    var root = newNodeUCT(juego,nil,nil)
    for i in countup(1,uct_config.iteraciones,1):
        var nodo = tree_policy(root,uct_config)
        var res_final= default_policy(nodo,player)
        backup(nodo,res_final)
    best_child(root,uct_config).accion