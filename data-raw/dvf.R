library(httr)
library(jsonlite)
library(sf)
library(tidyverse)
library(lubridate)
get_dvf<-GET("http://api.cquest.org/dvf?code_commune=44109")

dvf_content<-content(get_dvf,'text')

dvf_json <- fromJSON(dvf_content)$resultats %>%
  filter(!is.na(lon),!is.na(lat),!is.na(valeur_fonciere),!is.na(surface_relle_bati))

dvf <- st_as_sf(dvf_json,
                         coords = c("lon", "lat"), 
           crs = 4326)

#get_quartier_nantes<-GET("https://data.nantesmetropole.fr/api/records/1.0/search/?dataset=244400404_quartiers-nantes")
#quartier_nantes<-content(get_quartier_nantes,'text')
#
#quartier_nantes_json <- fromJSON(quartier_nantes, 
#                                flatten = TRUE)$records
#

# provient de nantes métropole open data :https://data.nantesmetropole.fr/explore/dataset/244400404_quartiers-nantes/information/?disjunctive.nom&location=12,47.23826,-1.56032&basemap=jawg.streets
quartier_nantes<-st_read(dsn="extdata/quartier_nantes/244400404_quartiers-nantes.geojson")

#rm(get_dvf,dvf_content,dvf_json)

dvf_avec_quartier<-st_join(dvf,
                           quartier_nantes %>% 
                             select(nom)) %>% 
  rename(quartier=nom)
  
#ggplot()+
#  geom_sf(data=quartier_nantes)+
#  geom_sf(data=dvf_avec_quartier,
#          aes(color=nom))

stat1<-dvf_avec_quartier %>% 
  st_drop_geometry() %>% 
  filter(nature_mutation=="Vente",
         type_local %in% c("Appartement","Maison")) %>% 
  mutate(date_mutation=ymd(date_mutation),
         annee_mutation=year(date_mutation),
         nb_ventes=1) %>% 
  group_by(quartier,type_local,annee_mutation) %>% 
  summarise_at(vars(nb_ventes,valeur_fonciere,surface_relle_bati),funs(sum)) %>% 
  ungroup()


stat2<-dvf_avec_quartier %>% 
  st_drop_geometry() %>% 
  filter(nature_mutation=="Vente",
         type_local %in% c("Appartement","Maison")) %>% 
  mutate(date_mutation=ymd(date_mutation),
         annee_mutation=year(date_mutation),
         nb_ventes=1,
         type_local="Ensemble") %>% 
  group_by(quartier,type_local,annee_mutation) %>% 
  summarise_at(vars(nb_ventes,valeur_fonciere,surface_relle_bati),funs(sum)) %>% 
  ungroup()

stat<-bind_rows(stat1,stat2)

indicateurs1<-stat %>% 
  filter(type_local=="Ensemble") %>% 
  select(quartier,annee_mutation,nb_ventes)

indicateurs2<-stat %>% 
  select(quartier,annee_mutation,type_local,nb_ventes) %>% 
  spread(type_local,nb_ventes) %>% 
  mutate(pourcentage_maison=100*Maison/Ensemble) %>% 
  select(quartier,annee_mutation,pourcentage_maison)

indicateurs3<-stat %>% 
  select(quartier,annee_mutation,type_local,valeur_fonciere,surface_relle_bati) %>% 
  mutate(prix_m2=valeur_fonciere/surface_relle_bati) %>% 
  select(quartier,annee_mutation,type_local,prix_m2) %>% 
  spread(type_local,prix_m2) %>% 
  rename_at(vars(Appartement,Maison,Ensemble),funs(paste0("prix_m2_",.)))

indicateurs<-reduce(list(indicateurs1,indicateurs2,indicateurs3),left_join)

indicateurs <- quartier_nantes %>%
  select(quartier=nom) %>% 
  left_join(indicateurs)

ggplot()+
  geom_sf(data = indicateurs %>% 
            filter(annee_mutation == 2018),
          aes(fill=nb_ventes))
indicateurs$prix_m2_Maison
ggplot()+
  geom_sf(data = indicateurs %>% 
            filter(annee_mutation == 2018),
          aes(fill=prix_m2_Maison))
