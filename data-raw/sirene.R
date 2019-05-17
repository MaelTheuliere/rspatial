library(readr)
library(sp)
library(sf)
library(ggplot2)
library(tidyverse)
load("support/data/territoires.RData")

sirene44<-read_csv("support/extdata/siren44201903/geo-sirene_44.csv") %>% 
  st_as_sf(coords = c("longitude", "latitude"), 
                 crs = 4326, agr = "constant") %>% 
  select(SIREN,APET700,APEN700,LIBAPET,LIBAPEN,NOMEN_LONG) %>% 
  st_transform(2154)
save(sirene44,file="support/data/sirene.RData")
