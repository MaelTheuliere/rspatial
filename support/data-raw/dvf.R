library(httr)
library(jsonlite)
get_dvf<-GET("http://api.cquest.org/dvf?code_commune=44109")

dvf<-content(get_dvf,'text')

dvf_json <- fromJSON(dvf, flatten = TRUE)$resultats %>%
  filter(!is.na(lon),!is.na(lat))

dvf_json_geo <- st_as_sf(dvf_json,
                         coords = c("lon", "lat"), 
           crs = 4326)

