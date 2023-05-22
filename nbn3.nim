import neo
import random
import math
randomize()
proc makeRandomSeqSeq(M,N:int):seq[seq[float]]=
    var seqseq:seq[seq[float]]= @[]
    for i in countup(0,M-1,1):
        var fila:seq[float]= @[]
        for j in countup(0,N-1,1):
            fila.add(rand(1.0))
        seqseq.add(fila)
    seqseq

proc sigmoide(x:float):float=
    1/(1+exp(-x))
proc der_sigmoide(x:float):float=
    sigmoide(x)*(1-sigmoide(x))
proc relu(x:float):float=
    if x>=0:
        x
    else:
        0
proc der_relu(x:float):float=
    if x>=0:
        1
    else:
        0

let iteraciones=10000
var mu=1.0
let beta=0.1
let alfa=0.5
let inputs= @[
    @[0.0,0.0],
    @[0.0,1.0],
    @[1.0,0.0],
    @[1.0,1.0],
]
let outputs= @[
    @[1.0],
    @[0.0],
    @[0.0],
    @[1.0],
]
let config = @[
    @[2,0,1],
    @[3,0,1,2]   
]
let verbose=false
var matriz_inputs_bias=makeRandomSeqSeq(2,3)
var w12=rand(1.0)
var delta= rand(1.0)
var error=100.0
var error_esperado=0.01
for iter in countup(1,iteraciones,1):
    echo ""
    echo "Iteracion: ",iter
    var error_sumatoria=0.0
    for fila_input in countup(0,inputs.len-1,1):
        
        #Calculo la salida
        var sumatorias=newSeq[float](2)
        var salidas=newSeq[float](2)
        var slopes=newSeq[float](2)
        var derivadas_neurona=newSeq[float](2)
        for neurona in countup(0,1,1):
            let sumatoria=matriz_inputs_bias[neurona][0] * inputs[fila_input][0] + matriz_inputs_bias[neurona][1] * inputs[fila_input][1] + matriz_inputs_bias[neurona][2]
            sumatorias[neurona]=sumatoria
        salidas[0]=sigmoide(sumatorias[0])
        slopes[0]=der_sigmoide(sumatorias[0])
        sumatorias[1] += salidas[0] * w12
        salidas[1]=sigmoide(sumatorias[1])
        #Calculo el error
        let diff=salidas[1]-outputs[fila_input][0]
        slopes[1]=der_sigmoide(sumatorias[1])
        derivadas_neurona[1]=diff*slopes[1]
        #Ya tengo la salida
        #Debo recalcular delta
        delta=derivadas_neurona[1]*w12*slopes[0]
        derivadas_neurona[0]=delta
        if verbose:
            echo "SALIDAS"
            echo salidas
            echo "DERIVADAS"
            echo derivadas_neurona
            echo "deltas"
            echo delta
        
        
        error_sumatoria+=abs(diff)
        #Calculo la derivada de los pesos
        var derivadas_error_peso=newSeq[float](7)
        var peso_i=0
        for i in countup(0,1,1):
            for j in countup(0,2,1):
                if j==2:
                    derivadas_error_peso[peso_i]=derivadas_neurona[i]
                else:
                    derivadas_error_peso[peso_i]=derivadas_neurona[i] * inputs[fila_input][j]
                peso_i += 1
        derivadas_error_peso[peso_i]=salidas[0]*derivadas_neurona[1]
        var peso_i_2=0
        for i in countup(0,1,1):
            for j in countup(0,2,1):
                matriz_inputs_bias[i][j] -= alfa*derivadas_error_peso[peso_i_2]
                peso_i_2 += 1
        w12 -= alfa * derivadas_error_peso[peso_i_2]
        if verbose:
            echo ""
            echo "out put: ",outputs[fila_input][0]
            echo "diff: ",diff
            echo "pesoo"
            echo w12
            echo ""
            echo "Pesos"
            echo matriz_inputs_bias
    error=error_sumatoria

    echo "Error: ", error
    echo ""

    if error_esperado>=error:
        echo "por error"
        echo error
        break
    if iter==iteraciones:
        echo "Por iteraciones"


var sumatorias_posibles=newSeq[float](2)
var salida_posible=0.0
for fila_input in countup(0,inputs.len-1,1):
    for neurona in countup(0,1,1):
        let sumatoria=matriz_inputs_bias[neurona][0] * inputs[fila_input][0] + matriz_inputs_bias[neurona][1] * inputs[fila_input][1] + matriz_inputs_bias[neurona][2]
        sumatorias_posibles[neurona]=sumatoria
    sumatorias_posibles[1] += sigmoide(sumatorias_posibles[0])*w12     
    salida_posible=sigmoide( sumatorias_posibles[1])
    echo inputs[fila_input]
    echo if salida_posible < 0.5: 0 else: 1
    echo outputs[fila_input][0]