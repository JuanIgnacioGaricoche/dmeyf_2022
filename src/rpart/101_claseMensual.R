#limpio la memoria
rm( list=ls() )  #remove all objects
gc()             #garbage collection

#cargo las librerias que necesito
require("data.table")
require("rpart")
require("rpart.plot")
require("dplyr")

#Aqui se debe poner la carpeta de la materia de SU computadora local
# setwd("D:\\gdrive\\UBA2022\\")  #Establezco el Working Directory
setwd("C:/Users/jgaricoche/Desktop/Facultad/DMEyF_2022/repo")

#cargo el dataset
dataset  <- fread("./datasets/competencia2_2022_fe_dd.csv.gz" )

# muestra <- dataset[1:5,]

dataset <- dataset %>% mutate(clase_mensual = case_when(foto_mes==202101 ~ 'ENERO',
                                                       foto_mes==202102 ~ 'FEBRERO',
                                                       foto_mes==202103 ~ 'MARZO',
                                                       foto_mes==202104 ~ 'ABRIL',
                                                       foto_mes==202105 ~ 'MAYO'))

dtrain <- dataset %>% select(-c(foto_mes, clase_ternaria))

#genero el modelo,  aqui se construye el arbol
# modelo  <- rpart(formula=   "clase_binaria ~ .-clase_ternaria",  #quiero predecir clase_ternaria a partir de el resto de las variables
modelo  <- rpart(formula=   "clase_mensual ~ .",  #quiero predecir clase_ternaria a partir de el resto de las variables                 
                 data=      dtrain,  #los datos donde voy a entrenar
                 xval=      0,
                 cp=       -1,   #esto significa no limitar la complejidad de los splits
                 minsplit=  800,     #minima cantidad de registros para que se haga el split
                 minbucket= 40,     #tamaño minimo de una hoja
                 maxdepth=  8 )    #profundidad maxima del arbol


#grafico el arbol
prp(modelo, extra=101, digits=5, branch=1, type=4, varlen=0, faclen=0)

# Analizo el data drifting en mcomisiones

mean(dtrain[clase_mensual=='ENERO', mcomisiones])
mean(dtrain[clase_mensual=='FEBRERO', mcomisiones])
mean(dtrain[clase_mensual=='MARZO', mcomisiones])
mean(dtrain[clase_mensual=='ABRIL', mcomisiones])
mean(dtrain[clase_mensual=='MAYO', mcomisiones])


median(dtrain[clase_mensual=='ENERO', mcomisiones])
median(dtrain[clase_mensual=='FEBRERO', mcomisiones])
median(dtrain[clase_mensual=='MARZO', mcomisiones])
median(dtrain[clase_mensual=='ABRIL', mcomisiones])
median(dtrain[clase_mensual=='MAYO', mcomisiones])

unique(dtrain[clase_mensual=='ENERO', ccomisiones_mantenimiento])
unique(dtrain[clase_mensual=='FEBRERO', ccomisiones_mantenimiento])
unique(dtrain[clase_mensual=='MARZO', ccomisiones_mantenimiento])
unique(dtrain[clase_mensual=='ABRIL', ccomisiones_mantenimiento])
unique(dtrain[clase_mensual=='MAYO', ccomisiones_mantenimiento])
