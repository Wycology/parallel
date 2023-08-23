# Parallel programming in R -----------------------------------------------

# This is one of the most beautiful things to learn and master in R.

# Suppose you have a map of 11 countries and a raster layer of monthly rainfall
# covering all of the countries.

# You want to report annual rainfall for each country separately.

# This is a classical case in which you will use the shapefile of each country,
# crop rainfall layers for the country, sum them and write the raster out.

# Repeat this for all the countries.

# Here we show how loop, do, and dopar can help achieve these.

# The task ----------------------------------------------------------------



