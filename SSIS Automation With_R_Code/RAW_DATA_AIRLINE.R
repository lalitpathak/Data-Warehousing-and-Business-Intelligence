# code to create RAW_DIM_AIRLINE
library(dplyr)
setwd("C:\\Users\\MOLAP\\Documents\\R")
RAW_DATA_AIRPORT<-read.csv("Raw_DATA_AVIATION.csv")
RAW_DATA_AIRLINE<-distinct(RAW_DATA_AIRPORT[,c(2:4)])
colnames(RAW_DATA_AIRLINE)<-c("AIRLINE_ID","CARRIER_CODE","CARRIER_NAME")
write.csv(RAW_DATA_AIRLINE,"RAW_DATA_AIRLINE.CSV",row.names=FALSE)