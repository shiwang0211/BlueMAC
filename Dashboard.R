library(leaflet)
library(shiny)
library(ggplot2)
library(plotly)
source('global.R')
library(htmltools)
library(shinythemes)
library(shinydashboard)

ui <- dashboardPage(skin="black",
  dashboardHeader(title = "BlueMAC Battery"),
  dashboardSidebar(width=300,
    sidebarMenu(id = "sidebarMenu",
      menuItem("ByDevicePlot", tabName="ByDevicePlot", icon=icon("dashboard")),
      menuItem("AllDevicePlot", tabName="AllDevicePlot", icon=icon("dashboard"))
      )
  ),
  dashboardBody(
    sliderInput("datetime", "Select Day for Analysis (2016/1/1-2016/12/31)",width=1000,
                min = minDatetime,
                max = maxDatetime,
                value = minDatetime,
                timezone = "+0000", # UTC
                step = 86400,
                animate = animationOptions(interval=200)),
    tabItems(
      tabItem(tabName = "AllDevicePlot", 
              plotlyOutput("AllDevicePlots")),
      
    tabItem(tabName = "ByDevicePlot",
              selectInput("CompanyName", 
                          label = "Selected a Company",
                          choices = UniqueCompanys),
              uiOutput("DeviceIDs"),
              plotlyOutput("ByDevicePlot"))      
      )
    )
  )


server <- function(input, output, session) {
  
  output$DeviceIDs <- renderUI({
    UniqueDeviceIDs = unique(data_processed[Company == input$CompanyName,DeviceID])
    radioButtons("DeviceID", 
                 label = "Select DeviceID",
                 inline=TRUE,
                 choices = UniqueDeviceIDs)
  })
  
  output$AllDevicePlots<- renderPlotly({
    
    Data <- data_processed[ReceivedDateTime>=input$datetime  & ReceivedDateTime<=input$datetime +86400]
    p <- plot_ly(Data, x = ~ReceivedDateTime, y = ~BatteryVoltage, type = "scatter", color = ~DeviceID, mode = "lines+markers")%>%
      layout(
        title='',
        xaxis=list(
          title='Time'
        ),
        yaxis=list(
          title='BatteryVoltage'
        )
      )
    p
  
  })
  
  output$ByDevicePlot<- renderPlotly({
    
    Data <- data_processed[Company == input$CompanyName & DeviceID == input$DeviceID & ReceivedDateTime>=input$datetime & ReceivedDateTime<=input$datetime +86400]
    p <- plot_ly(Data, x = ~ReceivedDateTime, y = ~BatteryVoltage, color = ~DeviceID, type = "scatter", mode = "lines+markers")%>%
      layout(
        title='',
        xaxis=list(
          title='Time',
          gridcolor = "grey",
          range = c((as.numeric(input$datetime)+4*3600) * 1000, (as.numeric(input$datetime) +6*3600+86400) * 1000) , type="date"
        ),   # I still have to manually fix the time diff here .... All the other inputs, including time slider, are configured as UTC
        yaxis=list(
          title='BatteryVoltage'
        )
      )
      
    p
    
  })
    
  
}

shinyApp(ui, server)
