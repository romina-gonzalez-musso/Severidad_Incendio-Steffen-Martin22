
## **2. ESTIMACIÓN DE SUPERFICIES AFECTADAS POR CATEGORÍA DE SEVERIDAD**

En esta sección se priorizará el uso de la librería `terra` para la
manipulación y análisis de datos espaciales, aunque también se
utilizarán las librería `sf` y `raster` para algunas funciones
específicas. En la manipulación de tablas y datos en general se
trabajará con `dplyr`.

``` r
library("terra")
library("sf")
library("dplyr")
library("raster")
```

### **2a. Obtener el perímetro del incendio**

En primer lugar se importará el **archivo raster dNBR** que fue generado
con en la sección anterior `rgee`. Se asume que luego de exportado a
Google Drive, fue descargado a un directorio en la PC local.

``` r
# Importar el raster (SRC POSGAR FAJA 1)
nbr_f1 <- rast("_gis_rasters/dNBR_scaled_masked_f1.tif") 
```

Para obtener el perímetro, primero hay que definir un **umbral de
clasificación de píxeles quemados vs. píxeles no quemados**. En este
caso se utilizó 100 en concordancia con el corte establecido por las
categorías propuestas por USGS.

``` r
# Definir umbral de corte entre área quemada
umbral <- 100

# Clasificar área quemada vs. no quemada
burnedArea_rast <- classify(nbr_f1, cbind(-Inf, umbral, NA))        # Valores entre -Inf y el umbral = NA
burnedArea_rast <- classify(burnedArea_rast, cbind(umbral, Inf, 1)) # Valores mayores al umbral = Quemados
```

``` r
# Plot
par(mfrow=c(1,2))    
plot(nbr_f1, main = "NBR", col = grey.colors(15), legend = FALSE)
plot(burnedArea_rast, main = "Área quemada", legend = FALSE, col = "red")
```

<img src="https://github.com/romina-gonzalez-musso/Severidad_Incendio-Steffen-Martin22/blob/master/_images/2_NBRvsAreaQuemada.png?raw=true" width="90%" />

Se observa que quedan píxeles aislados clasificados como área quemada. A
continuación se realizarán una serie de pasos a fin de **filtrar y
obtener el perímetro final.**

Primero, el raster clasificado se poligoniza.

``` r
burnedArea_vect <- burnedArea_rast %>%
  as.polygons(.) %>%    # Del paquete terra
  st_as_sf(.) %>%       # Convertir a SF
  st_cast(.,"POLYGON")  # Multipolygon a Simpleparts
```

Se seleccionan los polígonos de mayor tamaño que representarán la mayor
parte del área del incendio. En este caso, son dos polígonos.

``` r
burnedArea_vect_max <- burnedArea_vect %>%
  mutate(area = st_area(burnedArea_vect)) %>% 
  slice_max(area, n = 2) # Seleccionar los dos polígonos de mayor tamaño
```

Ahora se generará un **buffer** alrededor del estos dos polígonos
principales, a fin de poder incluir como parte de la superficie quemada
los polígonos más chicos.

``` r
par(mfrow=c(1,1))
buffer <- buffer(vect(burnedArea_vect_max), 600) #600 metros de buffer. Puede variar. 
```

``` r
# Graficar
plot(burnedArea_rast, legend = FALSE)
plot(buffer, add = TRUE)
```

<img src="https://github.com/romina-gonzalez-musso/Severidad_Incendio-Steffen-Martin22/blob/master/_images/2_buffer.png?raw=true" width="90%" />

Se seleccionarán todos los polígonos incluidos en el área buffer que
corresponden a píxeles quemados.

``` r
# Seleccionar todos los polígonos (píxeles) quemados del área buffer de incendio
perimeter_f1 <- terra::mask(burnedArea_rast, buffer) %>%
  terra::crop(., buffer) %>%
  as.polygons(.) %>%
  st_as_sf(.) %>%    
  st_cast(.,"POLYGON") 

# Calcular la superficie de cada polígono
perimeter_f1 <- perimeter_f1 %>%  
  mutate(area = st_area(perimeter_f1))
```

Finalmente, se eliminarán los píxeles más pequeños que aún siguen
generando ruido.

``` r
# Eliminar polígonos sueltos (ruido) < a 10.000m2 area
perimeter_f1$sup <- as.numeric(perimeter_f1$area)
perimeter_f1 <- subset(perimeter_f1, sup > 10000)
```

Se grafica para verificar los resultados:

``` r
# Graficar
par(mfrow=c(1,1))
plot(nbr_f1, col = grey.colors(10), legend = FALSE)
plot(perimeter_f1$geometry, col = (col=rgb(1, 0, 0, 0.2)), add = TRUE)
```

<img src="https://github.com/romina-gonzalez-musso/Severidad_Incendio-Steffen-Martin22/blob/master/_images/2_Perimetro_poligono_incendio.png?raw=true" width="90%" />

Se puede **exportar el polígono** en formato shape para trabajar en
forma local.

``` r
writeVector(vect(perimeter_f1), "poligono_incendio_f1.shp")
```

### **2b. Cálculo de la superficie total del incendio**

``` r
as.numeric(sum(perimeter_f1$area)/10000)
```

    ## [1] "La superficie estimada del incendio es de 7860.36 hectáreas."

### **2c. Clasificar el raster dNBR por clases de severidad USGS**

Primero se recorta el área del incendio con `mask`y `crop` del paquete
`terra`:

``` r
nbr_f1_crop <- terra::mask(nbr_f1, vect(perimeter_f1)) %>%
                  terra::crop(., vect(perimeter_f1))
```

``` r
plot(nbr_f1_crop, main = "dNBR recortado al área incendio", legend = FALSE) 
```

<img src="https://github.com/romina-gonzalez-musso/Severidad_Incendio-Steffen-Martin22/blob/master/_images/2_dNBR_croped.png?raw=true" width="90%" />

Luego se establecen los rangos de clasificación del raster en función a
las categorías USGS y la paleta de colores:

<img src="https://github.com/romina-gonzalez-musso/Severidad_Incendio-Steffen-Martin22/blob/master/_images/1_classes.png?raw=true" width="100%" />

``` r
# Rangos de clasificación de Severidad USGS
NBR_ranges <- c(-Inf, -500, -1,  # NA
                -500, -251, 1,   # 1 - Enhanced Regrowth, High
                -251, -101, 2,   # 2 - Enhanced Regrowth, Low
                -101, 99, 3,     # 3 - Unburned
                99, 269, 4,      # 4 - Low Severity
                269, 439, 5,     # 5 - Moderate-low Severity
                439, 659, 6,     # 6 - Moderate-high Severity
                659, 1300, 7,    # 7 - High Severity
                1300, +Inf, -1)  # NA

# Matriz de clasificación
class.matrix <- matrix(NBR_ranges, ncol = 3, byrow = TRUE)

# Definir paleta de colores
my_col=c("#ffffff",      # -1 NA Values
          "#7a8737",      # 1 - Enhanced Regrowth, High
          "#acbe4d",      # 2 - Enhanced Regrowth, Low
          "#0ae042",      # 3 - Unburned
          "#fff70b",      # 4 - Low Severity
          "#ffaf38",      # 5 - Moderate-low Severity
          "#ff641b",      # 6 - Moderate-high Severity
          "#a41fd6")      # 7 - High Severity
```

Se clasifica el raster dNBR en categorías y luego se grafica:

``` r
nbr_class <- classify(nbr_f1_crop, class.matrix, right=NA)
```

``` r
plot(nbr_f1_crop, col = grey.colors(10), legend = FALSE, main = "Severidad - Rangos USGS")
plot(nbr_class, col = my_col, add = TRUE, legend = FALSE)
```

<img src="https://github.com/romina-gonzalez-musso/Severidad_Incendio-Steffen-Martin22/blob/master/_images/2_Severidad.png?raw=true" width="90%" />

Se puede construir una *Tabla de Atributos Raster* (RAT, por sus siglas
en inglés) para mejor representación de los resultados.

``` r
# Armar la legenda con las clases USGS
nbr_class <- ratify(raster(nbr_class))
rat <- levels(nbr_class)[[1]]

# Ponerle texto a cada categoría del -1 al 7
rat$legend  <- c("NA", "1-Enhanced Regrowth, High", 
                 "2-Enhanced Regrowth, Low", "3-Unburned", 
                 "4-Low Severity", "5-Moderate-low Severity", 
                 "6-Moderate-high Severity", "7-High Severity") 

levels(nbr_class) <- rat
```

``` r
par(mar =  c(4, 2, 4, 8) + 0.1)
plot(nbr_class, col=my_col, legend=F,
     main = "Clases de severidad USGS") 
legend("right", inset = c(-0.55,0), legend =rat$legend, xpd = TRUE, 
       horiz = FALSE, fill = my_col, cex = 0.75)
```

<img src="https://github.com/romina-gonzalez-musso/Severidad_Incendio-Steffen-Martin22/blob/master/_images/2_Severidad_clases.png?raw=true" width="90%" />

Se puede **exportar el raster clasificado** en formato `.tiff` para
trabajar en forma local.

``` r
nbr_class <- rast(nbr_class) # Pasar a Terra
writeRaster(nbr_class, "_gis_rasters/nbr_class_USGS_f1.tiff")
```

### **2d. Cálculo de superficies por clases de severidad USGS**

Los pasos para generar la tabla de superficies por clases de severidad
son:

-   Poligonizar la clasificación
-   Eliminar (si fuese necesario) las categorías de *“No quemado”* que
    pudieran quedar dentro del área del incendio.
-   Calcular la superficie por categoría
-   Armar la tabla de superficies

``` r
# Poligonizar la clasificación
nbr_class <- rast(nbr_class) # Pasar a objeto Terra si no se hizo antes
class_usgs <- nbr_class %>%
  as.polygons(.) %>%    # Del paquete terra
  st_as_sf(.) %>%       # Convertir a SF
  st_cast(.,"POLYGON")  # Multipolygon a Simpleparts

# Eliminar categorías de "no quemado"
class_usgs <- subset(class_usgs, class_usgs$nd != "1-Enhanced Regrowth, High" & 
                       class_usgs$nd != "2-Enhanced Regrowth, Low" & 
                       class_usgs$nd != "3-Unburned")

# Calcular superficie por categoría
class_usgs_f1 <-  st_transform(class_usgs, crs = 22181) # POSGAR F1

# Agregar la columna de superficie en m2
class_usgs_f1 <- class_usgs_f1 %>% 
  mutate(area_m2 = st_area(class_usgs_f1))

# Agregar columna de superficie en ha
class_usgs_f1$area_ha <- units::set_units(class_usgs_f1$area, ha)
```

Se puede chequear que el área del polígono de incendio obtenido en el
paso *2b* es igual a la suma de las categorías estimadas en este paso.
Puede haber pequeñas diferencias producto de la eliminación de píxeles
“no quemados” y las conversiones de formatos (raster a vectorial)

``` r
## Superficie total incendio obtenida del polígono vectorial
as.numeric(sum(perimeter_f1$area)/10000)
## Superficie total incendio obtenida de la clasificación USGS 
sum(class_usgs_f1$area_ha)
```

    ## [1] "Superficie estimada del incendio con el polígono vectorial es de 7860.4 ha."

    ## [1] "La superficie de estimada a partir de la sumatoria de clases de severidad es de 7869.3ha"

### **2e. Tabla de superficies por clases de severidad USGS**

Se construye una tabla que contiene la superficie total por clase de
severidad en unidades absolutas (hectáras) y en porcentaje.

``` r
Sups <- aggregate(class_usgs_f1$area_ha, list(class_usgs_f1$nd), FUN=sum) 
colnames(Sups) <- c("Categoría", "Sup_ha")

Sups <- Sups %>% 
  mutate(Percentage = Sup_ha/sum(Sup_ha)*100) %>% 
  mutate_if(is.numeric, ~round(., 2))
```

    ##                  Categoría       Sup_ha Percentage
    ## 1           4-Low Severity 1399.72 [ha]  17.79 [1]
    ## 2  5-Moderate-low Severity 1541.44 [ha]  19.59 [1]
    ## 3 6-Moderate-high Severity 1414.24 [ha]  17.97 [1]
    ## 4          7-High Severity 3513.88 [ha]  44.65 [1]
