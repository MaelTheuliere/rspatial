library(httr)
library(jsonlite)
library(sf)
library(tidyverse)
library(lubridate)
get_dvf<-GET("http://api.cquest.org/dvf?code_commune=44109")

dvf_content<-content(get_dvf,'text')

dvf_json <- fromJSON(dvf_content, flatten = TRUE)$resultats %>%
  filter(!is.na(lon),!is.na(lat))

dvf <- st_as_sf(dvf_json,
                         coords = c("lon", "lat"), 
           crs = 4326)

#get_quartier_nantes<-GET("https://data.nantesmetropole.fr/api/records/1.0/search/?dataset=244400404_quartiers-nantes")
#quartier_nantes<-content(get_quartier_nantes,'text')
#
#quartier_nantes_json <- fromJSON(quartier_nantes, 
#                                flatten = TRUE)$records
#
#quartier_nantes_json_geo<-st_as_sf(quartier_nantes_json,
#                                   sf_column_name = "fields.geometry.coordinates",
#                                   crs = 4326)

# provient de nantes métropole open data :https://data.nantesmetropole.fr/explore/dataset/244400404_quartiers-nantes/information/?disjunctive.nom&location=12,47.23826,-1.56032&basemap=jawg.streets
quartier_nantes<-st_read(dsn="extdata/quartier_nantes/244400404_quartiers-nantes.geojson")

rm(get_dvf,dvf_content,dvf_json)

dvf_avec_quartier<-st_join(dvf,
                           quartier_nantes %>% 
                             select(nom))
ggplot()+
  geom_sf(data=quartier_nantes)+
  geom_sf(data=dvf_avec_quartier,
          aes(color=nom))

dvf_avec_quartier %>% 
  st_drop_geometry() %>% 
  filter(nature_mutation=="Vente",
         type_local %in% c("Appartement","Maison")) %>% 
  rename(quartier=nom) %>% 
  mutate(date_mutation=ymd(date_mutation),
         annee_mutation=year(date_mutation),
         nb_ventes=1) %>% 
  group_by(type_local,annee_mutation) %>% 
  summarise_at(vars(nb_ventes,valeur_fonciere,surface_relle_bati),funs(sum)) %>% 

