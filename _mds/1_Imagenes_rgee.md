
## **1. BÚSQUEDA Y DESCARGA DE IMÁGENES**

### **1a. Instalar rgee**

<img src="_images/1_Rgee_logo.png" width="08%" />

**rgee** es una librería que permite llamar a la API de Google Earth
Entine usando R (Aybar et al. 2020).

El paquete se instala en R como cualquier otro paquete ejecutando
`install.packages(rgee)`. Luego es necesario configurar por única vez el
entorno de trabajo e indicar las credenciales de acceso a la cuenta de
Google Earth Engine (GEE) del usuario. Para esto, luego de instalar el
paquete se ejecuta `rgee::ee_install()` y se siguen las indicaciones. La
guía detallada de instalación de rgee se puede leer en la página oficial
del desarrollo: <https://github.com/r-spatial/rgee>

Una vez instalada, cargamos la librería rgee e iniciamos la API de GEE:

``` r
library("rgee")
ee_Initialize()
```

### **1b. Indicar área y fechas de interés**

Una forma de indicar el **área de estudio** es usando un shape propio.
Para eso usamos la librería `sf` y le indicamos dónde tenemos alojado en
nuestro sistema el archivo shape.

``` r
library("sf")
shape <- st_read("_gis_shapes/area_incendio.shp")
```

Usando `leflet`, desplegamos el shape:

``` r
library("leaflet")
leaflet(shape) %>%
  addTiles() %>% 
  addPolygons(color = "red", weight = 1, opacity = 1.0)
```

<img src="_images/1_Area.png" width="40%" />

Finalmente, convertimos el objeto `sf` a objeto rgee:

``` r
shape_ee <- sf_as_ee(shape$geometry)
```

Ahora hay que definir las **fechas**. Para este caso ya se habían
elegido dos imágenes Sentinel 2 libre de nubes usando visores de
imágenes externos. Por lo tanto, se acota el período de fechas para que
tome únicamente la imagen del día de interés.

``` r
pre_fire <- c('2021-12-05', '2021-12-07')    # Fecha de interés: 6/12/21
post_fire <- c('2022-03-10', '2022-03-12')   # Fecha de interés: 11/03/22
```

### **1c.Traer la colección de imágenes de GEE (ImageCollection)**

Traemos la colección de imágenes Sentinel 2 de GEE y la filtramos por
las fechas y el área de estudio.

``` r
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

Verificamos que al acotar el rango de fechas únicamente a la imagen
deseada, cada colección de imágenes tendrá una sola imagen.

``` r
length(PostImcol) # Ejemplo consultando la colección de imágenes post-incendio
```

    ## [1] 1

Convertimos la ImageCollection en una Imagen y la recortamos al área de
estudio:

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
Map$addLayer(PreImage, viz_true_color, 'Pre-fuego RGB') +
Map$addLayer(PreImage, viz_swir, 'Pre-fuego SWIR') +
Map$addLayer(PostImage, viz_swir, 'Post-fuego SWIR')+
Map$addLayer(PostImage, viz_true_color, 'Post-fuego RGB')
```

<img src="_images/1_True_color.gif" width="50%" />

<img src="_images/2_swir.gif" width="50%" />

### **1e. Descargar las imágenes a Google Drive**

Se pueden exportar los productos a Google Drive para luego trabajar en
forma local en cualquier softare GIS.

Primero se definen los parámetros del objeto `task` a descargar y luego
con `task$start` comienza la descarga.

``` r
# Task para exportar la imagen pre-incendio
PreImage_export <- PreImage$select('B.+') #Elimina la banda Q20
task <-  ee_image_to_drive(
  image = PreImage_export,
  description = "S2_Prefire",
  folder= "GEE_export",
  scale = 20,
  crs = 'EPSG:4326',
  region = shape_ee)  

# Comienza con la descarga
task$start()
ee_monitoring(task)
```
