
## **3. ESTIMACIÓN DE SUPERFICIES AFECTADAS POR TIPO DE BOSQUE**

### **3a. Importar las librerías e inputs necesarios**

En esta sección se utilizará la [Clasificación de Tipos Forestales y
Cobertura del Suelo de la Región Bosque Andino Patagónico (CIEFAP, MAyDS
2016)](https://www.argentina.gob.ar/sites/default/files/informe_final_ccs_bap_20160712.pdf),
Nivel 2 de la Leyenda. También se utilizará el archivo raster
correspondiente al dNBR generado en las secciones anteriores.

Indicar el **directorio local** donde se encuentran ambos archivos:

``` r
dir_ciefap <-"_gis_shapes/clasif_ciefap_incendio.shp"
dir_nbr_class <- "_gis_rasters/nbr_class_USGS.tiff"
```

*Observación: en este caso la cobertura vectorial del Tipos Forestales
ya fue recortada al área del incendio.*

Se utilizarán también 3 **funciones generadas específicamente** para
extraer las superficies afectadas para cada tipo forestal y luego
graficar.

Las 3 funciones, `shapeUSGSxTipoFtal`, `supUSGSxTipoFtal` y `plotUSGS`
se encuentran en el repositorio.

``` r
# Llamar a las funciones
source("_r_functions/USGSxTipoFtal_funciones.R")
```

Finalmente, cargar las **librerías** necesarias:

``` r
library(terra)
library(sf)
library(dplyr)
library(raster)
```

### **3b. Bosques de Ciprés**

``` r
# Definir el tipo forestal
x <- "Ci"
```

``` r
# Aplicar la función que extrae los polígonos de Coihue
Ci <- shapeUSGSxTipoFtal(x)
# Función para calcular la superficie por clase de severidad
supUSGSxTipoFtal(Ci)
```

    ##   N_Cat                Categoria Tipo_ftal      Sup_ha Percentage
    ## 1     2 2-Enhanced Regrowth, Low        Ci   0.17 [ha]   0.03 [1]
    ## 2     3               3-Unburned        Ci  19.11 [ha]   2.93 [1]
    ## 3     4           4-Low Severity        Ci 105.63 [ha]  16.20 [1]
    ## 4     5  5-Moderate-low Severity        Ci  98.69 [ha]  15.14 [1]
    ## 5     6 6-Moderate-high Severity        Ci  96.48 [ha]  14.80 [1]
    ## 6     7          7-High Severity        Ci 331.78 [ha]  50.90 [1]

``` r
# Graficar
plotUSGS(Ci)
```

<img src="https://github.com/romina-gonzalez-musso/Severidad_IncendioLagoMartin/blob/master/_images/3_Ci.png?raw=true" width="90%" />

### **3c. Bosques de Coihue**

``` r
# Definir el tipo forestal
x <- "Co"
```

``` r
# Aplicar la función que extrae los polígonos de Coihue
Co <- shapeUSGSxTipoFtal(x)
# Función para calcular la superficie por clase de severidad
supUSGSxTipoFtal(Co)
```

    ##   N_Cat                 Categoria Tipo_ftal      Sup_ha Percentage
    ## 1     1 1-Enhanced Regrowth, High        Co   0.25 [ha]   0.02 [1]
    ## 2     2  2-Enhanced Regrowth, Low        Co   0.69 [ha]   0.05 [1]
    ## 3     3                3-Unburned        Co  71.91 [ha]   5.02 [1]
    ## 4     4            4-Low Severity        Co 353.77 [ha]  24.68 [1]
    ## 5     5   5-Moderate-low Severity        Co 401.36 [ha]  28.00 [1]
    ## 6     6  6-Moderate-high Severity        Co 267.55 [ha]  18.67 [1]
    ## 7     7           7-High Severity        Co 337.66 [ha]  23.56 [1]

``` r
# Graficar
plotUSGS(Co)
```

<img src="https://github.com/romina-gonzalez-musso/Severidad_IncendioLagoMartin/blob/master/_images/3_Co.png?raw=true" width="90%" />

### **3d. Bosques Mixtos**

``` r
# Definir el tipo forestal
x <- "Mx"
```

``` r
# Aplicar la función que extrae los polígonos de Coihue
Mx <- shapeUSGSxTipoFtal(x)
# Función para calcular la superficie por clase de severidad
supUSGSxTipoFtal(Mx)
```

    ##   N_Cat                 Categoria Tipo_ftal      Sup_ha Percentage
    ## 1     1 1-Enhanced Regrowth, High        Mx   0.32 [ha]   0.01 [1]
    ## 2     2  2-Enhanced Regrowth, Low        Mx   0.96 [ha]   0.04 [1]
    ## 3     3                3-Unburned        Mx 116.77 [ha]   4.64 [1]
    ## 4     4            4-Low Severity        Mx 577.49 [ha]  22.95 [1]
    ## 5     5   5-Moderate-low Severity        Mx 640.77 [ha]  25.46 [1]
    ## 6     6  6-Moderate-high Severity        Mx 475.21 [ha]  18.88 [1]
    ## 7     7           7-High Severity        Mx 705.20 [ha]  28.02 [1]

``` r
# Graficar
plotUSGS(Mx)
```

<img src="https://github.com/romina-gonzalez-musso/Severidad_IncendioLagoMartin/blob/master/_images/3_Mx.png?raw=true" width="90%" />

### **3e. Bosques de Lenga**

``` r
# Definir el tipo forestal
x <- "Le"
```

``` r
# Aplicar la función que extrae los polígonos de Coihue
Le <- shapeUSGSxTipoFtal(x)
# Función para calcular la superficie por clase de severidad
supUSGSxTipoFtal(Le)
```

    ##   N_Cat                 Categoria Tipo_ftal      Sup_ha Percentage
    ## 1     1 1-Enhanced Regrowth, High        Le   0.20 [ha]   0.02 [1]
    ## 2     2  2-Enhanced Regrowth, Low        Le   1.13 [ha]   0.09 [1]
    ## 3     3                3-Unburned        Le  61.65 [ha]   5.06 [1]
    ## 4     4            4-Low Severity        Le 166.25 [ha]  13.65 [1]
    ## 5     5   5-Moderate-low Severity        Le 225.66 [ha]  18.53 [1]
    ## 6     6  6-Moderate-high Severity        Le 327.95 [ha]  26.92 [1]
    ## 7     7           7-High Severity        Le 435.20 [ha]  35.73 [1]

``` r
# Graficar
plotUSGS(Le)
```

<img src="https://github.com/romina-gonzalez-musso/Severidad_IncendioLagoMartin/blob/master/_images/3_Le.png?raw=true" width="90%" />

### **3f. Bosques de Ñire**

``` r
# Definir el tipo forestal
x <- "Ñi"
```

``` r
# Aplicar la función que extrae los polígonos de Coihue
Ni <- shapeUSGSxTipoFtal(x)
# Función para calcular la superficie por clase de severidad
supUSGSxTipoFtal(Ni)
```

    ##   N_Cat                 Categoria Tipo_ftal      Sup_ha Percentage
    ## 1     1 1-Enhanced Regrowth, High        Ñi   0.10 [ha]   0.01 [1]
    ## 2     2  2-Enhanced Regrowth, Low        Ñi   0.61 [ha]   0.05 [1]
    ## 3     3                3-Unburned        Ñi  15.08 [ha]   1.23 [1]
    ## 4     4            4-Low Severity        Ñi  40.46 [ha]   3.29 [1]
    ## 5     5   5-Moderate-low Severity        Ñi  58.36 [ha]   4.75 [1]
    ## 6     6  6-Moderate-high Severity        Ñi 132.83 [ha]  10.80 [1]
    ## 7     7           7-High Severity        Ñi 982.39 [ha]  79.88 [1]

``` r
# Graficar
plotUSGS(Ni)
```

<img src="https://github.com/romina-gonzalez-musso/Severidad_IncendioLagoMartin/blob/master/_images/3_Ni.png?raw=true" width="90%" />

### **3g. Arbustales nativos**

``` r
# Definir el tipo forestal
x <- "Arbu Na"
```

``` r
# Aplicar la función que extrae los polígonos de Coihue
Arb <- shapeUSGSxTipoFtal(x)
# Función para calcular la superficie por clase de severidad
supUSGSxTipoFtal(Arb)
```

    ##   N_Cat                 Categoria Tipo_ftal      Sup_ha Percentage
    ## 1     1 1-Enhanced Regrowth, High   Arbu Na   0.07 [ha]   0.04 [1]
    ## 2     2  2-Enhanced Regrowth, Low   Arbu Na   0.27 [ha]   0.14 [1]
    ## 3     3                3-Unburned   Arbu Na   3.76 [ha]   1.93 [1]
    ## 4     4            4-Low Severity   Arbu Na   9.89 [ha]   5.06 [1]
    ## 5     5   5-Moderate-low Severity   Arbu Na  16.21 [ha]   8.29 [1]
    ## 6     6  6-Moderate-high Severity   Arbu Na  35.88 [ha]  18.36 [1]
    ## 7     7           7-High Severity   Arbu Na 129.31 [ha]  66.18 [1]

``` r
# Graficar
plotUSGS(Arb)
```

<img src="https://github.com/romina-gonzalez-musso/Severidad_IncendioLagoMartin/blob/master/_images/3_ArbuNa.png?raw=true" width="90%" />
