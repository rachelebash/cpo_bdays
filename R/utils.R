# leaflet basemap to render shiny leaflet maps at the start
# takes in a sf "shp" containing POINT geometries and a "nm_dscr" column which is used as the 'label' and 'layerId'
basemap <- function(shp) {
  leaflet::leaflet() %>%
    leaflet::addScaleBar("bottomleft") %>%
    # leaflet::setView(lng = -105.6, lat = 39.7, zoom = 7) %>% 
    leaflet::addTiles() %>%
    leaflet::addCircleMarkers(
      data         = shp,
      color        = "black",
      opacity      = 0.7,
      fillColor    = "dodgerblue",
      fillOpacity  = 0.7,
      weight       = 2,
      stroke       = TRUE,
      label        = shp$nm_dscr,
      layerId      = ~nm_dscr
      )
}
