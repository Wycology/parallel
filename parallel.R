# Parallel programming in R -----------------------------------------------

# This is one of the most beautiful things to learn and master in R.

# Suppose you have a map of 11 countries and a raster layer of monthly rainfall
# covering all of the countries.

# You want to report annual rainfall for each country separately.

# This is a classical case in which you will use the polygon of each country,
# crop rainfall layers for the country, sum them and write the raster out.

# Repeat this for all the countries.

# Here we show how loop, do, and dopar can help achieve these.

# Libraries ---------------------------------------------------------------

pacman::p_load(doParallel, parallel, terra)

# The task ----------------------------------------------------------------

dir.create("output") # Creates a folder called output in the working directory

# Creating the function to do the task ------------------------------------

get_map <- function(raster, shape){ # A function that takes two arguments
  p_rast <- terra::crop(raster, shape, snap = "out") # Crops raster using shape
  p_rast <- terra::mask(p_rast, shape) # Masks raster using shape
  p_rast <- sum(p_rast) # Sums cell wise all months in the cropped raster
  return(p_rast) # Keeps the raster with annual rainfall per pixel
}

# Using the basic for loop ------------------------------------------------

system.time( # This is to time how long the process will take
  for(i in 1:nrow(countries)){ # 1 to number of countries in the multipolygon
    countries <- countries[which(countries$DISP_AREA == "NO"),] # Takes clean countries
    r <- get_map(raster = chirps, # Takes the raster stack
                 shape = countries[i,]) # Crops it by each country polygon
    n <- countries[i,]$Name_label # Picks the name of the country
    n <- paste0("output/", n, ".tif") # Adds to output path the name of country and .tif
    writeRaster(r, n, overwrite = T) # Writes the raster for the country to disk
  })

# Using do ----------------------------------------------------------------

cores <- detectCores() - 1          # Spares one core from the available cores
registerDoParallel(cores = cores)   # Initiates the cores for use in parallel computation

system.time( # Checking on time
  foreach(i = 1:nrow(countries), .packages = "terra") %do% { # Setting stage
    countries <- countries[which(countries$DISP_AREA == "NO"),]
    r <- get_map(raster = chirps, shape = countries[i,])
    n <- countries[i,]$Name_label # Picking the variable for naming outputs
    n <- paste0("output/", n, ".tif")
    writeRaster(r, n, overwrite = TRUE)
  })

stopImplicitCluster()

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