library(CCAMLRGIS)
library(terra)

#Load bathymetry (raw, unprojected)
B=rast("I:/Science/Projects/GEBCO/2024/Processed/GEBCO2024_LL.tif")

#Load ASDs and RBs
ASDs=load_ASDs()
RBs=load_RBs()

#Keep those of interest
ASDs=ASDs[ASDs$GAR_Short_Label=="486",]
RBs=RBs[RBs$GAR_Short_Label%in%c("486_2","486_3","486_4","486_5"),]

#Merge ASDs and RBs into one spatial object
ASDs=ASDs[,"GAR_Long_Label"] #Keep field of interest
RBs=RBs[,"GAR_Long_Label"]   #Keep field of interest

Pol=rbind(ASDs,RBs)
Pol=st_transform(Pol,4326) #Project back to Lat/Lon
plot(st_geometry(Pol))

#Compute fishable area
FishArea=seabed_area(B,Pol,PolyNames="GAR_Long_Label",depth_classes=c(-600,-1800))

#Compute percentages
FishArea$Percent=round(100*FishArea$Fishable_area/FishArea$Fishable_area[FishArea$GAR_Long_Label=="48.6"],1)

#Export
write.csv(FishArea,"FishArea.csv",row.names=F)
