
# Contruction de la table des départements --------------------------------

library(sf)

epci_geo<-st_read(dsn="extdata/epci/",layer="EPCI")

departements_geo<-st_read(dsn="extdata/departements/",layer="DEPARTEMENT") %>% 
  mutate(AREA=st_area(geometry))

regions_geo<-st_read(dsn="extdata/regions/",layer="REGION")


save(epci_geo,departements_geo,regions_geo,file="data/admin_express.RData")
