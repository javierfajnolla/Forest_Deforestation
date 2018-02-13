library(tidyverse)
library(raster)
# library(rasterVis)
library(snowfall)


# Links de descarga
down_links_tc <- read.table("https://storage.googleapis.com/earthenginepartners-hansen/GFC-2016-v1.4/treecover2000.txt", stringsAsFactors = FALSE)
down_links_fl <- read.table("https://storage.googleapis.com/earthenginepartners-hansen/GFC-2016-v1.4/lossyear.txt", stringsAsFactors = FALSE)

sea_links <- read.csv("./data/lista_mar.csv", strip.white = T)
ame_links <- read.csv("./data/lista_ame.csv", strip.white = T)


# Quitar los ya terminados
# done_links_tc <- list.files("./data/raster/tc")
# for (y in done_links_tc){
#   if(grepl("treecover", y) == TRUE){
#     remove <- which(!grepl(y, down_links_tc$V1))
#     down_links_tc <- down_links_tc %>% slice(remove)
#   }
# }
# done_links_fl <- list.files("./data/raster/fl")
# for (y in done_links_fl){
#   if(grepl("lossyear", y) == TRUE){
#     remove <- which(!grepl(y, down_links_fl$V1))
#     down_links_fl <- down_links_fl %>% slice(remove)
#   }
# }

matrix_tc <- read.csv("./data/m_hansen_tc.csv")
matrix_fl <- read.csv("./data/m_hansen_fl.csv")
matrix_fl2010 <- read.csv("./data/m_hansen_fl2010.csv")

# Directorios para guardar todas las capas
dir.create(paste0("./data/", "raster"), showWarnings = FALSE)
dir.create(paste0("./data/raster/", "tc"), showWarnings = FALSE)
dir.create(paste0("./data/raster/", "fl"), showWarnings = FALSE)
dir.create(paste0("./data/raster/", "fl2010"), showWarnings = FALSE)
dir.create(paste0("./data/", "log"), showWarnings = FALSE)
dir.create(paste0("./data/log/", "processing"), showWarnings = FALSE)
dir.create(paste0("./data/log/", "finished"), showWarnings = FALSE)


# Definicion de la funcion
gfc <- function(x){
  # Nombre de la capa
  name_tc <- as.character(down_links_tc[x,]) %>%
    strsplit(split = "Hansen_GFC-2016-v1.4_") %>%
    .[[1]] %>% .[2]
  name_fl <- as.character(down_links_fl[x,]) %>%
    strsplit(split = "Hansen_GFC-2016-v1.4_") %>%
    .[[1]] %>% .[2]
  name_general <- gsub("treecover2000_", "", name_tc) %>% gsub(".tif", "",.)
  
  name_sea <- as.character(down_links_tc[x,]) %>%
    strsplit(split = "GFC-2016-v1.4/") %>%
    .[[1]] %>% .[2]
  
  ### Comprobar si está siendo procesado para hacer este o pasar al siguiente
  list_done <- c(list.files("./data/log/processing"), list.files("./data/log/finished")) %>%
    gsub(".txt", "",.)
  
  if(!(name_general %in% list_done)){
    
    # Crear archivo de registro del proceso
    con <- file(paste0("./data/log/processing/", name_general, ".txt"), open = "wt")
    sink(con, append = T)
    sink(con, append = T, type = "message")
    cat('\n', "Empezando a las "); print(Sys.time())
    ptm <- proc.time()
    
    ## Crear carpeta para guardar temporales de raster para eliminarla al final
    dir.create(paste0("./data/temp_", x))
    rasterOptions(tmpdir = paste0("./data/temp_", x))
    
    ## Tree Cover
    # Descargar la capa
    temp_tc <- tempfile()
    download.file(as.character(down_links_tc[x,]), destfile = paste0(temp_tc, ".tif"), mode = "wb")
    tc <- raster(file.path(paste0(temp_tc, ".tif")))
    
    # Toma de decision: hacer script o crear raster de valor 0 si es mar
    # Si es mar, crear raster de valor 0
    if(name_sea %in% as.character(sea_links$tile)){
      cat('\n', " - > MAR - no es necesario descargar")
      
      # Creamos nuestro propio raster con la resolucion final que buscamos
      built_tc <- raster(ncol = 1250, nrow = 1250)
      
      # Asignamos la extension y proyeccion de la celda que estamos trabajando
      extent(built_tc) <- extent(tc)
      proj4string(built_tc) <- proj4string(tc)
      values(built_tc) <- 0
      
      # Copiamos la misma informacion para forest loss
      built_fl <- built_tc
      
      # Guardar
      writeRaster(built_tc, paste0("./data/raster/tc/", name_tc), format = "GTiff")
      writeRaster(built_fl, paste0("./data/raster/fl/", name_fl), format = "GTiff")
      if (name_sea %in% as.character(ame_links$tile)){
        writeRaster(built_fl, paste0("./data/raster/fl2010/", name_fl), format = "GTiff")
      }
    } else {
      # Si habia mas de un valor o el valor no era 0, sigue el script normal
      cat('\n', " -> FRAGMENTO CON DATOS - Empezando procesamiento")
      cat('\n', "Empezando procesamiento de ", name_general)
      tempo <- proc.time() - ptm
      print(paste0(tempo[[3]]/3600, " horas ///// ", tempo[[3]]/60, " minutos"))
      
      # Convertir Tree Cover raster a Boolean (0 - menos del 20% deforestado, 1 - mÃ¡s del 20% def)
      cat('\n', "* TREE COVER *")
      cat('\n', "Reclasificando TC")
      tempo <- proc.time() - ptm
      print(paste0(tempo[[3]]/3600, " horas ///// ", tempo[[3]]/60, " minutos"))
      tc2 <- reclassify(tc, matrix_tc)
      
      # Convertir a Ã¡rea
      cat('\n', "Calculos de area TC")
      tempo <- proc.time() - ptm
      print(paste0(tempo[[3]]/3600, " horas ///// ", tempo[[3]]/60, " minutos"))
      layer_area <- area(tc2)
      tc3 <- tc2 * layer_area
      
      # Cambiar resoluciÃ³n a 1km2
      cat('\n', "Cambiando resolucion TC")
      tempo <- proc.time() - ptm
      print(paste0(tempo[[3]]/3600, " horas ///// ", tempo[[3]]/60, " minutos"))
      tc4 <- aggregate(tc3, fact = 32, fun = sum)
      
      ## Save rasters
      writeRaster(tc4, paste0("./data/raster/tc/", name_tc), format = "GTiff")
      # Guardar primera capa de 30 m para inspeccionar
      # if(x == 1){
      #   writeRaster(tc2, paste0("./data/raster/tc/_", name_tc, "_30m"), format = "GTiff")
      #   writeRaster(tc3, paste0("./data/raster/tc/_", name_tc, "_30marea"), format = "GTiff")
      # }
      
      ############
      ## Forest Loss
      # Descargar la capa
      temp_fl <- tempfile()
      download.file(as.character(down_links_fl[x,]), destfile = paste0(temp_fl, ".tif"), mode = "wb")
      fl <- raster(file.path(paste0(temp_fl, ".tif")))
      unlink(temp_fl)
      
      # Reclasificar a 1 donde hubo deforestacion (cualquier año)
      cat('\n', "* FOREST LOSS *")
      cat('\n', "Reclasificando FL")
      tempo <- proc.time() - ptm
      print(paste0(tempo[[3]]/3600, " horas ///// ", tempo[[3]]/60, " minutos"))
      fl2 <- reclassify(fl, matrix_fl)
      
      # Eliminar pixeles donde la deforestaciÃ³n se produjo donde habia menos del 20% de bosque
      cat('\n', "Eliminando deforestacion de pixeles con menos del 20% de bosque")
      tempo <- proc.time() - ptm
      print(paste0(tempo[[3]]/3600, " horas ///// ", tempo[[3]]/60, " minutos"))
      fl2b <- fl2 * tc2
      
      # Convertir a area
      cat('\n', "Calculos de area FL")
      tempo <- proc.time() - ptm
      print(paste0(tempo[[3]]/3600, " horas ///// ", tempo[[3]]/60, " minutos"))
      fl3 <- fl2b * layer_area
      
      # Cambiar resoluciÃ³n a 1km2
      cat('\n', "Cambiando resolucion FL")
      tempo <- proc.time() - ptm
      print(paste0(tempo[[3]]/3600, " horas ///// ", tempo[[3]]/60, " minutos"))
      fl4 <- aggregate(fl3, fact = 32, fun = sum)
      
      ## Save rasters
      writeRaster(fl4, paste0("./data/raster/fl/", name_fl), format = "GTiff")
      # Guardar primera capa de 30 m para inspeccionar
      # if(x == 1){
      #   writeRaster(fl2, paste0("./data/raster/fl/_", name_fl, "_30m_alldefor"), format = "GTiff")
      #   writeRaster(fl2b, paste0("./data/raster/fl/_", name_fl, "_30m_over20defor"), format = "GTiff")
      #   writeRaster(fl3, paste0("./data/raster/fl/_", name_fl, "_area"), format = "GTiff")
      # }
      #
      
      ### Repetir para 2010 - articulo brechas
      # Solo cuando es un raster de America
      if (name_sea %in% as.character(ame_links$tile)){
        cat('\n', "HACIENDO CALCULOS HASTA 2010 PARA PAPER DE BRECHA")
        cat('\n', "Reclasificando TC 2010")
        tempo <- proc.time() - ptm
        print(paste0(tempo[[3]]/3600, " horas ///// ", tempo[[3]]/60, " minutos"))
        fl2_2010 <- reclassify(fl, matrix_fl2010)
        # Eliminar pixeles donde la deforestaciÃ³n se produjo donde habia menos del 20% de bosque
        cat('\n', "Eliminando deforestacion de pixeles con menos del 20% de bosque - 2010")
        tempo <- proc.time() - ptm
        print(paste0(tempo[[3]]/3600, " horas ///// ", tempo[[3]]/60, " minutos"))
        fl2_2010b <- fl2_2010 * tc2
        
        # Convertir a area
        cat('\n', "Calculos de area FL 2010")
        tempo <- proc.time() - ptm
        print(paste0(tempo[[3]]/3600, " horas ///// ", tempo[[3]]/60, " minutos"))
        fl3_2010 <- fl2_2010b * layer_area
        
        # Cambiar resoluciÃ³n a 1km2
        cat('\n', "Cambiando resolucion FL 2010")
        tempo <- proc.time() - ptm
        print(paste0(tempo[[3]]/3600, " horas ///// ", tempo[[3]]/60, " minutos"))
        fl4_2010 <- aggregate(fl3_2010, fact = 32, fun = sum)
        
        ## Save rasters
        writeRaster(fl4_2010, paste0("./data/raster/fl2010/", name_fl), format = "GTiff")
      }
    }
    
    # Eliminar carpeta temporales
    unlink(paste0("./data/temp_", x), recursive = T)
    unlink(paste0(temp_tc, ".tif"))
    
    # Cerrar archivo de seguimiento
    sink(type = "message")
    sink()
    close(con)
    
    file.rename(from = paste0("./data/log/processing/", name_general, ".txt"),
                to = paste0("./data/log/finished/", name_general, ".txt"))
  }
}

## Init snowfall
sfInit(parallel=TRUE, cpus=4)

## Export packages
sfLibrary('raster', character.only=TRUE)
sfLibrary('tidyverse', character.only=TRUE)

## Export variables
sfExportAll()   # sfExportAll() to export all your workspace variables, but can be also sfExport('mySpeciesOcc'), sfExport('Sp.list'), ...

# USE in SNOWFALL the LAPPLY FUNCTION ON THE LIST OF SPECIES
mySFModelsOut <- sfClusterApplyLB(1:nrow(down_links_tc), gfc)
# mySFModelsOut <- sfLapply(Sp.list, MyBiomodSF)

## stop snowfall (if needed)
sfStop(nostop=FALSE)
