library(shiny)
library(leaflet)
library(sf)
library(data.table)
library(dplyr)
library(lubridate)
library(ggplot2)
library(raster)
library(rgdal)
require(factoextra)
library(stringr)
library(readxl)
library(GGally)
library(car)
library(MLmetrics)
library(wordcloud)
library(gplots)
library(R.utils)
library(tm)
library(DescTools)
library(mclust)
library(geosphere)
library(NbClust)
library(vegan)
library(qpcR)

# Define server logic required to draw a histogram
server <- function(input, output){
  
  base_final <- read.csv("base_final.csv", encoding="UTF-8")
  
  #catastral <- read.csv("Limite_Barrio_Vereda_Catastral.csv", encoding="UTF-8")
  
  #barrio_vereda <- read.csv("Barrio_Vereda_2014.csv", encoding="UTF-8")
  
  catastral <- read.csv("Limite_Barrio_Vereda_Catastral.csv", encoding="UTF-8")
  
  catastro <- read_sf("Limite_Barrio_Vereda_Catastral.shp")
  
  barrio_vereda <- read.csv("Barrio_Vereda_2014.csv", encoding="UTF-8")
  
  output$Historico <- renderLeaflet({
  
    Unido <- inner_join(catastral, base_final, by = c("COMUNA" = "NUMCOMUNA"))
    
    if(input$select_tipo_accidente == "Todos"){
      nueva_base <- Unido %>% filter(AÑO >= input$slider_año[1] & AÑO <= input$slider_año[2]) %>% 
        group_by(CODIGO) %>%
        summarise(accidentes = n()) %>%
        ungroup()
    }
    else{
      nueva_base <- Unido %>% filter(AÑO >= input$slider_año[1] & AÑO <= input$slider_año[2], CLASE == input$select_tipo_accidente ) %>% 
        group_by(CODIGO) %>%
        summarise(accidentes = n()) %>%
        ungroup()
      
    }
    
    catastro$CODIGO <- as.numeric(as.character(catastro$CODIGO))
    
    mapa <- inner_join(catastro, nueva_base, by = c("CODIGO" = "CODIGO"))
    
    mypal <- colorNumeric(palette = c("#000000","#280100","#3D0201","#630201","#890100","#B00100","#DD0100","#F50201",
                                      "#FF5F5E","#FF7A79","#FF9796","#FEB1B0","#FDC9C8", "#FFE5E4"), domain = mapa$accidentes, reverse = T)
    
    leaflet() %>% addPolygons(data = mapa, color = "#0A0A0A", opacity = 0.6, weight = 1, fillColor = ~mypal(mapa$accidentes),
                              fillOpacity = 0.6, label = ~NOMBRE_BAR,
                              highlightOptions = highlightOptions(color = "black", weight = 3, bringToFront = T, opacity = 1),
                              popup = paste("Barrio: ", mapa$NOMBRE_BAR, "<br>", "Accidentes: ", mapa$accidentes, "<br>")) %>%
      addProviderTiles(providers$OpenStreetMap) %>%
      addLegend(position = "bottomright", pal = mypal, values = mapa$accidentes, title = "Accidentes", opacity = 0.6)
    })
  
  
  
  
  
  
  
  
  
  output$Agrupamiento <- renderLeaflet({
      
    basemapa <- read_excel("basemapa.xlsx")
    base_mapa <- data_frame(basemapa)
    
    catastro$CODIGO <- as.numeric(as.character(catastro$CODIGO))
    base_mapa$Codigo <- as.numeric(as.character(base_mapa$Codigo))
    
    if(input$select_comuna == "Todas"){mapa02 <- inner_join(catastro, base_mapa, by = c("CODIGO" = "Codigo"))}
    else{mapa02 <- inner_join(catastro, base_mapa, by = c("CODIGO" = "Codigo")) %>% filter(NOMBRE_COM == input$select_comuna)}
    
    colorgrupos <- c("#00FF66", "#CCFF00", "#FF0000", "#0066FF")
    mapa02$colores <- ifelse(mapa02$kmm.cluster == "1", "#00FF66",
                             ifelse(mapa02$kmm.cluster == "2", "#CCFF00",
                                    ifelse(mapa02$kmm.cluster == "3", "#FF0000",
                                           ifelse(mapa02$kmm.cluster == "4", "#0066FF",0))))
    
    leaflet() %>% addPolygons(data = mapa02, opacity = 0.4, color = "#545454",weight = 1, fillColor = mapa02$colores,
                              fillOpacity = 0.4, label = ~NOMBRE_BAR,
                              highlightOptions = highlightOptions(color = "#262626", weight = 3, bringToFront = T, opacity = 1),
                              popup = paste("Barrio: ", mapa02$NOMBRE_BAR, "<br>", "Grupo: ", mapa02$kmm.cluster, "<br>", "N?mero de Accidentes con heridos: ", mapa02$Con_heridos, "<br>", "N?mero de Accidentes con muertos: ", mapa02$Con_muertos, "<br>", "N?mero de Accidentes con solo da?os: ", mapa02$Solo_danos)) %>%
      addProviderTiles(providers$OpenStreetMap) %>%
      addLegend(position = "bottomright", colors = colorgrupos, labels = c("Grupo 1: Accidentalidad Moderada", "Grupo 2: Accidentalidad Baja", "Grupo 3: Accidentalidad Alta", "Grupo 4: Accidentalidad Media-Alta"))
    
  })
  
  
}
