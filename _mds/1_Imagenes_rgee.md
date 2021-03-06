
## **1. BÚSQUEDA Y DESCARGA DE IMÁGENES**

### **1a. Instalar rgee**

<img src="https://github.com/romina-gonzalez-musso/Severidad_Incendio-Steffen-Martin22/blob/master/_images/1_Rgee_logo.png?raw=true" width="12%" />

**rgee** es una librería que permite llamar a la API de Google Earth
Entine usando R (Aybar et al. 2020).

El paquete se instala en R como cualquier otro paquete ejecutando
`install.packages(rgee)`. Luego es necesario configurar por única vez el
entorno de trabajo e indicar las credenciales de acceso a la cuenta de
Google Earth Engine (GEE) del usuario. Para esto, es necesario ejecutar
`rgee::ee_install()` y seguir las indicaciones. La guía detallada de
instalación de rgee se puede leer en la [página oficial del
desarrollo](https://github.com/r-spatial/rgee).

Una vez instalada, cargamos la librería rgee e iniciamos la API de GEE:

``` r
library("rgee")
ee_Initialize()
```

### **1b. Indicar área de estudio y fechas de interés**

Una forma de indicar el **área de estudio** para la búsqueda de imágenes
en GEE es usando un shape propio. Para eso usamos la librería `sf` y se
debe indicar dónde se encuentra el archivo shape en nuestro sistema.

``` r
library("sf")
shape <- st_read("_gis_shapes/area_incendio.shp")
```

Usando `leflet`, desplegamos el shape para visualizar:

``` r
library("leaflet")
leaflet(shape) %>%
  addTiles() %>% 
  addPolygons(color = "red", weight = 1, opacity = 1.0)
```

<img src="https://github.com/romina-gonzalez-musso/Severidad_Incendio-Steffen-Martin22/blob/master/_images/1_Area.png?raw=true" width="50%" />

Para ejecutar la búsqueda de imágenes, se debe convertir el objeto `sf`
a objeto `rgee`:

``` r
shape_ee <- sf_as_ee(shape$geometry)
```

Ahora hay que definir las **fechas** de interés.

Para este caso ya se habían elegido dos imágenes Sentinel 2 libre de
nubes usando la plataforma [Sentinel Hub](https://www.sentinel-hub.com/)
como visor externo (ver Informe STAN, sección “Métodos”). Por lo tanto,
para dirigir la búsqueda a las imágenes deseadas se acota el rango de
fechas para que obtener únicamente la imagen del día de interés.

``` r
pre_fire <- c('2021-12-05', '2021-12-07')    # Fecha de interés: 6/12/21
post_fire <- c('2022-03-10', '2022-03-12')   # Fecha de interés: 11/03/22
```

### **1c. Traer la colección de imágenes de GEE (ImageCollection)**

Traemos la colección de imágenes [Sentinel 2 de
GEE](https://developers.google.com/earth-engine/datasets/catalog/COPERNICUS_S2_SR_HARMONIZED)
y la filtramos por las fechas y el área de estudio.

``` r
# Traer la colección de imágenes
Imcol <- ee$ImageCollection('COPERNICUS/S2_SR_HARMONIZED')

# PRE INCENDIO
PostImcol <- Imcol$
  filterDate(post_fire[1], post_fire[2])$
  filterBounds(shape_ee)

# POST INCENDIO
PreImcol <- Imcol$
  filterDate(pre_fire[1],pre_fire[2])$
  filterBounds(shape_ee)
```

Verificamos que al acotar el rango de fechas únicamente a la imagen con
fecha de interés, cada colección de imágenes tendrá una sola imagen.

``` r
length(PostImcol) # Ejemplo consultando la colección de imágenes post-incendio
```

    ## [1] 1

Convertimos el objeto `ImageCollection` en un objeto `Image` y lo
recortamos al área de estudio:

``` r
PreImage <- PreImcol$mosaic()$clip(shape_ee)
PostImage <- PostImcol$mosaic()$clip(shape_ee)
```

### **1d. Visualizar las imágenes**

Primero definimos los parámetros de visualización:

``` r
viz_true_color <- list(
  bands=c('B4', 'B3', 'B2'),
  min = 10,
  max = 2000,
  gamma = 1.5)

viz_swir <- list(
  bands=c('B12', 'B8A', 'B4'),
  min = 150,
  max = 4000,
  gamma = 1.5)
```

Agregamos las imágenes PRE y POST en visualización falso color SWIR y
color verdadero

``` r
Map$centerObject(shape_ee, zoom = 10)
# Agregar imágenes Pre Incendio
Map$addLayer(PreImage, viz_true_color, 'Pre-fuego RGB') +
Map$addLayer(PreImage, viz_swir, 'Pre-fuego SWIR') +
# Agregar imágenes Post Incendio
Map$addLayer(PostImage, viz_swir, 'Post-fuego SWIR')+
Map$addLayer(PostImage, viz_true_color, 'Post-fuego RGB')
```

*Visualización en color verdadero:*

<img src="https://github.com/romina-gonzalez-musso/Severidad_Incendio-Steffen-Martin22/blob/master/_images/1_True_color.gif?raw=true" width="50%" />

*Visualización en falso color:*

<img src="https://github.com/romina-gonzalez-musso/Severidad_Incendio-Steffen-Martin22/blob/master/_images/1_swir.gif?raw=true" width="50%" />

### **1e. Opcional: aplicar máscaras de agua y vegetación**

Se pueden aplicar máscaras para eliminar las áreas sin vegetación (ej.
afloramiento rocosos) y los lagos, de manera que los índices sean
aplicados solo a las zonas de bosque y vegetación.

Para este caso, la **máscara de agua** se generó a partir del producto
`GlobalSurfaceWater`:

``` r
# Máscara de agua con Global Surface Water
gsw <- ee$Image("JRC/GSW1_2/GlobalSurfaceWater")
water_mask <- gsw$select('seasonality')$lt(11)$unmask(1)$clip(shape_ee)
```

La **máscara de vegetación** se puede generar usando el producto
`GlobalForestWatch`. En este caso se optó por utilizar un umbral de NDVI
de la imagen Pre-incendio para eliminar las áreas sin vegetación.

``` r
getIndexes <- function(image) {
  ndwi <- image$normalizedDifference(c("B3", "B5"))$rename('NDWI')
  ndvi <- image$normalizedDifference(c("B8", "B4"))$rename('NDVI')
  return(image$addBands(c(ndvi, ndwi)))
}

indices <- getIndexes(PreImage)

# Máscaras de vegetación con NDVI
veg_mask <- indices$select('NDVI')$gte(0.15)$unmask(1)$clip(shape_ee)
```

Se aplican las máscaras a las imágenes:

``` r
## Aplicar máscaras 
PreImage <- PreImage$mask(water_mask)$mask(veg_mask)
PostImage <- PostImage$mask(water_mask)$mask(veg_mask)
```

*Comparación entre imagen sin máscaras y con máscaras:*

<img src="https://github.com/romina-gonzalez-musso/Severidad_Incendio-Steffen-Martin22/blob/master/_images/1_Masks.gif?raw=true" width="50%" />

### **1f. Cálculo del Índice NBR (Índice Normalizado de Área Quemada)**

El índice NBR se calcula a partir de la relación entre las bandas NIR y
SWIR:

<img src="https://github.com/romina-gonzalez-musso/Severidad_Incendio-Steffen-Martin22/blob/master/_images/1_NBR_formula.jpg?raw=true" width="20%" />

``` r
preNBR <- PreImage$normalizedDifference(c("B8", "B12"))
postNBR <- PostImage$normalizedDifference(c("B8", "B12"))
```

La diferencia entre ambos NBR permite estimar **la severidad del
incendio**.

``` r
# dNBR
dNBR_unscaled <-preNBR$subtract(postNBR)
```

Teniendo en cuenta los cambios fenológicos entre ambas fechas, se
calculó el `dNRB offset` (Parks et al. 2014) y luego se escalaron los
resultados de acuerdo a los valores propuestos por USGS.

``` r
# dNRB offset
offset <- 0.0277  # Calculado específicamente para este caso
dNBR_unscaled <- dNBR_unscaled$subtract(offset)

# Escalado a los estándars USGS
dNBR_scaled <- dNBR_unscaled$multiply(1000)
```

Ahora configuramos la **visualización**

``` r
viz_grayscale <- list(palette = c("White", "Black"), 
                      min = -1000,
                      max = 1000)

Map$addLayer(PostImage, viz_true_color, 'Post-fuego RGB') +
Map$addLayer(dNBR_scaled, viz_grayscale, 'dNBR GREY')
```

*Comparación entre la imagen post-incendio en falso color y el dNBR en
escala de grises:*

<img src="https://github.com/romina-gonzalez-musso/Severidad_Incendio-Steffen-Martin22/blob/master/_images/1_dNBR.gif?raw=true" width="50%" />

### **1.g. Visualización con las categorías de severidad USGS**

La USGS propone una una clasificación de severidad para interpretar los
resultados del índice:

<img src="https://github.com/romina-gonzalez-musso/Severidad_Incendio-Steffen-Martin22/blob/master/_images/1_classes.png?raw=true" width="75%" />

Fuente: <https://un-spider.org/es/node/10959>

Se determina una paleta de colores (`sld_intervals`) para clasificar el
dNBR en función a la tabla anterior:

``` r
sld_intervals <- paste0(
  "<RasterSymbolizer>",
  '<ColorMap type="intervals" extended="false" >',
  '<ColorMapEntry color="#ffffff" quantity="-500" label="-500"  />',
  '<ColorMapEntry color="#7a8737" quantity="-250" label="-250"  />',
  '<ColorMapEntry color="#acbe4d" quantity="-100" label="-100" />',
  '<ColorMapEntry color="#0ae042" quantity="100" label="100" />',
  '<ColorMapEntry color="#fff70b" quantity="270" label="270" />',
  '<ColorMapEntry color="#ffaf38" quantity="440" label="440" />',
  '<ColorMapEntry color="#ff641b" quantity="660" label="660" />',
  '<ColorMapEntry color="#a41fd6" quantity="2000" label="2000" />',
  "</ColorMap>",
  "</RasterSymbolizer>"
)
```

Visualizar los resultados en función a las categorías USGS:

``` r
Map$addLayer(PostImage, viz_true_color, 'Post-fuego RGB') +
Map$addLayer(dNBR_scaled$sldStyle(sld_intervals), {}, 'dNBR classified')
```

*Comparación entre la imagen post-incendio en color verdadero y la
clasificación de severidad:*

<img src="https://github.com/romina-gonzalez-musso/Severidad_Incendio-Steffen-Martin22/blob/master/_images/1_USGS.gif?raw=true" width="50%" />

### **1h. Descargar las imágenes a Google Drive**

Para poder trabajar en forma local los productos generados con GEE,
estos deben ser previamente exportados a Google Drive y luego
descargados.

Para exportar Google Drive se deben definir algunos parámetros. En este
caso están incluidos en el objeto `task`. Una vez definidos, se inicia
la exportación al Drive con `task$start`.

*Exportar el raster correspondiente al dNBR*

``` r
# Task para exportar el dNBR escalado a USGS proyectado a POSGAR F1
task <- ee$batch$Export$image$toDrive(
  image = dNBR_scaled,                  # Seleccionar qué producto se va a exportar
  description = "dNBR_scaled_masked",   # El nombre del archivo
  folder= "GEE_export",                 # La carpeta en GD donde se va a guardar
  scale = 20,                           # La resolución 
  crs = 'EPSG:22181',                   # El sistema de coordenadas
  region = shape_ee)                    # Recortar al área de estudio

# Comienza con la descarga
task$start()
ee_monitoring(task)
```

*Exportar las imágenes Sentinel 2:*

``` r
# Task para exportar la imagen pre-incendio
PreImage_export <- PreImage$select('B.+') #Elimina la banda Q20
task <-  ee_image_to_drive(
  image = PreImage_export,
  description = "S2_Prefire",
  folder= "GEE_export",
  scale = 20,
  crs = 'EPSG:22181',
  region = shape_ee)  

# Comienza con la descarga
task$start()
ee_monitoring(task)
```

``` r
# Task para exportar la imagen post-incendio
PreImage_export <- PostImage$select('B.+') #Elimina la banda Q20
task <-  ee_image_to_drive(
  image = PostImage_export,
  description = "S2_Postfire",
  folder= "GEE_export",
  scale = 20,
  crs = 'EPSG:22181',
  region = shape_ee)  

# Comienza con la descarga
task$start()
ee_monitoring(task)
```
