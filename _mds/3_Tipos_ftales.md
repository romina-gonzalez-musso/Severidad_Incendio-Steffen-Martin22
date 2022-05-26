
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

### **3b. Bosques de Coihue**

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
