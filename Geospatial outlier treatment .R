install.packages("sp")
install.packages("maps")
install.packages("rgeos")
install.packages("maptools")
require(sp)
require(maps)
library(rgeos)
library(maptools)
library(RODBC)
myconn=odbcConnect("VerticaDB",uid="username",pwd="password")
#data<- sqlQuery(myconn, "select * from TABLE.DRIVER_GPS_LOCATION;")
#data<- sqlQuery(myconn, "select gps_longitude_number, gps_latitude_number from TABLE.DRIVER_GPS_LOCATION;")
data<- sqlQuery(myconn, "select gps_longitude_number, gps_latitude_number from TABLE.DRIVER_GPS_LOCATION_duplicate where NTile=1;")
data<- sqlQuery(myconn, "select gps_longitude_number, gps_latitude_number from TABLE.DRIVER_GPS_LOCATION_duplicate where NTile=2;")
data<- sqlQuery(myconn, "select gps_longitude_number, gps_latitude_number from TABLE.DRIVER_GPS_LOCATION_duplicate where NTile=3;")
data1=data
coordinates(data) <- c("gps_longitude_number", "gps_latitude_number")

shp <- file.path("/data/TABLE_data/StatPlanet_USA_County/map","map.shp")

shp <- file.path("/home/manickra/StatPlanet_USA_County/map","map.shp")
map <- readShapeSpatial(shp, proj4string = CRS("+init=epsg:25832"))
proj4string(data) <- proj4string(map)

inside.USA <- !is.na(over(data, as(map, "SpatialPolygons")))

#subset
final=cbind(data1,inside.USA)
rm(data1)

final1=subset(final,inside.USA=="FALSE")
final2=subset(final,inside.USA=="TRUE")

canada1=final1
shp2 <- file.path("/home/manickra/StatPlanet_USA_County/map","gpr_000b11a_e.shp")
shp2 <- file.path("/data/TABLE_data","gpr_000b11a_e.shp")
map2 <- readShapeSpatial(shp2, proj4string = CRS("+init=epsg:25832"))

coordinates(final1) <- c("gps_longitude_number", "gps_latitude_number")
proj4string(final1) <- proj4string(map2)

inside.canada <- !is.na(over(final1, as(map2, "SpatialPolygons")))

final3=cbind(canada1,inside.canada)
final2$inside.canada="FALSE"
new=rbind(final2,final3)



###################### Saving the table in vertica################################
#sqlSave(myconn, new, tablename = "TABLE.drivdist_ntil1overall", append = FALSE)
#sqlSave(myconn, new, tablename = "TABLE.drivdist_ntil2overall", append = FALSE)

#sqlSave(myconn, final, tablename = "TABLE.finaldriverdistance_outtreat", append = FALSE)
#sqlSave(myconn, final, tablename = "TABLE.drivdist_outtreat_USAonly2", append = FALSE)



#save(data1, file = "mymodel.Rdata")
#save(final, file = "mymodel2.Rdata")
#load("mymodel2.Rdata")
#identical(mod, e$mod, ignore.environment = TRUE)



#/opt/vertica/R/bin/R

#sqlSave(myconn, final, tablename = "TABLE.drivdist_outtreat_USAonly", append = FALSE)
 
#load("/home/manickra/ntile3usa.Rdata")
 
 #save(final, file = "/home/manickra/ntile1usa.Rdata")
 #save(final, file = "/home/manickra/ntile2usa.Rdata")
 #save(final, file = "/home/manickra/ntile3usa.Rdata")
 
#save(new, file = "/home/manickra/ntile2overall.Rdata")
#save(new, file = "/home/manickra/ntile1overall.Rdata")

#save(final, file = "/home/manickra/ntile1outlierUSA.Rdata")
#save(final3, file = "/home/manickra/ntile1outlierUSAcanada.Rdata")
#load("/home/manickra/ntile1outlierUSA.Rdata")


#################################map url################################################################
#wget http://www.statsilk.com/files/software/StatPlanet_USA_County.zip
#wget  http://www12.statcan.gc.ca/census-recensement/2011/geo/bound-limit/files-fichiers/gpr_000b11a_e.zip
#unzip StatPlanet_USA_County.zip
#unzip gpr_000b11a_e.zip