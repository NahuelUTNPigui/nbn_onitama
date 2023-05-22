import neo
import random
import math
import std/sequtils
import redalphazero


proc play_alphazero()=
    let config2 = @[
        @[3,2,1,0],
        @[4,3,2,1,0],
        @[5,4,3,2,1,0]
    ]
    let inputs2= @[
        @[0.0,0.0,1],
        @[1.0,1.0,0],
        @[1.0,0.0,1],
        @[1.0,0.0,0],
        @[0.0,0.0,0]
    ]
    let outputs_exp2= @[
        @[1.0,0],
        @[0.0,1],
        @[1.0,0],
        @[0.0,1],
        @[0.5,0.5]
        # Es imposible es a lo sumo 50 y 50 @[0.0,0]
    ]
    let dummies2=3
    let output2= @[5,4]
    var red=newRedNBN2(dummies2,config2, output2,sigmoide,der_sigmoide)
    echo "Antes de aprender"
    
    #for inp in inputs2:
    #    echo red.predict(inp)
    let epochs=5000
    let max_error=0.0000001
    let alfa=0.9
    let e = red.learn_gr_alphazero(epochs,alfa,max_error,inputs2,outputs_exp2,0.0,false,false)
    echo "Luego de aprender"
    echo "Error: ",e
    var i = 0
    for inp in inputs2:
        echo "Esperado"
        echo outputs_exp2[i]
        i += 1
        echo "Real"
        echo red.predict_alphazero(inp)

proc train(dummies:int,config:seq[seq[int]],output_neurons:seq[int],mcts_sims:int,epochs:int):RedNBN2=
    var nn=newRedNBN2(dummies,config,output_neurons,relu,der_relu)

    nn
var (x,y) = (10 , 1)
echo x
echo  y
(x,y)=(y,x)
echo x
echo  y