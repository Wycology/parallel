# Parallel programming in R -----------------------------------------------

# This is one of the most beautiful things to learn and master in R.

# Suppose you have a map of 11 countries and a raster layer of monthly rainfall
# covering all of the countries.

# You want to report annual rainfall for each country separately.

# This is a classical case in which you will use the polygon of each country,
# crop rainfall layers for the country, sum them and write the raster out.

# Repeat this for all the countries.

# Here we show how loop, do, and dopar can help achieve these.

# The task ----------------------------------------------------------------

output <- "output"

get_map <- function(raster, shape){
  p_rast <- terra::crop(raster, shape, snap = "out")
  p_rast <- terra::mask(p_rast, shape)
  p_rast <- sum(p_rast)
  return(p_rast)
}

cores <- detectCores() - 1
registerDoParallel(cores)

system.time(
  foreach(i = 1:nrow(countries),.packages = "terra") %dopar% {
    rst <- terra::rast(chirps_files)
    countries <- vect(shape_path)
    countries <- countries[which(countries$DISP_AREA == "NO"),]
    r  <- get_map(raster = rst, shape = countries[i,])
    n  <- countries[i,]$Name_label
    n  <- paste0(output,"/", n,".tif")
    writeRaster(r, n, overwrite = TRUE)
  })

stopImplicitCluster()

# This for loop works fine ------------------------------------------------

system.time(
  for(i in 1:nrow(countries)){
    r <- get_map(raster = chirps, shape = countries[i,])
    countries <- countries[which(countries$DISP_AREA == "NO"),]
    n <- countries[i,]$Name_label
    n <- paste0("output/", n, ".tif")
    writeRaster(r, n, overwrite = T)
  })

# This do also works fine -------------------------------------------------

cores <- detectCores() - 1
registerDoParallel(cores = cores)

system.time(
  foreach(i = 1:nrow(countries), .packages = "terra") %do% {
    
    countries <- countries[which(countries$DISP_AREA == "NO"),]
    r <- get_map(raster = chirps, shape = countries[i,])
    n <- countries[i,]$Name_label
    n <- paste0("output/", n, ".tif")
    
    writeRaster(r, n, overwrite = TRUE)
    
  })

stopImplicitCluster()

