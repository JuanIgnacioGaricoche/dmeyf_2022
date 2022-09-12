#Aplicacion de los mejores hiperparametros encontrados en una bayesiana
#Utilizando clase_binaria =  [  SI = { "BAJA+1", "BAJA+2"} ,  NO="CONTINUA ]

#cargo las librerias que necesito
require("data.table")
require("rpart")
require("rpart.plot")


#Aqui se debe poner la carpeta de la materia de SU computadora local
# setwd("D:\\gdrive\\UBA2022\\")  #Establezco el Working Directory
setwd("C:/Users/jgaricoche/Desktop/Facultad/DMEyF_2022/repo")

#cargo el dataset
dataset  <- fread("./datasets/competencia1_2022.csv" )


#creo la clase_binaria SI={ BAJA+1, BAJA+2 }    NO={ CONTINUA }
dataset[ foto_mes==202101, 
         clase_binaria :=  ifelse( clase_ternaria=="CONTINUA", "NO", "SI" ) ]

# Hago FE con las vbles mas importantes
dataset[, "c_ctrx_quarter_mcuentas_saldo" := ctrx_quarter/mcuentas_saldo]
dataset[, "m_ctrx_quarter_mcuentas_saldo" := ctrx_quarter*mcuentas_saldo]
dataset[, "s_ctrx_quarter_mcuentas_saldo" := ctrx_quarter+mcuentas_saldo]
dataset[, "r_ctrx_quarter_mcuentas_saldo" := ctrx_quarter-mcuentas_saldo]

dataset[, "c_ctrx_quarter_cdescubierto_preacordado" := ctrx_quarter/cdescubierto_preacordado]
dataset[, "m_ctrx_quarter_cdescubierto_preacordado" := ctrx_quarter*cdescubierto_preacordado]
dataset[, "s_ctrx_quarter_cdescubierto_preacordado" := ctrx_quarter+cdescubierto_preacordado]
dataset[, "r_ctrx_quarter_cdescubierto_preacordado" := ctrx_quarter-cdescubierto_preacordado]

dataset[, "c_cdescubierto_preacordado_mcuentas_saldo" := cdescubierto_preacordado/mcuentas_saldo]
dataset[, "m_cdescubierto_preacordado_mcuentas_saldo" := cdescubierto_preacordado*mcuentas_saldo]
dataset[, "s_cdescubierto_preacordado_mcuentas_saldo" := cdescubierto_preacordado+mcuentas_saldo]
dataset[, "r_cdescubierto_preacordado_mcuentas_saldo" := cdescubierto_preacordado-mcuentas_saldo]

# Train y test
dtrain  <- dataset[ foto_mes==202101 ]  #defino donde voy a entrenar
dapply  <- dataset[ foto_mes==202103 ]  #defino donde voy a aplicar el modelo


# Entreno el modelo
# obviamente rpart no puede ve  clase_ternaria para predecir  clase_binaria
#  #no utilizo Visa_mpagado ni  mcomisiones_mantenimiento por drifting
# Elijo los hiperparametros que salieron de la OB

modelo  <- rpart(formula=   "clase_binaria ~ . -clase_ternaria",
                 data=      dtrain,  #los datos donde voy a entrenar
                 xval=         0,
                 cp=          -0.54,#  -0.89
                 minsplit=  1073,   # 621
                 minbucket=  278,   # 309
                 maxdepth=     9 )  #  12


#----------------------------------------------------------------------------
# habilitar esta seccion si el Fiscal General  Alejandro Bolaños  lo autoriza
#----------------------------------------------------------------------------

# Hago data Drifting solo con Master, porque fue la variable con mayor importancia al clasificar mensualmente

# corrijo manualmente el drifting de  Visa_fultimo_cierre
# dapply[ Visa_fultimo_cierre== 1, Visa_fultimo_cierre :=  4 ]
# dapply[ Visa_fultimo_cierre== 7, Visa_fultimo_cierre := 11 ]
# dapply[ Visa_fultimo_cierre==21, Visa_fultimo_cierre := 25 ]
# dapply[ Visa_fultimo_cierre==14, Visa_fultimo_cierre := 18 ]
# dapply[ Visa_fultimo_cierre==28, Visa_fultimo_cierre := 32 ]
# dapply[ Visa_fultimo_cierre==35, Visa_fultimo_cierre := 39 ]
# dapply[ Visa_fultimo_cierre> 39, Visa_fultimo_cierre := Visa_fultimo_cierre + 4 ]

# corrijo manualmente el drifting de  Master_fultimo_cierre
dapply[ Master_fultimo_cierre== 1, Master_fultimo_cierre :=  4 ]
dapply[ Master_fultimo_cierre== 7, Master_fultimo_cierre := 11 ]
dapply[ Master_fultimo_cierre==21, Master_fultimo_cierre := 25 ]
dapply[ Master_fultimo_cierre==14, Master_fultimo_cierre := 18 ]
dapply[ Master_fultimo_cierre==28, Master_fultimo_cierre := 32 ]
dapply[ Master_fultimo_cierre==35, Master_fultimo_cierre := 39 ]
dapply[ Master_fultimo_cierre> 39, Master_fultimo_cierre := Master_fultimo_cierre + 4 ]


#aplico el modelo a los datos nuevos
prediccion  <- predict( object=  modelo,
                        newdata= dapply,
                        type = "prob")

#prediccion es una matriz con DOS columnas, llamadas "NO", "SI"
#cada columna es el vector de probabilidades 

#agrego a dapply una columna nueva que es la probabilidad de BAJA+2
dfinal  <- copy( dapply[ , list(numero_de_cliente) ] )
dfinal[ , prob_SI := prediccion[ , "SI"] ]


# por favor cambiar por una semilla propia
# que sino el Fiscal General va a impugnar la prediccion
# set.seed(102191)  
set.seed(679909)

dfinal[ , azar := runif( nrow(dapply) ) ]

# ordeno en forma descentente, y cuando coincide la probabilidad, al azar
setorder( dfinal, -prob_SI, azar )


dir.create( "./exp/" )
dir.create( "./exp/1MERA_FINAL" )


for( corte  in  c( 7500, 8000, 8500, 9000, 9500, 10000, 10500, 11000 ) )
{
  #le envio a los  corte  mejores,  de mayor probabilidad de prob_SI
  dfinal[ , Predicted := 0L ]
  dfinal[ 1:corte , Predicted := 1L ]


  fwrite( dfinal[ , list(numero_de_cliente, Predicted) ], #solo los campos para Kaggle
           file= paste0( "./exp/1MERA_FINAL/1MERA_FINAL_005_",  corte, ".csv"),
           sep=  "," )
}
