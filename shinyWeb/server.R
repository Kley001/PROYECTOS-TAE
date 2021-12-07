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
library(plotly)

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
  
  output$Prediccion2020 <- renderPlotly({
    
    base_final$CLASE <- as.factor(as.character(base_final$CLASE))
    datos_vl <- subset(base_final, (AÑO == '2018'))
    base_final01 <- subset(base_final, (AÑO != '2018'))
    base_final02 <- subset(base_final01, (AÑO != '2019'))
    base_final03 <- subset(base_final02, (AÑO != '2020'))
    
    datos_lm4 <- base_final03 %>% group_by(FECHA, FESTIVIDAD, DIA_SEMANA, 
                                           CLASE) %>% count(name = "NRO_ACCID")
    
    lm4 <- glm(NRO_ACCID ~ FESTIVIDAD+DIA_SEMANA+CLASE, family = "poisson", 
               data = datos_lm4)
    
    datos_lm6 <- base_final03 %>% group_by(FECHA, FESTIVIDAD, SEMANA, 
                                           CLASE) %>% count(name = "NRO_ACCID")
    
    lm6 <- glm(NRO_ACCID ~ FESTIVIDAD+SEMANA+CLASE, family = "poisson", 
               data = datos_lm6)
    
    datos_lm7 <- base_final03 %>% group_by(FECHA, FESTIVIDAD, MES, 
                                           CLASE) %>% count(name = "NRO_ACCID")
    
    lm7 <- glm(NRO_ACCID ~ FESTIVIDAD+MES+CLASE, family = "poisson", 
               data = datos_lm7)
    
    Base_prediccion <- read.csv("prediccion.csv", sep = ",", encoding = "UTF-8")
    
    Base_prediccion03 <- Base_prediccion[,-4]
    Base_prediccion04 <- Base_prediccion03[,-4]
    
    if(input$select_ventana_tiempo == "Diario"){
      
      Base_prediccion_2020 <- subset(Base_prediccion, (AÑO != '2021'))
      
      Base_prediccion_2020$FECHA <- as.Date(Base_prediccion_2020$FECHA)
      Base_prediccion_2020$CLASE <- as.factor(Base_prediccion_2020$CLASE)
      Base_prediccion_2020$DIA_SEMANA <- as.factor(Base_prediccion_2020$DIA_SEMANA)
      Base_prediccion_2020$AÑO <- as.integer(Base_prediccion_2020$AÑO)
      Base_prediccion_2020$FESTIVIDAD <- as.factor(Base_prediccion_2020$FESTIVIDAD)
      
      prediccion_2020 <- predict(object = lm4, newdata = Base_prediccion_2020,
                                 type = "response")
      prediccion_diaria2020 <- Base_prediccion_2020 %>% 
        mutate(NRO_ACCID = round(prediccion_2020,0))
      
      if(input$select2_tipo_accidente == "Todos"){
        
        diario_20_02 <- prediccion_diaria2020 %>%
          group_by(FECHA, DIA_SEMANA, CLASE, FESTIVIDAD) %>%
          summarise(NRO_TOTAL_ACCID=NRO_ACCID)
        
      } else{
        
        diario_20_02 <- prediccion_diaria2020 %>%
          group_by(FECHA, DIA_SEMANA, CLASE, FESTIVIDAD) %>%
          filter(CLASE == input$select2_tipo_accidente)%>%
          summarise(NRO_TOTAL_ACCID=NRO_ACCID)
        
      }
      
      Grafico <- plot_ly(x = factor(diario_20_02$FECHA), y = diario_20_02$NRO_TOTAL_ACCID,type = "bar",marker = list(color = rgb(0, 0.5, 0.9, 1))) %>%
        layout(title = "PREDICCION ACCIDENTES 2020", xaxis = list(title = "Dia"), yaxis = list(title = "Cantidad Accidentes"))
      
    } else{
      
      Base_prediccion_2020 <- subset(Base_prediccion, (AÑO != '2021'))
      
      Base_prediccion_2020$FECHA <- as.Date(Base_prediccion_2020$FECHA)
      Base_prediccion_2020$CLASE <- as.factor(Base_prediccion_2020$CLASE)
      Base_prediccion_2020$DIA_SEMANA <- as.factor(Base_prediccion_2020$DIA_SEMANA)
      Base_prediccion_2020$AÑO <- as.integer(Base_prediccion_2020$AÑO)
      Base_prediccion_2020$FESTIVIDAD <- as.factor(Base_prediccion_2020$FESTIVIDAD)
      
      prediccion_2020 <- predict(object = lm7, newdata = Base_prediccion_2020,
                                 type = "response")
      prediccion_mensual2020 <- Base_prediccion_2020 %>% 
        mutate(NRO_ACCID = round(prediccion_2020,0))
      
      prediccion_mensual2020 <-  prediccion_mensual2020[,c(-1,-2,-3,-5,-7)]
      
      mensual_20 <- prediccion_mensual2020 %>% group_by(CLASE, MES, NRO_ACCID, FESTIVIDAD) %>% summarize(total = n())
      mensual_20 <- mutate(mensual_20, NRO_ACCID_TOTAL=NRO_ACCID*total)
      
      mensual_20_02 <- mensual_20 %>%
        group_by(MES, CLASE, FESTIVIDAD) %>%
        summarise(NRO_TOTAL_ACCID=sum(NRO_ACCID_TOTAL))
      
      if(input$select2_tipo_accidente == "Todos"){
        
        mensual_20_02 <- mensual_20 %>%
          group_by(MES, CLASE, FESTIVIDAD) %>%
          summarise(NRO_TOTAL_ACCID=sum(NRO_ACCID_TOTAL))
        
      } else{
        
        mensual_20_02 <- mensual_20 %>%
          group_by(MES, CLASE, FESTIVIDAD) %>%
          filter(CLASE == input$select2_tipo_accidente)%>%
          summarise(NRO_TOTAL_ACCID=sum(NRO_ACCID_TOTAL))
        
      }
      
      Grafico <- plot_ly(x = factor(mensual_20_02$MES), y = mensual_20_02$NRO_TOTAL_ACCID,type = "bar",marker = list(color = rgb(0, 0.5, 0.9, 1))) %>%
        layout(title = "PREDICCION ACCIDENTES 2020", xaxis = list(title = "Mes"), yaxis = list(title = "Cantidad Accidentes"))
      
    } 
    
  })
  
  output$Prediccion2021 <- renderPlotly({
    
    base_final$CLASE <- as.factor(as.character(base_final$CLASE))
    datos_vl <- subset(base_final, (AÑO == '2018'))
    base_final01 <- subset(base_final, (AÑO != '2018'))
    base_final02 <- subset(base_final01, (AÑO != '2019'))
    base_final03 <- subset(base_final02, (AÑO != '2020'))
    
    Base_prediccion <- read.csv("prediccion.csv", sep = ",", encoding = "UTF-8")
    
    if(input$select_ventana_tiempo == "Diario"){
      
      datos_lm4 <- base_final03 %>% group_by(FECHA, FESTIVIDAD, DIA_SEMANA, 
                                             CLASE) %>% count(name = "NRO_ACCID")
      
      lm4 <- glm(NRO_ACCID ~ FESTIVIDAD+DIA_SEMANA+CLASE, family = "poisson", 
                 data = datos_lm4)
      
      Base_prediccion_2021 <- subset(Base_prediccion, (AÑO != '2020'))
      
      Base_prediccion_2021$FECHA <- as.Date(Base_prediccion_2021$FECHA)
      Base_prediccion_2021$CLASE <- as.factor(Base_prediccion_2021$CLASE)
      Base_prediccion_2021$DIA_SEMANA <- as.factor(Base_prediccion_2021$DIA_SEMANA)
      Base_prediccion_2021$AÑO <- as.integer(Base_prediccion_2021$AÑO)
      Base_prediccion_2021$FESTIVIDAD <- as.factor(Base_prediccion_2021$FESTIVIDAD)
      
      prediccion_2021 <- predict(object = lm4, newdata = Base_prediccion_2021,
                                 type = "response")
      prediccion_diaria2021 <- Base_prediccion_2021 %>% 
        mutate(NRO_ACCID = round(prediccion_2021,0))
      
      diario_21_02 <- prediccion_diaria2021 %>%
        group_by(FECHA, DIA_SEMANA, CLASE, FESTIVIDAD) %>%
        summarise(NRO_TOTAL_ACCID=NRO_ACCID)
      
      if(input$select2_tipo_accidente == "Todos"){
        
        diario_21_02 <- prediccion_diaria2021 %>%
          group_by(FECHA, DIA_SEMANA, CLASE, FESTIVIDAD) %>%
          summarise(NRO_TOTAL_ACCID=NRO_ACCID)
        
      } else{
        
        diario_21_02 <- prediccion_diaria2021 %>%
          group_by(FECHA, DIA_SEMANA, CLASE, FESTIVIDAD) %>%
          filter(CLASE == input$select2_tipo_accidente)%>%
          summarise(NRO_TOTAL_ACCID=NRO_ACCID)
        
      }
      
      Grafico <- plot_ly(x = factor(diario_21_02$FECHA), y = diario_21_02$NRO_TOTAL_ACCID,type = "bar",marker = list(color = rgb(0, 0, 0, 0.8))) %>%
        layout(title = "PREDICCION ACCIDENTES 2021", xaxis = list(title = "Dia"), yaxis = list(title = "Cantidad Accidentes"))
      
    } else{
      
      datos_lm7 <- base_final03 %>% group_by(FECHA, FESTIVIDAD, MES, 
                                             CLASE) %>% count(name = "NRO_ACCID")
      
      lm7 <- glm(NRO_ACCID ~ FESTIVIDAD+MES+CLASE, family = "poisson", 
                 data = datos_lm7)
      
      Base_prediccion_2021 <- subset(Base_prediccion, (AÑO != '2020'))
      
      Base_prediccion_2021$FECHA <- as.Date(Base_prediccion_2021$FECHA)
      Base_prediccion_2021$CLASE <- as.factor(Base_prediccion_2021$CLASE)
      Base_prediccion_2021$DIA_SEMANA <- as.factor(Base_prediccion_2021$DIA_SEMANA)
      Base_prediccion_2021$AÑO <- as.integer(Base_prediccion_2021$AÑO)
      Base_prediccion_2021$FESTIVIDAD <- as.factor(Base_prediccion_2021$FESTIVIDAD)
      
      prediccion_2021 <- predict(object = lm4, newdata = Base_prediccion_2021,
                                 type = "response")
      prediccion_mensual2021 <- Base_prediccion_2021 %>% 
        mutate(NRO_ACCID = round(prediccion_2021,0))
      
      prediccion_mensual2021 <-  prediccion_mensual2021[,c(-1,-2,-3,-5,-7)]
      
      mensual_21 <- prediccion_mensual2021 %>% group_by(CLASE, MES, NRO_ACCID, FESTIVIDAD) %>% summarize(total = n())
      mensual_21 <- mutate(mensual_21, NRO_ACCID_TOTAL=NRO_ACCID*total)
      
      mensual_21_02 <- mensual_21 %>%
        group_by(MES, CLASE, FESTIVIDAD) %>%
        summarise(NRO_TOTAL_ACCID=sum(NRO_ACCID_TOTAL))
      
      if(input$select2_tipo_accidente == "Todos"){
        
        mensual_21_02 <- mensual_21 %>%
          group_by(MES, CLASE, FESTIVIDAD) %>%
          summarise(NRO_TOTAL_ACCID=sum(NRO_ACCID_TOTAL))
        
      } else{
        
        mensual_21_02 <- mensual_21 %>%
          group_by(MES, CLASE, FESTIVIDAD) %>%
          filter(CLASE == input$select2_tipo_accidente)%>%
          summarise(NRO_TOTAL_ACCID=sum(NRO_ACCID_TOTAL))
        
      }
      
      Grafico <- plot_ly(x = factor(mensual_21_02$MES), y = mensual_21_02$NRO_TOTAL_ACCID,type = "bar",marker = list(color = rgb(0, 0, 0, 0.8))) %>%
        layout(title = "PREDICCION ACCIDENTES 2021", xaxis = list(title = "Mes"), yaxis = list(title = "Cantidad Accidentes"))
      
    } 
    
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
