#limpio la memoria
rm( list=ls() )  #remove all objects
gc()             #garbage collection

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
dataset  <- fread("./datasets/competencia2_2022.csv" )


# #creo la clase_binaria SI={ BAJA+1, BAJA+2 }    NO={ CONTINUA }
# dataset[ foto_mes==202101, 
#          clase_binaria :=  ifelse( clase_ternaria=="CONTINUA", "NO", "SI" ) ]

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

# Corrijo Data Drifting con las dos tarjetas, porque al sacar una del rpart claseMensual, aparece la otra

# corrijo manualmente el drifting de  Visa_fultimo_cierre
dataset[ Visa_fultimo_cierre== 1, Visa_fultimo_cierre :=  4 ]
dataset[ Visa_fultimo_cierre== 7, Visa_fultimo_cierre := 11 ]
dataset[ Visa_fultimo_cierre==21, Visa_fultimo_cierre := 25 ]
dataset[ Visa_fultimo_cierre==14, Visa_fultimo_cierre := 18 ]
dataset[ Visa_fultimo_cierre==28, Visa_fultimo_cierre := 32 ]
dataset[ Visa_fultimo_cierre==35, Visa_fultimo_cierre := 39 ]
dataset[ Visa_fultimo_cierre> 39, Visa_fultimo_cierre := Visa_fultimo_cierre + 4 ]

# corrijo manualmente el drifting de  Master_fultimo_cierre
dataset[ Master_fultimo_cierre== 1, Master_fultimo_cierre :=  4 ]
dataset[ Master_fultimo_cierre== 7, Master_fultimo_cierre := 11 ]
dataset[ Master_fultimo_cierre==21, Master_fultimo_cierre := 25 ]
dataset[ Master_fultimo_cierre==14, Master_fultimo_cierre := 18 ]
dataset[ Master_fultimo_cierre==28, Master_fultimo_cierre := 32 ]
dataset[ Master_fultimo_cierre==35, Master_fultimo_cierre := 39 ]
dataset[ Master_fultimo_cierre> 39, Master_fultimo_cierre := Master_fultimo_cierre + 4 ]

# Hago FE sobre mcomisiones, 3era vble en el rpart claseMensual después de eliminar las 1meras 2

dataset[, pcomisiones_mantenimiento := mcomisiones_mantenimiento/ccomisiones_mantenimiento]
dataset[, pcomisiones_otras := mcomisiones_otras/ccomisiones_otras]

# Pruebo si mcomisiones_mantenimiento + mcomisiones_otras = mcomisiones

dataset[, diferencia_comisiones := mcomisiones_mantenimiento + mcomisiones_otras - mcomisiones]
# No es igual siempre. La dejo en el df

# Escribo el dataset con FE
fwrite(dataset, "./datasets/competencia2_2022_fe_dd.csv.gz")