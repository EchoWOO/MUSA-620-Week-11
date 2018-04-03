library(leaflet)
library(rgdal)
library(htmlwidgets)
library(ggmap)
library(sf)


# Leaflet is a popular JavaScript library for building zoomable, interactive maps
# R Leaflet allows you to create web-based Leaflet maps in R

# Leaflet offers many options and is very well documented
# https://rstudio.github.io/leaflet/



# *** BASIC LEAFLET EXAMPLE ***

ourCoords <- geocode("210 S 34th St, Philadelphia, PA 19104")

mymap <- leaflet() %>%
  addTiles() %>%
  addMarkers(ourCoords$lon, ourCoords$lat, popup="<strong>**MUSA 620**</strong>") %>%
  setView(ourCoords$lon, ourCoords$lat, zoom = 17)

mymap



# *** MAP TILES ***
# Many options: https://leaflet-extras.github.io/leaflet-providers/preview/
# Design your own: https://www.mapbox.com/help/define-mapbox-studio-classic/.

# Default map tiles
leaflet() %>%
  addTiles() %>%

# Neutral, light -- good for data visualization
leaflet() %>%
  addProviderTiles(providers$CartoDB.Positron)

# Neutral, dark -- good for data visualization
leaflet() %>%
  addProviderTiles(providers$CartoDB.DarkMatter)

# Satellite imagery
leaflet() %>%
  addProviderTiles(providers$Esri.WorldImagery)

# Earth at night
leaflet() %>%
  addProviderTiles(providers$NASAGIBS.ViirsEarthAtNight2012)

# Map tiles can also be layered
leaflet() %>% addProviderTiles(providers$MtbMap) %>%
  addProviderTiles(providers$Stamen.TonerLines, options = providerTileOptions(opacity = 0.35)) %>%
  addProviderTiles(providers$Stamen.TonerLabels)





# *** POINT OVERLAYS ***

accidentpoints <- read.csv("philly-accident-points.csv")

# Leaflet includes four "palette functions" for convenience.
#   colorNumeric():   continuous input, continuous colors
#   colorBin():       continuous input, discrete colors (pre defined bins)
#   colorQuantile():  continuous input, discrete colors (quantiles)
#   colorFactor():    categorical input, discrete colors

# Each palette function takes two required inputs: palette and domain
# palette can be:
#   1. The name of a Viridis or ColorBrewer palette (e.g. "magma", "inferno", "RdYlBu", "Greens")
#   2. A vector of colors, e.g. c("black", "grey", "#FFFFFF")


personBins <- c(0, 1, 2, 5, 10, 20, Inf)
paletteBins <- colorBin(palette = "OrRd", accidentpoints$persons, bins=-personBins)

paletteFactor <- colorFactor(c("blue","green","yellow"), accidentpoints$drunk_dr)

paletteContinuous <- colorNumeric(palette = "magma", domain = accidentpoints$latitude + accidentpoints$longitud)


# The syntax for styling Leaflet layers is much like ggplot

leaflet() %>%
  #addProviderTiles(providers$CartoDB.DarkMatterNoLabels) %>%
  addProviderTiles(providers$CartoDB.PositronNoLabels) %>%
  addCircleMarkers(data=accidentpoints,
                   lng = ~longitud,
                   lat = ~latitude,
                   radius = ~sqrt(persons) + 0.5,
                   fillOpacity = 1,
                   fillColor = ~paletteBins(-persons),
                   #fillColor = ~paletteFactor(drunk_dr),
                   #fillColor = ~paletteContinuous(latitude + longitud),
                   color = "white",
                   #opacity = 1,
                   stroke=F,
                   #stroke=T,
                   #weight = 1,
                   #popup= ~paste0("Date: ",month,"/",day),
                   label = ~tway_id)





# *** POLYGON OVERLAYS ***

phillycrime2016 <- readOGR("philly-crime-2016.geojson") %>%
  st_as_sf()

phillycrime2016$crimebucket <- factor(
  cut(as.numeric(phillycrime2016$y2016), c(-1, 200, 600, 1100, 1801, 99999999)),
  labels = c("Less than 200", "200 to 599", "600 to 1099", "1100 to 1800", "More than 1800")
)

crimeBucketPal <- colorFactor(c("#3b2a3d", "#685a4a", "#9b944a",  "#b3cb30", "#ffff20"), phillycrime2016$crimebucket)

crime2016 <- leaflet(phillycrime2016) %>% addProviderTiles(providers$CartoDB.Positron) %>%
  addPolygons( data = phillycrime2016,
               fillColor = ~crimeBucketPal(crimebucket),
               weight = 0.8,
               opacity = 0.6,
               smoothFactor = 0.1,
               #color = ~crimeBucketPal(crimebucket),
               color = "white",
               fillOpacity = 0.8,
               label = ~paste0("Crimes: ", y2016),
               highlight = highlightOptions(
                 fillColor = "orange",
                 fillOpacity = 1)) %>%
  addLegend(pal = crimeBucketPal, 
            values = ~crimebucket, 
            position = "bottomright", 
            title = "Crimes in 2016",
            opacity = 1)

crime2016



# *** EXPORT TO THE WEB ***

saveWidget(crime2016, file="philly-crime.html", selfcontained=TRUE)





