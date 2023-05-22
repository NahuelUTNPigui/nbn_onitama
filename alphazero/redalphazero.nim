# Es muy parecido a nbn pero al final uso softmax
import neo
import random
import math
import std/sequtils
import jsony
randomize()
#Clases
type
    Peso = object
        valor : float
        valido: bool
    RedNBN2* = object
        config :seq[seq[int]]
        padres :seq[seq[int]]
        pesos_inputs:seq[seq[Peso]]
        pesos_deltas:seq[seq[Peso]]
        #pesos_w:seq[float] # Es para la ultima capa del valor
        output_neurons:seq[int]
        dummies:int
        cantidad_pesos:int
        activ:proc(x:float):float
        der_activ:proc(x:float):float
    PesosRed* = object
        config :seq[seq[int]]
        padres :seq[seq[int]]
        pesos_inputs:seq[seq[Peso]]
        pesos_deltas:seq[seq[Peso]]
        #pesos_w:seq[float] # Es para la ultima capa del valor
        output_neurons:seq[int]
        dummies:int
        cantidad_pesos:int
#Funciones auxiliares
proc makePesosRed(red:RedNBN2):PesosRed=
    PesosRed(
        config:red.config,
        padres:red.padres,
        pesos_inputs:red.pesos_inputs,
        pesos_deltas:red.pesos_deltas,
        output_neurons:red.output_neurons,
        dummies:red.dummies,
        cantidad_pesos:red.cantidad_pesos
    )
proc fromPesosRed(pesos:PesosRed,activ: proc(x:float):float,der_activ:proc(y:float):float):RedNBN2=
    RedNBN2(
        config:pesos.config,
        padres:pesos.padres,
        pesos_inputs:pesos.pesos_inputs,
        pesos_deltas:pesos.pesos_deltas,
        output_neurons:pesos.output_neurons,
        dummies:pesos.dummies,
        cantidad_pesos:pesos.cantidad_pesos,       
        activ:activ,
        der_activ:der_activ 
    )
proc makeRandomSeqSeq(M,N:int):seq[seq[float]]=
    var seqseq:seq[seq[float]]= @[]
    for i in countup(0,M-1,1):
        var fila:seq[float]= @[]
        for j in countup(0,N-1,1):
            fila.add(rand(1.0))
        seqseq.add(fila)
    seqseq
proc makeRandomSeqPesos(M,N:int):seq[seq[Peso]]=
    var seqPeso:seq[seq[Peso]] = @[]
    for i in countup(0,M-1,1):
        var fila:seq[Peso]= @[]
        for j in countup(0,N-1,1):
            fila.add(Peso(valor:rand(1.0),valido:false))
        seqPeso.add(fila)
    seqPeso
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

proc toStringPesosMtx(mtx:seq[seq[Peso]]):string=
    var s = ""
    for f_i in countup(0,mtx.len-1,1):
        
        s &= "\n[ "
        for c_j in countup(0,mtx[0].len-1,1):
            s &= "| "
            if mtx[f_i][c_j].valido: s &= $round(mtx[f_i][c_j].valor,2) else: s &= "cero"
            s &= " |"
        s &= " ]"
    s


proc distributiva(j:var seq[float],n:float)=
    for i in countup(0,j.len-1,1):
        j[i] *= n

proc newRedNBN2*(dummies:int,config:seq[seq[int]],output_neurons:seq[int],activ:proc(x:float):float,der_activ:proc(x:float):float):RedNBN2=
    var pesos_inputs=makeRandomSeqPesos(config.len,dummies+1)
    var pesos_deltas=makeRandomSeqPesos(config.len,config.len)
    var padres=newSeq[seq[int]](config.len)
    var j=0
    var cantidad_pesos = 0
    for fila in config:
        padres[j]=newSeq[int]()
        let id_fila=fila[0]-dummies
        for i in countup(1,fila.len-1,1):
            #La ultima columna es el bias y siempre es valido
            pesos_inputs[id_fila][dummies].valido=true
            if(fila[i]<dummies):
                pesos_inputs[id_fila][fila[i]].valido=true
                cantidad_pesos += 1
            else:
                let id_neurona_inp=fila[i]-dummies
                pesos_deltas[id_neurona_inp][id_fila].valido=true
                cantidad_pesos += 1
        j += 1

    for i in countdown(config.len-1,0,1):
        let linea=config[i]
        for son in linea:
            if son>=dummies and not any(padres[son-dummies],proc(x:int):bool=x==linea[0]):
                setParent(padres,son,linea[0],config,dummies)
    
    RedNBN2(config:config,output_neurons:output_neurons,activ:activ,der_activ:der_activ,dummies:dummies,pesos_inputs:pesos_inputs,pesos_deltas:pesos_deltas,cantidad_pesos:cantidad_pesos,padres:padres)

proc sigmoide*(x:float):float=
    1/(1+exp(-x))
proc der_sigmoide*(x:float):float=
    sigmoide(x)*(1-sigmoide(x))
proc relu*(x:float):float=
    if x>=0:
        x
    else:
        0
proc der_relu*(x:float):float=
    if x>=0:
        1
    else:
        0
proc sfmax*(xs:seq[float]):seq[float]=
    var suma =0.0
    for x in xs:
        suma += exp(x)
    var res = newSeq[float](xs.len)
    var i=0
    for x in xs:
        res[i] = exp(x)/suma
        i += 1
    res
proc predict*(red: RedNBN2,input:seq[float]):seq[float]=
    var salida=newSeq[float](red.pesos_inputs.len)
    for fila_i in countup(0,red.pesos_inputs.len-1,1):
        var suma = red.pesos_inputs[fila_i][red.dummies].valor
        for inp in countup(0,input.len-1,1):
            if(red.pesos_inputs[fila_i][inp].valido):
                suma += red.pesos_inputs[fila_i][inp].valor*input[inp]
        if fila_i!=0:
            for fila_pesos_delta in countup(0,fila_i-1,1):
                if(red.pesos_deltas[fila_pesos_delta][fila_i].valido):
                    suma += salida[fila_pesos_delta]*red.pesos_deltas[fila_pesos_delta][fila_i].valor
        salida[fila_i]=red.activ(suma)
    var output:seq[float]= @[]
    
    for o in red.output_neurons:
        output.add(salida[o-red.dummies])
    output
proc actualizar_gr(red: var RedNBN2,j:seq[float],o_n:int,alfa:float,regularization_cte:float,regularization=false)=
    var pesos_i = 0
    # nim
    for nn_i in countup(0,red.config.len-1,1):
        if isParent(red.padres,nn_i + red.dummies,o_n,red.dummies):
            for c_inp in countup(0,red.dummies,1):
                if red.pesos_inputs[nn_i][c_inp].valido:
                    red.pesos_inputs[nn_i][c_inp].valor -= j[pesos_i]*alfa - (if regularization: regularization_cte * red.pesos_inputs[nn_i][c_inp].valor else : 0)
                    pesos_i += 1
            for ny_i in countup(0,nn_i-1,1):
                if red.pesos_deltas[ny_i][nn_i].valido:
                    red.pesos_deltas[ny_i][nn_i].valor -= j[pesos_i]*alfa - (if regularization: regularization_cte * red.pesos_inputs[ny_i][nn_i].valor else : 0)
                    pesos_i += 1
#El normal
proc learn_gr2*(red: var RedNBN2, iteraciones:int,alfa:float,max_error:float,inputs:seq[seq[float]],outputs:seq[seq[float]],verbose=false):float=
    var error=0.0
    var prev_error=0.0
    for iter in countup(1, iteraciones,1):
        if verbose:
            echo "Iter: ",iter

        var salida=newSeq[float](red.config.len)
        var der_salida=newSeq[float](red.config.len)
        prev_error=error
        error=0
        
        for p_i in countup(0,inputs.len-1,1):
            
            let inp_exp=inputs[p_i]
            if verbose:
                echo "patter"
                echo inp_exp
            let out_exp=outputs[p_i]
            salida=newSeq[float](red.config.len)
            der_salida=newSeq[float](red.config.len)
            #k
            for nn_i in countup(0,red.config.len-1,1):
                #salida de las neuronas
                var suma= red.pesos_inputs[nn_i][red.dummies].valor
                for inp_i in countup(0,red.dummies-1,1):
                    if red.pesos_inputs[nn_i][inp_i].valido:
                        suma += red.pesos_inputs[nn_i][inp_i].valor * inp_exp[inp_i]
                for nx_i in countup(0,nn_i-1,1):
                    if red.pesos_deltas[nx_i][nn_i].valido:
                        suma += red.pesos_deltas[nx_i][nn_i].valor * salida[nx_i]
                salida[nn_i] = red.activ suma
                der_salida[nn_i] = red.der_activ suma
                #calcular los deltas
                for ny_i in countdown(nn_i,0,1):
                    if ny_i == nn_i:
                        red.pesos_deltas[nn_i][nn_i].valido=true
                        red.pesos_deltas[nn_i][nn_i].valor=der_salida[nn_i]
                    else:
                        if isParent(red.padres,ny_i + red.dummies, nn_i + red.dummies,red.dummies):
                            var xkj=0.0
                            for i in countup(ny_i,nn_i-1,1):
                                if red.pesos_deltas[i][nn_i].valido and red.pesos_deltas[i][ny_i].valido:
                                    xkj += red.pesos_deltas[i][nn_i].valor * red.pesos_deltas[i][ny_i].valor
                            var dkj= xkj * red.pesos_deltas[nn_i][nn_i].valor
                            red.pesos_deltas[nn_i][ny_i].valido=true
                            red.pesos_deltas[nn_i][ny_i].valor=dkj
                
            
            #Aca viene calcular le jacobiano
            for o_i in countup(0, out_exp.len-1,1):
                let o_neurona = red.output_neurons[o_i]
                var j =newSeq[float]()
                
                for nn_i in countup(0,red.config.len-1,1):
                    let derivadas_neurona_out=red.pesos_deltas[o_neurona-red.dummies][nn_i].valor
                    if isParent(red.padres,nn_i + red.dummies,o_neurona,red.dummies):
                        for c_inp in countup(0,red.dummies,1):
                            if red.pesos_inputs[nn_i][c_inp].valido:
                                if c_inp==red.dummies:
                                    j.add(derivadas_neurona_out)
                                else:
                                    j.add(derivadas_neurona_out * inp_exp[c_inp])
                        for nx_i in countup(0,nn_i-1,1):
                            if red.pesos_deltas[nx_i][nn_i].valido:
                                j.add(derivadas_neurona_out * salida[nx_i])
                let diff = - salida[o_neurona-red.dummies] + out_exp[o_i]
                if verbose:
                    echo "o_n: ",o_neurona
                    echo "Diff: ",diff
                j.distributiva(diff)
                error += abs(diff)
                if verbose:
                    echo "j"
                    echo j
                if verbose:
                    echo "Pesos deltas antes"
                    echo toStringPesosMtx(red.pesos_deltas)
                    echo ""
                    echo "pesos inputs antes"
                    echo toStringPesosMtx(red.pesos_inputs)
                    echo ""
                actualizar_gr(red,j,o_neurona,alfa,0.0,false)
                if verbose:
                    echo "Pesos deltas despues"
                    echo toStringPesosMtx(red.pesos_deltas)
                    echo ""
                    echo "pesos inputs despues"
                    echo toStringPesosMtx(red.pesos_inputs)
                    echo ""
        if verbose:
            echo "Error: ",error
        if error < max_error or abs(prev_error - error) <= max_error:
            if verbose:
                echo "Iter ",iter
                if abs(prev_error - error) <= max_error:
                    echo "No hubo cambio en el error"
            return error


    error
proc predict_alphazero*(red: RedNBN2,input:seq[float]):seq[float]=
    var salida=newSeq[float](red.pesos_inputs.len)
    for fila_i in countup(0,red.pesos_inputs.len-1,1):
        var suma = red.pesos_inputs[fila_i][red.dummies].valor
        for inp in countup(0,input.len-1,1):
            if(red.pesos_inputs[fila_i][inp].valido):
                suma += red.pesos_inputs[fila_i][inp].valor*input[inp]
        if fila_i!=0:
            for fila_pesos_delta in countup(0,fila_i-1,1):
                if(red.pesos_deltas[fila_pesos_delta][fila_i].valido):
                    suma += salida[fila_pesos_delta]*red.pesos_deltas[fila_pesos_delta][fila_i].valor
        salida[fila_i]=red.activ(suma)
    var output:seq[float]= @[]
    
    for o in red.output_neurons:

        output.add(salida[o-red.dummies])
    var suma=0.0
 
    var prob_vector=sfmax(output)
    
    prob_vector

# Será sin board value, porque hay una red encima y mucho lio
# Debo agregar regularization
proc learn_gr_alphazero*(red: var RedNBN2, iteraciones:int,alfa:float,max_error:float,inputs:seq[seq[float]],outputs:seq[seq[float]],regularization_cte:float , regularization=false,verbose=false):float=
    var error=0.0
    var prev_error=0.0
    for iter in countup(1, iteraciones,1):
        if verbose:
            echo "Iter: ",iter

        var salida=newSeq[float](red.config.len)
        var der_salida=newSeq[float](red.config.len)
        prev_error=error
        error=0
        
        for p_i in countup(0,inputs.len-1,1):
            
            let inp_exp=inputs[p_i]
            if verbose:
                echo "patter"
                echo inp_exp
            let out_exp=outputs[p_i]
            salida=newSeq[float](red.config.len)
            der_salida=newSeq[float](red.config.len)
            #k
            for nn_i in countup(0,red.config.len-1,1):
                #salida de las neuronas
                var suma= red.pesos_inputs[nn_i][red.dummies].valor
                for inp_i in countup(0,red.dummies-1,1):
                    if red.pesos_inputs[nn_i][inp_i].valido:
                        suma += red.pesos_inputs[nn_i][inp_i].valor * inp_exp[inp_i]
                for nx_i in countup(0,nn_i-1,1):
                    if red.pesos_deltas[nx_i][nn_i].valido:
                        suma += red.pesos_deltas[nx_i][nn_i].valor * salida[nx_i]
                salida[nn_i] = red.activ suma
                der_salida[nn_i] = red.der_activ suma
                #calcular los deltas
                for ny_i in countdown(nn_i,0,1):
                    if ny_i == nn_i:
                        red.pesos_deltas[nn_i][nn_i].valido=true
                        red.pesos_deltas[nn_i][nn_i].valor=der_salida[nn_i]
                    else:
                        if isParent(red.padres,ny_i + red.dummies, nn_i + red.dummies,red.dummies):
                            var xkj=0.0
                            for i in countup(ny_i,nn_i-1,1):
                                if red.pesos_deltas[i][nn_i].valido and red.pesos_deltas[i][ny_i].valido:
                                    xkj += red.pesos_deltas[i][nn_i].valor * red.pesos_deltas[i][ny_i].valor
                            var dkj= xkj * red.pesos_deltas[nn_i][nn_i].valor
                            red.pesos_deltas[nn_i][ny_i].valido=true
                            red.pesos_deltas[nn_i][ny_i].valor=dkj
            #Primero calculo board_value 
            var salid_vector:seq[float] = newSeq[float](out_exp.len)
            for o_i in countup(0,out_exp.len-1,1):
                salid_vector[o_i] = salida[red.output_neurons[o_i]-red.dummies]

            var prob_vector=sfmax(salid_vector)
            #Aca viene calcular le jacobiano
            
            for o_i in countup(0, out_exp.len-1,1):
                let o_neurona = red.output_neurons[o_i]
                var j =newSeq[float]()
                
                for nn_i in countup(0,red.config.len-1,1):
                    let derivadas_neurona_out=red.pesos_deltas[o_neurona-red.dummies][nn_i].valor
                    if isParent(red.padres,nn_i + red.dummies,o_neurona,red.dummies):
                        for c_inp in countup(0,red.dummies,1):
                            if red.pesos_inputs[nn_i][c_inp].valido:
                                if c_inp==red.dummies:
                                    j.add(derivadas_neurona_out)
                                else:
                                    j.add(derivadas_neurona_out * inp_exp[c_inp])
                        for nx_i in countup(0,nn_i-1,1):
                            if red.pesos_deltas[nx_i][nn_i].valido:
                                j.add(derivadas_neurona_out * salida[nx_i])
                let diff =prob_vector[o_i] - out_exp[o_i]
                if verbose:
                    echo "o_n: ",o_neurona
                    echo "Diff: ",diff
                j.distributiva(diff)
                error += abs(diff)
                if verbose:
                    echo "j"
                    echo j
                if verbose:
                    echo "Pesos deltas antes"
                    echo toStringPesosMtx(red.pesos_deltas)
                    echo ""
                    echo "pesos inputs antes"
                    echo toStringPesosMtx(red.pesos_inputs)
                    echo ""
                actualizar_gr(red,j,o_neurona,alfa,regularization_cte,regularization)
                if verbose:
                    echo "Pesos deltas despues"
                    echo toStringPesosMtx(red.pesos_deltas)
                    echo ""
                    echo "pesos inputs despues"
                    echo toStringPesosMtx(red.pesos_inputs)
                    echo ""
        if verbose:
            echo "Error: ",error
        if error < max_error or abs(prev_error - error) <= max_error:
            if verbose:
                echo "Iter ",iter
                if abs(prev_error - error) <= max_error:
                    echo "No hubo cambio en el error"
            return error


    error

proc toFile*(file_name:string,red:PesosRed)=
    let text = red.toJson()
    writeFile(file_name,text)
    

proc fromFile*(file_name:string,activ: proc(x:float):float,der_activ:proc(y:float):float):RedNBN2=
    var entireFile = readFile(file_name)
    var pesos=entireFile.fromJson(PesosRed) 
    fromPesosRed(pesos,activ,der_activ)
    
proc play()=
    let config3 = @[
    @[2,1,0],
    @[3,1,0],
    @[4,2,3]   
    ]
    let inputs3 = @[
    @[0.0,0.0],
    @[1.0,1.0],
    @[1.0,0.0],
    @[0.0,1.0],
    ]
    let dummies3=2
    let output3= @[3]
    var red=newRedNBN2(dummies3,config3, output3,func(x:float):float=1/(1+exp(-x)),func(x:float):float=(1/(1+exp(-x)))*(1-1/(1+exp(-x))))
    let pesos=makePesosRed(red)
    toFile("red.json",pesos)
#echo fromFile("red.json",proc(x:float):float=x,proc(x:float):float=x)

