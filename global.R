library(leaflet)
library(shiny)
library(ggplot2)
library(plotly)
library(data.table)

load("./rda/SampleData.rda")

# Convert All Times Into UTC to avoid displaying issues
if(FALSE){
data<-fread("../data/BlueMAC_SampleData_Export170114.txt",sep=",")
date_time = as.POSIXct(data$ReceivedDateTime, format = "%Y-%m-%d %H:%M:%S",tz="GMT") #create time
data_processed = data[,.(ClientDeviceID, DeviceID, Company,  BatteryVoltage, Temperature)][,ReceivedDateTime:=date_time][order(ReceivedDateTime)]
save(data_processed,file="./rda/SampleData.rda");
}

minDatetime = as.POSIXct("2016-01-01 00:00:00",format = "%Y-%m-%d %H:%M:%S",tz="GMT")
maxDatetime = as.POSIXct("2016-12-31 23:59:59",format = "%Y-%m-%d %H:%M:%S",tz="GMT")
data_processed = data_processed[BatteryVoltage != "" &  ReceivedDateTime >= minDatetime & ReceivedDateTime <= maxDatetime]
UniqueCompanys = unique(data_processed[["Company"]])
