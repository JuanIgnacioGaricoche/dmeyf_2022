# -*- coding: utf-8 -*-
"""
Created on Wed Nov 30 00:21:35 2022

@author: jgaricoche
"""

#%% Librerias

import pandas as pd
import os
import numpy as np
# import sys

#%% Df_semilla

# Agarro una semilla cualquiera para tomar los numero_de_cliente
df_semillero = pd.read_csv('C:/Users/jgaricoche/Downloads/entrega_final/m10/exp_FCZZ9410_semillerio_ensamble_m10_FCZZ9410_semillerio_ensamble_m10_M10_S1_S13_105367_resultados.csv') 

df_semillero_orig = df_semillero[['numero_de_cliente']]

#%% Modelos

# Itero por cada semilla, obteniendo el vector de probabilidades
# Guardo en 4 dfs distintos, uno por cada modelo

directory_in_str = 'C:/Users/jgaricoche/Downloads/entrega_final/'
directory = os.fsencode(directory_in_str)

for modelo in os.listdir(directory):

     df_semillero = df_semillero_orig.copy()
     filename = os.fsdecode(modelo)
     model = filename
     model_directory_in_str = str(os.path.join(directory_in_str, filename)+'/')
     
     model_directory = os.fsencode(model_directory_in_str)
     
     for semilla in os.listdir(model_directory):
          filename = os.fsdecode(semilla)
          if filename.endswith(".csv"):
              directorio_completo = os.path.join(model_directory_in_str, filename)

              df_semilla = pd.read_csv(directorio_completo)
              df_semilla = df_semilla[['numero_de_cliente','prob']]
              df_semillero = pd.merge(df_semillero, df_semilla, how='inner', left_on='numero_de_cliente', right_on='numero_de_cliente')

     globals()['df_'+model] = df_semillero

#%% Promedio semillas en cada modelo

df_m1 = globals()['df_m1']
df_m2 = globals()['df_m2']
df_m6 = globals()['df_m6']
df_m10 = globals()['df_m10']

df_m1['avg_prob'] = df_m1.iloc[:,1:39].mean(axis=1)
df_m1 = df_m1[['numero_de_cliente','avg_prob']]

df_m2['avg_prob'] = df_m2.iloc[:,1:41].mean(axis=1)
df_m2 = df_m2[['numero_de_cliente','avg_prob']]

df_m6['avg_prob'] = df_m6.iloc[:,1:41].mean(axis=1)
df_m6 = df_m6[['numero_de_cliente','avg_prob']]

df_m10['avg_prob'] = df_m10.iloc[:,1:41].mean(axis=1)
df_m10 = df_m10[['numero_de_cliente','avg_prob']]

#%% Modelo final

# Promedio modelos

modelo_final = pd.merge(df_m1, df_m2, how='inner', left_on='numero_de_cliente', right_on='numero_de_cliente')
modelo_final = pd.merge(modelo_final, df_m6, how='inner', left_on='numero_de_cliente', right_on='numero_de_cliente')
modelo_final = pd.merge(modelo_final, df_m10, how='inner', left_on='numero_de_cliente', right_on='numero_de_cliente')

modelo_final['prob_final'] = modelo_final.iloc[:,1:6].mean(axis=1)
modelo_final = modelo_final[['numero_de_cliente','prob_final']]

#%% Corte 10500

# Ordeno
modelo_final_10500 = modelo_final.sort_values(by='prob_final', ascending=False)

# Creo indice
modelo_final_10500.insert(0, 'orden', range(0, 164935))

modelo_final_10500['Predicted'] = np.where(modelo_final_10500['orden']<=10500, 1, 0)

modelo_final_10500 = modelo_final_10500[['numero_de_cliente','Predicted']]

#%% Subo a dire local

modelo_final_10500.to_csv('C:/Users/jgaricoche/Downloads/entrega_final/semillerio_ensamble_10500.csv', index=False)
