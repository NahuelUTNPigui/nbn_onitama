import neo
import math
import random
import std/sequtils
randomize()

#Funciones auxiliares
proc setParent(padres: var seq[seq[int]],son:int,big_father:int,config:seq[seq[int]],dummies:int)=
    let linea = config[son-dummies]
    for son_son in linea:
        if son_son != son and son_son >= dummies:
            if not any(padres[son_son-dummies],proc(x:int):bool=x==big_father):
                setParent(padres,son_son,big_father,config,dummies)
    if not any(padres[son-dummies],proc(x:int):bool=x==big_father):    
        padres[son-dummies].add(big_father)
proc isParent(padres:seq[seq[int]],son:int,big_father:int,dummies:int):bool=
    any(padres[son-dummies],proc(x:int):bool=x==big_father)
#Tiene un problema grande este algoritmo no puede realmente tener cualquier arquitectura

type
    Peso = object
        valor : float
        valido: bool
    RedNBN = object
        salidas:seq[float]
        #Lo voy a usar para guardar las derivadas de las neuronass
        slopes:seq[float]
        #Creo que no aplica lo de la matriz aca, pero ya lo hice
        #Matriz que representa los pesos entre neuronas
        matriz_pesos_delta:Matrix[Peso]
        #La matriz que representa los pesos con los inputs y el bias
        matriz_inputs_bias:Matrix[Peso]
        #Las neuronas que representan la salida
        output:seq[int]
        mu:float
        beta:float
        dummies:int
        activ:proc(x:float):float
        der_activ:proc(x:float):float
        padres:seq[seq[int]]
        cantidad_pesos:int
proc showMatriz(m:Matrix[Peso],nombre:string )=
    echo nombre
    for fila in countup(0,m.M-1,1):
        var fila_s = "[ "
        for col in countup(0,m.N-1,1):
            let v=if m[fila,col].valido: "tr" else: "fs"
            fila_s = fila_s & " Valido: " & v & " and valor :" & $m[fila,col].valor.round(1).abs() & "|"
        echo fila_s & "]"
#El config es una matriz que tiene como fila neuronas y le sigue sus
# sus predecesoras y dummies representa las neuronas de input
# Debe haber una forma de validar el config con el dummies y el output
proc newRedNBN(dummies:int,config:seq[seq[int]],output:seq[int],activ:proc(x:float):float,der_activ:proc(x:float):float):RedNBN=
    var cantidad_pesos=config.len
    var matriz_inputs_bias:Matrix[Peso]=makeMatrix(config.len,dummies+1,proc(i,j:int):Peso=Peso(valor:rand(1.0)-0.5,valido:false))
    var matriz_pesos_delta:Matrix[Peso]=makeMatrix(config.len,config.len,proc(i,j:int):Peso=Peso(valor:rand(1.0)-0.5,valido:false))
    var padres=newSeq[seq[int]](config.len)
    var i=0
    for fila in config:
        padres[i]=newSeq[int]()
        let id_fila=fila[0]-dummies
        for i in countup(1,fila.len-1,1):
            #La ultima columna es el bias y siempre es valido
            matriz_inputs_bias[id_fila,dummies].valido=true
            if(fila[i]<dummies):
                matriz_inputs_bias[id_fila,fila[i]].valido=true
                cantidad_pesos += 1
            else:
                let id_neurona_inp=fila[i]-dummies
                matriz_pesos_delta[id_neurona_inp,id_fila].valido=true
                cantidad_pesos += 1
        i += 1

    for i in countdown(config.len-1,0,1):
        let linea=config[i]
        for son in linea:
            if son>=dummies and not any(padres[son-dummies],proc(x:int):bool=x==linea[0]):
                setParent(padres,son,linea[0],config,dummies)
    #[
    for o in countup(0,output.len-1,1):
        let linea = config[output[o]-dummies]
        for son in linea:
            if son != o:
                if not any(padres[son-dummies],proc(x:int):bool=x==output[o]):
                    setParent(padres,son,output[o],config,dummies)
            else:
                padres[output[o]-dummies].add(output[o])
    ]#
    var salidas = newSeq[float](config.len)
    var slopes = newSeq[float](config.len)
    
    RedNBN(
        matriz_inputs_bias:matriz_inputs_bias,
        matriz_pesos_delta:matriz_pesos_delta,
        output:output,
        dummies:dummies,
        salidas:salidas,
        slopes:slopes,
        activ:activ,
        der_activ:der_activ,
        padres:padres,
        cantidad_pesos:cantidad_pesos)
proc predict(red:RedNBN,matriz_inputs_bias:Matrix[Peso],matriz_pesos_delta:Matrix[Peso],input:seq[float]):seq[float]=
    var salida=newSeq[float](matriz_inputs_bias.M)
    for fila_i in countup(0,matriz_inputs_bias.M-1,1):
        var suma = matriz_inputs_bias[fila_i,red.dummies].valor
        for inp in countup(0,input.len-1,1):
            if(matriz_inputs_bias[fila_i,inp].valido):
                suma += matriz_inputs_bias[fila_i,inp].valor*input[inp]
        if fila_i!=0:
            for fila_pesos_delta in countup(0,fila_i-1,1):
                if(matriz_pesos_delta[fila_pesos_delta,fila_i].valido):
                    suma += salida[fila_pesos_delta]*matriz_pesos_delta[fila_pesos_delta,fila_i].valor
        salida[fila_i]=red.activ(suma)
    var output:seq[float]= @[]
    
    for o in red.output:
        output.add(salida[o-red.dummies])
    output

proc train(red:var RedNBN,inputs:seq[seq[float]],outputs_expected:seq[seq[float]],mu:float,beta:float,epochs:int,max_error:float)=
    var error=100.0
    var epoch:int=1
    red.mu=mu
    red.beta=beta
    let pesos_validos=red.cantidad_pesos
    while epoch<epochs:
        var Q = makeMatrix(pesos_validos,pesos_validos,proc(i,j:int):float=0)
        var g = makeMatrix(pesos_validos,1,proc(i,j:int):float=0)
        for pattern_i in countup(0,inputs.len-1,1):
            let input=inputs[pattern_i]
            let output_expected=outputs_expected[pattern_i]
            #k
            for fila_i in countup(0,red.matriz_inputs_bias.M-1,1):
                var suma = red.matriz_inputs_bias[fila_i,red.dummies].valor
                for inp in countup(0,input.len-1,1):
                    if(red.matriz_inputs_bias[fila_i,inp].valido):
                        suma += red.matriz_inputs_bias[fila_i,inp].valor*input[inp]
                for fila_pesos_delta in countup(0,fila_i-1,1):
                    if(red.matriz_pesos_delta[fila_pesos_delta,fila_i].valido):
                        suma += red.salidas[fila_pesos_delta]*red.matriz_pesos_delta[fila_pesos_delta,fila_i].valor
                red.salidas[fila_i]=red.activ(suma)
                let delta_i=red.der_activ(suma)
                red.matriz_pesos_delta[fila_i,fila_i] = Peso(valor:delta_i,valido:true)
                #Hasta aca la salida
                if (fila_i!=0):
                    #j
                    #Es mas bien columnas y es al reves
                    for columna_pesos_delta in countdown(fila_i-1,0,1):
                        #Calcular los deltas de la lower traingle
                        if(isParent(red.padres,columna_pesos_delta + red.dummies,fila_i+red.dummies,red.dummies)):
                            var xkj=0.0 #Aaca iria la ecuacion 24
                            for i in countup(columna_pesos_delta,fila_i-1,1):
                                let w=red.matriz_pesos_delta[i,fila_i]
                                let d=red.matriz_pesos_delta[i,columna_pesos_delta]
                                if w.valido and d.valido:
                                    xkj += w.valor * d.valor
                            #Ecuacion 25
                            let dkj=red.matriz_pesos_delta[fila_i,fila_i].valor*xkj
                            red.matriz_pesos_delta[fila_i,columna_pesos_delta]=Peso(valor:dkj,valido:true)

            #Calcular error y jacobiano por error
            for i in countup(0,output_expected.len-1,1):
                let o =red.output[i]
                let diff= -red.salidas[o-red.dummies]+output_expected[i]
                #Calcular las derivadas por neuronas
                var derivadas_neurona=newSeq[float](red.salidas.len)
                for n_idx in countup(0,red.salidas.len-1,1):
                    if n_idx+red.dummies>o:
                        derivadas_neurona[n_idx]=0
                    elif n_idx+red.dummies == o:
                        derivadas_neurona[n_idx]= red.matriz_pesos_delta[n_idx,n_idx].valor
                    else:
                        var derivada:float=0.0
                        for fila in countup(n_idx+1,o-red.dummies,1):
                            if isParent(red.padres,fila+red.dummies,o,red.dummies):
                                derivada += red.matriz_pesos_delta[fila,n_idx].valor
                        derivadas_neurona[n_idx]=derivada
                #Funciaona?
                #echo "Derivas"
                #echo derivadas_neurona
                #JACOBIANO
                var jacob =newSeq[float](pesos_validos)

                var pesos_i=0
                #Se calcula la primera parte del jacobino
                for fila_input_bias in countup(0,red.matriz_inputs_bias.M-1,1):
                    for columna_input_bias in countup(0,red.matriz_inputs_bias.N-1,1):
                        if red.matriz_inputs_bias[fila_input_bias,columna_input_bias].valido:
                            if columna_input_bias==(red.matriz_inputs_bias.N-1):
                                #echo "bias"
                                jacob[pesos_i] = derivadas_neurona[fila_input_bias]
                            elif isParent(red.padres,fila_input_bias+red.dummies,o,red.dummies):
                                echo "hija: " , fila_input_bias
                                jacob[pesos_i] = input[columna_input_bias]*derivadas_neurona[fila_input_bias]
                                echo jacob[pesos_i]
                            else:
                                jacob[pesos_i] = 0
                            pesos_i += 1
                #Calculos pesos entre neuronas
                for fila_pesos_delta in countup(0,red.matriz_pesos_delta.M-1,1):
                    for columna_pesos_delta in countup(fila_pesos_delta+1,red.matriz_pesos_delta.N-1,1):
                        if red.matriz_pesos_delta[fila_pesos_delta,columna_pesos_delta].valido:
                            
                            #Aca va la ecuacion 13.12
                            jacob[pesos_i] = red.salidas[fila_pesos_delta] * derivadas_neurona[columna_pesos_delta]
                            pesos_i += 1
                #Aca viene la creacion de los j,q,g
                let jacob_v=makeMatrix[float](jacob.len,1,proc(i,j:int):float=jacob[i])
                #echo "jacob"
                #echo jacob_v
                let q_mini=jacob_v * jacob_v.t
                let n_mini=jacob_v*diff
                echo "mini"
                echo n_mini
                echo "jacob"
                echo jacob
                Q += q_mini
                g += n_mini
            
        #Terminado el epoch veo que me conviene si mejorar los pesos o mejorar el mu
        let H =Q - red.mu * eye(Q.M)
        let d= solve(H,g)
        echo "H"
        echo H
        echo "g"
        echo g
        echo "d"
        echo d
        var nuevo_pesos_inputs=makeMatrix(red.matriz_inputs_bias.M,red.matriz_inputs_bias.N,proc(i,j:int):Peso=Peso(valor:0,valido:false))
        var nuevo_pesos_delta=makeMatrix(red.matriz_pesos_delta.M,red.matriz_pesos_delta.N,proc(i,j:int):Peso=Peso(valor:0,valido:false))
        var pesos_i=0
        #Modifico los nuevos pesos
        for fila_input_bias in countup(0,nuevo_pesos_inputs.M-1,1):
            for columna_input_bias in countup(0,nuevo_pesos_inputs.N-1,1):
                if red.matriz_inputs_bias[fila_input_bias,columna_input_bias].valido:
                    nuevo_pesos_inputs[fila_input_bias,columna_input_bias].valor=red.matriz_inputs_bias[fila_input_bias,columna_input_bias].valor - d[pesos_i,0]
                    nuevo_pesos_inputs[fila_input_bias,columna_input_bias].valido=true
                    pesos_i += 1
        for fila_delta in countup(0,nuevo_pesos_delta.M-1,1):
            for columna_delta in countup(fila_delta+1,nuevo_pesos_delta.M-1,1):
                if red.matriz_pesos_delta[fila_delta,columna_delta].valido:
                    nuevo_pesos_delta[fila_delta,columna_delta].valor=red.matriz_pesos_delta[fila_delta,columna_delta].valor - d[pesos_i,0]
                    nuevo_pesos_delta[fila_delta,columna_delta].valido=true
                    pesos_i += 1
        error=0.0
        var error_posible=0.0
        #Con la configuracion actual
        for input_i in countup(0,inputs.len-1,1):
            let salida=predict(red,red.matriz_inputs_bias,red.matriz_pesos_delta,inputs[input_i])
            let salida_posible=predict(red,nuevo_pesos_inputs,nuevo_pesos_delta,inputs[input_i])
            let o=outputs_expected[input_i]
            for numero_i in countup(0,o.len-1,1):
                error += abs(salida[numero_i]-o[numero_i])
                error_posible += abs(salida_posible[numero_i]-o[numero_i])
        
        
        if error_posible>error:
            red.mu /= red.beta
            #echo "mu crece"
        else:
            
            red.mu *= red.beta
            
            red.matriz_pesos_delta=nuevo_pesos_delta
        
            red.matriz_inputs_bias=nuevo_pesos_inputs
            epoch += 1
            #nuevo_pesos_inputs.showMatriz("Nuevo pesos inputs")
            #red.matriz_inputs_bias.showMatriz("Matriz de la red")
        
        let error=min(error_posible,error)
        echo error
        if (error<=max_error):
            echo "por error"
            break
        if epoch== epochs:
            echo "Epoca"
        
#[
    0 d
    1 d
    2 d
    3 0 1 2
    4 0 1 2 3
    5 0 1 2 3 4
]#
#[
    0 d
    1 0
    2 0 1
    3 0 1 2
]#
let config = @[
    @[1,0],
    @[2,0],
    @[3,1,2]   
]
let config2= @[
    @[2,1,0],
    @[3,1,0],
    @[4,2],
    @[5,3],
    @[6,4,5,3],
    @[7,4,2]
]
let config3= @[
    @[2,1,0],
    @[3,2,1,0]
]
let output= @[3]
let output2= @[7,6]
let inputs3 = @[
    @[0.0,0.0],
    @[1.0,1.0],
    @[1.0,0.0],
    @[0.0,1.0],
]
let outs3= @[
    @[0.0],
    @[0.0],
    @[1.0],
    @[1.0]
]
let output3= @[3]
let dummies=1
let dummies2=2
let dummies3=2
let entries2= @[ @[1.0,1.0]]
let outs2= @[ @[1.0,1.0]]
var red=newRedNBN(dummies3,config3, output3,func(x:float):float=1/(1+exp(-x)),func(x:float):float=(1/(1+exp(-x)))*(1-1/(1+exp(-x))))
#echo red.padres
#let prediction = red.predict(@[1.0])


red.train(inputs3,outs3,5.5,0.1,5,0.005)

echo red.predict(red.matriz_inputs_bias,red.matriz_pesos_delta,inputs3[0])
echo red.predict(red.matriz_inputs_bias,red.matriz_pesos_delta,inputs3[1])
echo red.predict(red.matriz_inputs_bias,red.matriz_pesos_delta,inputs3[2])
echo red.predict(red.matriz_inputs_bias,red.matriz_pesos_delta,inputs3[3])
#red.matriz_inputs_bias.showMatriz("inputs")

#red.matriz_pesos_delta.showMatriz("deltas")

#[
echo red.cantidad_pesos
var cantidad_real=0
for i in countup(0,red.matriz_inputs_bias.M-1,1):
    for j in countup(0,red.matriz_inputs_bias.N-1,1):
        if red.matriz_inputs_bias[i,j].valido:
            cantidad_real += 1
for i in countup(0,red.matriz_pesos_delta.M-1,1):
    for j in countup(0,red.matriz_pesos_delta.N-1,1):
        if red.matriz_pesos_delta[i,j].valido:
            cantidad_real += 1
echo cantidad_real
for i in countup(0,red.padres.len-1,1):
    echo i + dummies
    echo red.padres[i]

]#

