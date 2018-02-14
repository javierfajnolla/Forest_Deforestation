# Unir los tiles de cada tipo (tree cover y forest loss)
library(tidyverse)
library(raster)

# Tree cover

files_tc <- list.files("data/raster/tc", full.names=TRUE, recursive=TRUE)
rast_list_tc <- lapply(1:length(files_tc),
                       function(x) {
                         raster(files_tc[x])
                       })
rast_list_tc$fun <- mean
rast_mosaic_tc <- do.call(mosaic, rast_list_tc)
writeRaster(rast_mosaic, "data/raster/world/tc/treecover2000", format = "GTiff")

### Por partes... cuando me salía error, que al final era porque transmit había descargado mal un par de cuadrados desde trueno (pero no es necesario si no ha ese problema en la conexión a internet durante la descarga)
# # NW
# files_tc <- list.files("data/raster/tc", full.names=TRUE, recursive=TRUE)
# files_tc_N <- files_tc[grepl("N_", files_tc)]
# files_tc_NW <- files_tc_N[grepl("W.tif", files_tc_N)]
# rast_list_NW <- lapply(1:length(files_tc_NW),
#                     function(x) {
#                       raster(files_tc_NW[x])
#                     })
# rast_list_NW$fun <- mean
# rast_mosaic_NW <- do.call(mosaic, rast_list_NW)
# # NE - error
# files_tc_NE <- files_tc_N[grepl("E.tif", files_tc_N)]
# rast_list_NE <- lapply(1:length(files_tc_NE),
#                        function(x) {
#                          raster(files_tc_NE[x])
#                        })
# rast_list_NE$fun <- mean
# rast_mosaic_NE <- do.call(mosaic, rast_list_NE)
# # SW
# files_tc_S <- files_tc[grepl("S_", files_tc)]
# files_tc_SW <- files_tc_S[grepl("W.tif", files_tc_S)]
# rast_list_SW <- lapply(1:length(files_tc_SW),
#                        function(x) {
#                          raster(files_tc_SW[x])
#                        })
# rast_list_SW$fun <- mean
# rast_mosaic_SW <- do.call(mosaic, rast_list_SW)
# # SE
# files_tc_SE <- files_tc_S[grepl("E.tif", files_tc_S)]
# rast_list_SE <- lapply(1:length(files_tc_SE),
#                        function(x) {
#                          raster(files_tc_SE[x])
#                        })
# rast_list_SE$fun <- mean
# rast_mosaic_SE <- do.call(mosaic, rast_list_SE)
# # World
# rast_mosaic <- mosaic(rast_mosaic_NW, rast_mosaic_NE, rast_mosaic_SW, rast_mosaic_SE, fun = mean)
# 
# # rast_mosaic %>% plot
# 
# writeRaster(rast_mosaic, "data/raster/world/tc/treecover2000", format = "GTiff")
# rm(rast_mosaic_NE, rast_mosaic_NW, rast_mosaic_SE, rast_mosaic_SW)
# rm(rast.mosaic, rast.mosaic_NW)


# Forest Loss
files_fl <- list.files("data/raster/fl", full.names=TRUE, recursive=TRUE)
rast_list_fl <- lapply(1:length(files_fl),
                       function(x) {
                         raster(files_fl[x])
                       })
rast_list_fl$fun <- mean
rast_mosaic_fl <- do.call(mosaic, rast_list_fl)
writeRaster(rast_mosaic_fl, "data/raster/world/fl/forestloss_2000_2016", format = "GTiff")

# Forest Loss America hasta 2010
files_fl2010 <- list.files("data/raster/fl2010", full.names=TRUE, recursive=TRUE)
rast_list_fl2010 <- lapply(1:length(files_fl2010),
                       function(x) {
                         raster(files_fl2010[x])
                       })
rast_list_fl2010$fun <- mean
rast_mosaic_fl2010 <- do.call(mosaic, rast_list_fl2010)
writeRaster(rast_mosaic_fl2010, "data/raster/world/fl/forestloss_2000_2010_ame", format = "GTiff")


# #### (old way)
# 
# # Tree cover
# cat('\n', "Tree cover")
# files_tc <- list.files("data/raster/tc")
# 
# cat('\n', "1")
# tc_world <- raster(paste0("data/raster/tc/", files_tc[1]))
# for (x in 2:length(files_tc)){
#   cat(" ", x)
#   tc_r <- raster(paste0("data/raster/tc/", files_tc[x]))
#   tc_world <- mosaic(tc_world, tc_r, fun = mean)
# }
# 
# cat('\n', "Saving")
# dir.create("data/raster/world", showWarnings = F)
# dir.create("data/raster/world/tc", showWarnings = F)
# writeRaster(tc_world, "data/raster/world/tc/treecover2000", format ="GTiff")
# 
# rm(tc_world); rm(tc_r)
# gc()
# 
# # Forest Loss
# cat('\n', "Forest Loss")
# files_fl <- list.files("data/raster/fl")
# 
# cat('\n', "1")
# fl_world <- raster(paste0("data/raster/fl/", files_fl[1]))
# for (x in 2:length(files_fl)){
#   cat(" ", x)
#   fl_r <- raster(paste0("data/raster/fl/", files_fl[x]))
#   fl_world <- mosaic(fl_world, fl_r, fun = mean)
# }
# 
# cat('\n', "Saving")
# dir.create("data/raster/world", showWarnings = F)
# dir.create("data/raster/world/fl", showWarnings = F)
# writeRaster(fl_world, "data/raster/world/fl/forestloss_2000_2016", format ="GTiff")
# 
# rm(tc_world); rm(tc_r)
# gc()
# 
# # Forest Loss (hasta 2010)
# cat('\n', "Forest Loss 2010")
# files_fl2010 <- list.files("data/raster/fl2010")
# 
# cat('\n', "1")
# fl2010_world <- raster(paste0("data/raster/fl2010/", files_fl2010[1]))
# for (x in 2:length(files_fl2010)){
#   cat(" ", x)
#   fl2010_r <- raster(paste0("data/raster/fl2010/", files_fl2010[x]))
#   fl2010_world <- mosaic(fl2010_world, fl2010_r, fun = mean)
# }
# 
# dir.create("data/raster/world", showWarnings = F)
# dir.create("data/raster/world/fl2010", showWarnings = F)
# writeRaster(fl2010_world, "data/raster/world/fl2010/forestloss_2000_2010", format ="GTiff")
# 
# cat('\n', "Saving")
# rm(tc_world); rm(tc_r)
# gc()