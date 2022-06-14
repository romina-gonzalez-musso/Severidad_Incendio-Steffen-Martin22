shapeUSGSxTipoFtal <- function(x){
  
  # Traer el shape CIEFAP
  ciefap <- vect(dir_ciefap)
  ciefap <- terra::project(ciefap, "EPSG:22181")
  # Traer el dNBR clasificado
  nbr_class <- rast(dir_nbr_class) 
  nbr_class <- terra::project(nbr_class, "EPSG:22181")
  
  # Seleccionar un tipo forestal del shape
  tipo_ftal <- terra::subset(ciefap, ciefap$Ley_N2 == x)
  
  # Recortar el NBR al tipo forestal
  forest_usgs <- terra::mask(nbr_class, tipo_ftal) %>%
    terra::crop(., tipo_ftal)
  
  # Poligonizar la clasificación
  forest_usgs <- forest_usgs %>%
    as.polygons(.) %>%         # Del paquete terra
    st_as_sf(.)             
    
    # Convertir a SF %>% st_cast(.,"POLYGON") 
  
  # Agregar la columna de superficie en m2
  forest_usgs  <- forest_usgs  %>% 
    mutate(area_m2 = st_area(forest_usgs))
  
  # Agregar la de tipo ftal
  forest_usgs  <- forest_usgs  %>% 
    mutate(tipo_ftal = x)
  
  # Agregar columna de superficie en ha
  forest_usgs$area_ha <- units::set_units(forest_usgs$area, ha)
  
  return(forest_usgs)
  
}

plotUSGS <- function(x){
  # Traer el raster
  nbr_class <- rast(dir_nbr_class)
  nbr_class <- terra::project(nbr_class, "EPSG:22181")
  # Definir los colores
  my_col=c("#ffffff",      # -1 NA Values
           "#7a8737",      # 1 - Enhanced Regrowth, High
           "#acbe4d",      # 2 - Enhanced Regrowth, Low
           "#0ae042",      # 3 - Unburned
           "#fff70b",      # 4 - Low Severity
           "#ffaf38",      # 5 - Moderate-low Severity
           "#ff641b",      # 6 - Moderate-high Severity
           "#a41fd6")      # 7 - High Severity
  
  # Armar la legenda con las clases USGS
  nbr_class <- ratify(raster(nbr_class))
  rat <- levels(nbr_class)[[1]]
  
  # Ponerle texto a cada categoría del -1 al 7
  rat$legend  <- c("NA", "1-Enhanced Regrowth, High", 
                   "2-Enhanced Regrowth, Low", "3-Unburned", 
                   "4-Low Severity", "5-Moderate-low Severity", 
                   "6-Moderate-high Severity", "7-High Severity") 
  
  levels(nbr_class) <- rat
  
  # Enmascarar el tipo forestal
  nbr_class_mask <- terra::mask(rast(nbr_class), vect(x)) %>%
    terra::crop(., vect(x))
  
  # Título
  name <- paste0("Clases de severidad USGS - ", x$tipo_ftal[1])
  
  # Graficar
  par(mar =  c(4, 2, 4, 8) + 0.1)
  plot(nbr_class, col = grey.colors(10), frame = FALSE, main = name,  xaxt='n',  yaxt='n', legend = FALSE)
  plot(nbr_class_mask, col=my_col, legend=F ,add = TRUE,) 
  legend("right", inset = c(-0.38,0), legend =rat$legend, xpd = TRUE, 
         horiz = FALSE, fill = my_col, cex = 0.8)
  
}


supUSGSxTipoFtal <- function(y){
  # Sumar los polígonos por categoría
  Sups <- aggregate(y$area_ha, list(y$ID), FUN=sum) 
  colnames(Sups) <- c("N_Cat", "Sup_ha")
  
  name <- deparse(substitute(y)) 
  
  # Editar la tabla
  Sups <- Sups %>% 
    mutate(Percentage = Sup_ha/sum(Sup_ha)*100) %>%
    mutate(Tipo_ftal = y$tipo_ftal[1]) %>%
    mutate_if(is.numeric, ~round(., 2)) %>%
    mutate(Categoria = ifelse(N_Cat == 1, "1-Enhanced Regrowth, High",
                              ifelse(N_Cat == 2, "2-Enhanced Regrowth, Low", 
                                     ifelse(N_Cat == 3, "3-Unburned", 
                                            ifelse(N_Cat == 4, "4-Low Severity", 
                                                   ifelse(N_Cat == 5, "5-Moderate-low Severity",
                                                          ifelse(N_Cat == 6, "6-Moderate-high Severity", 
                                                                 "7-High Severity"))))))) %>%
    dplyr::select(N_Cat, Categoria, Tipo_ftal, Sup_ha, Percentage)
  
  
  return(Sups)
  
  
}