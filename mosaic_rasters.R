# Unir los tiles de cada tipo (tree cover y forest loss)

library(tidyverse)
library(raster)

# Tree cover
files_tc <- list.files("data/raster/tc")

tc_world <- raster(paste0("data/raster/tc/", files_tc[1]))
for (x in 2:length(files_tc)){
  tc_r <- raster(paste0("data/raster/tc/", files_tc[x]))
  tc_world <- mosaic(tc_world, tc_r, fun = mean)
}

dir.create("data/raster/world", showWarnings = F)
dir.create("data/raster/world/tc", showWarnings = F)
writeRaster(tc_world, "data/raster/world/tc/treecover2000", format ="GTiff")

# Forest Loss
files_fl <- list.files("data/raster/fl")

fl_world <- raster(paste0("data/raster/fl/", files_fl[1]))
for (x in 2:length(files_fl)){
  fl_r <- raster(paste0("data/raster/fl/", files_fl[x]))
  fl_world <- mosaic(fl_world, fl_r, fun = mean)
}

dir.create("data/raster/world", showWarnings = F)
dir.create("data/raster/world/fl", showWarnings = F)
writeRaster(fl_world, "data/raster/world/fl/forestloss_2000_2016", format ="GTiff")


# Forest Loss (hasta 2010)
files_fl2010 <- list.files("data/raster/fl2010")

fl2010_world <- raster(paste0("data/raster/fl2010/", files_fl2010[1]))
for (x in 2:length(files_fl2010)){
  fl2010_r <- raster(paste0("data/raster/fl2010/", files_fl2010[x]))
  fl2010_world <- mosaic(fl2010_world, fl2010_r, fun = mean)
}

dir.create("data/raster/world", showWarnings = F)
dir.create("data/raster/world/fl2010", showWarnings = F)
writeRaster(fl2010_world, "data/raster/world/fl2010/forestloss_2000_2010", format ="GTiff")
