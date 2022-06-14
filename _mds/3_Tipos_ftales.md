
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
dir_nbr_class <- "_gis_rasters/nbr_class_USGS_f1.tiff"
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
    ## 1     2 2-Enhanced Regrowth, Low        Ci   0.04 [ha]   0.01 [1]
    ## 2     3               3-Unburned        Ci  21.08 [ha]   3.10 [1]
    ## 3     4           4-Low Severity        Ci 111.84 [ha]  16.46 [1]
    ## 4     5  5-Moderate-low Severity        Ci 105.88 [ha]  15.58 [1]
    ## 5     6 6-Moderate-high Severity        Ci  98.92 [ha]  14.56 [1]
    ## 6     7          7-High Severity        Ci 341.80 [ha]  50.30 [1]

``` r
# Graficar
plotUSGS(Ci)
```

<img src="https://github.com/romina-gonzalez-musso/Severidad_Incendio-Steffen-Martin22/blob/master/_images/3_Ci_2.png?raw=true" width="90%" />

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
    ## 1     1 1-Enhanced Regrowth, High        Co   0.32 [ha]   0.02 [1]
    ## 2     2  2-Enhanced Regrowth, Low        Co   0.68 [ha]   0.05 [1]
    ## 3     3                3-Unburned        Co  82.48 [ha]   5.54 [1]
    ## 4     4            4-Low Severity        Co 369.76 [ha]  24.83 [1]
    ## 5     5   5-Moderate-low Severity        Co 425.36 [ha]  28.56 [1]
    ## 6     6  6-Moderate-high Severity        Co 272.44 [ha]  18.29 [1]
    ## 7     7           7-High Severity        Co 338.12 [ha]  22.71 [1]

``` r
# Graficar
plotUSGS(Co)
```

<img src="https://github.com/romina-gonzalez-musso/Severidad_Incendio-Steffen-Martin22/blob/master/_images/3_Co_2.png?raw=true" width="90%" />

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
    ## 1     1 1-Enhanced Regrowth, High        Mx   0.24 [ha]   0.01 [1]
    ## 2     2  2-Enhanced Regrowth, Low        Mx   0.56 [ha]   0.02 [1]
    ## 3     3                3-Unburned        Mx 113.96 [ha]   4.43 [1]
    ## 4     4            4-Low Severity        Mx 606.76 [ha]  23.58 [1]
    ## 5     5   5-Moderate-low Severity        Mx 682.16 [ha]  26.51 [1]
    ## 6     6  6-Moderate-high Severity        Mx 465.72 [ha]  18.10 [1]
    ## 7     7           7-High Severity        Mx 703.36 [ha]  27.34 [1]

``` r
# Graficar
plotUSGS(Mx)
```

<img src="https://github.com/romina-gonzalez-musso/Severidad_Incendio-Steffen-Martin22/blob/master/_images/3_Mx_2.png?raw=true" width="90%" />

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

    ##   N_Cat                Categoria Tipo_ftal      Sup_ha Percentage
    ## 1     2 2-Enhanced Regrowth, Low        Le   0.96 [ha]   0.08 [1]
    ## 2     3               3-Unburned        Le  68.32 [ha]   5.47 [1]
    ## 3     4           4-Low Severity        Le 169.68 [ha]  13.57 [1]
    ## 4     5  5-Moderate-low Severity        Le 244.60 [ha]  19.57 [1]
    ## 5     6 6-Moderate-high Severity        Le 337.20 [ha]  26.98 [1]
    ## 6     7          7-High Severity        Le 429.24 [ha]  34.34 [1]

``` r
# Graficar
plotUSGS(Le)
```

<img src="https://github.com/romina-gonzalez-musso/Severidad_Incendio-Steffen-Martin22/blob/master/_images/3_Le_2.png?raw=true" width="90%" />

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

    ##   N_Cat                 Categoria Tipo_ftal       Sup_ha Percentage
    ## 1     1 1-Enhanced Regrowth, High        Ñi    0.04 [ha]   0.00 [1]
    ## 2     2  2-Enhanced Regrowth, Low        Ñi    0.20 [ha]   0.02 [1]
    ## 3     3                3-Unburned        Ñi   17.84 [ha]   1.41 [1]
    ## 4     4            4-Low Severity        Ñi   41.48 [ha]   3.27 [1]
    ## 5     5   5-Moderate-low Severity        Ñi   61.84 [ha]   4.88 [1]
    ## 6     6  6-Moderate-high Severity        Ñi  141.00 [ha]  11.13 [1]
    ## 7     7           7-High Severity        Ñi 1004.56 [ha]  79.29 [1]

``` r
# Graficar
plotUSGS(Ni)
```

<img src="https://github.com/romina-gonzalez-musso/Severidad_Incendio-Steffen-Martin22/blob/master/_images/3_Ni_2.png?raw=true" width="90%" />

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

    ##   N_Cat                Categoria Tipo_ftal      Sup_ha Percentage
    ## 1     2 2-Enhanced Regrowth, Low   Arbu Na   0.28 [ha]   0.14 [1]
    ## 2     3               3-Unburned   Arbu Na   4.00 [ha]   1.95 [1]
    ## 3     4           4-Low Severity   Arbu Na   9.52 [ha]   4.63 [1]
    ## 4     5  5-Moderate-low Severity   Arbu Na  17.68 [ha]   8.60 [1]
    ## 5     6 6-Moderate-high Severity   Arbu Na  38.36 [ha]  18.67 [1]
    ## 6     7          7-High Severity   Arbu Na 135.64 [ha]  66.01 [1]

``` r
# Graficar
plotUSGS(Arb)
```

<img src="https://github.com/romina-gonzalez-musso/Severidad_Incendio-Steffen-Martin22/blob/master/_images/3_ArbuNa_2.png?raw=true" width="90%" />
