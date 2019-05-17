
# Contruction de la table des départements --------------------------------

library(sf)

epci_geo<-st_read(dsn="support/extdata/adminexpress/",layer="EPCI")

departements_geo<-st_read(dsn="support/extdata/adminexpress/",layer="DEPARTEMENT") %>% 
  mutate(AREA=st_area(geometry))

regions_geo<-st_read(dsn="support/extdata/adminexpress/",layer="REGION")

save(epci_geo,departements_geo,regions_geo,file="support/data/territoires.RData")
