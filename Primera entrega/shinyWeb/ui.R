library(shiny)
library(shinythemes)
library(rsconnect)
library(leaflet)
library(sf)
library(plotly)


library(shiny)
library(leaflet)
library(sf)
library(data.table)
library(dplyr)
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

tipo_accidente <- c("Todos", "Atropello", "Caida de Ocupante", "Choque", "Incendio", 
                "Volcamiento", "Otro")

barrios <- read_sf("Limite_Barrio_Vereda_Catastral.shp")
grupos_de_barrios <- c("Todas", levels(factor(barrios$NOMBRE_COM)))

ventanas_de_tiempo <- c("Diario", "Mensual")

ui <- fluidPage(theme = shinytheme("yeti"),
                navbarPage(
                  "Accidentalidad-Medallo",
                  
                  tabPanel("Inicio",
                           fluidRow(
                             column(4,h1("Introducción:"),
                                    p("En esta aplicación web se refleja el trabajo hecho de análisis de datos de la accidentalidad en Medellín, a la derecha se presenta un video tutorial del funcionamiento del sitio, en las demás pestañas el resumen del reporte detallado al cual se puede acceder desde un link puesto en dicha pestaña, en la pestaña de predicción se hace una demostración con los años 2020 y 2021 y por último en la pestaña de agrupamiento se muestra un mapa con la accidentalidad de cada comuna de Medellín. Localmente como se aprecia en el video se puede ver un histórico de años anteriores pero este no pudo ser cargado en shinyapps por limitaciones de espacio del sitio"),
                             ),
                             column(8,
                                    h2("Video explicativo web app"),
                                    HTML('<iframe width="560" height="315" src="https://www.youtube.com/embed/uLC_pkZ-x7o" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>'),
                                    h2("Presentado por:"),
                                    p("Juan Esteban Carvajal Molina"),
                                    p("Jelssin Donnovan Robledo Mena"),
                                    p("Jesús David Santos Montes"),
                                    p("Daniel Andrés Toro Aguirre"),
                                    p("Kleider Stiven Vásquez Gómez"),
                                    
                                    # responsive HTML('<pre><div class="video-responsive"><iframe src="https://www.youtube.com/embed/dQw4w9WgXcQ?start=46" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe></div><pre>'),
                             )
                           ),
                  ),
                  
                  tabPanel("Resumen",
                           mainPanel(
                             h1("Resumen"),
                             
                             p("La accidentalidad vial en la ciudad de Medellín, es un problema estructural que limita el crecimiento económico y social, que debe ser atacado con politicas y estrategias de corto, mediano y largo plazo, en donde el gobierno, los entes privados y la academia, deben aunar esfuerzos por encontrar soluciones que beneficien a la sociedad en general."),
                             p("En el presente reporte, se busca contribuir a esas estrategías que permitan dar ideas o soluciones, para afrontar la problemática de la accidentalidad vial en la ciudad de Medellín, a través del análisis y la predicción de la accidentalidad en la ciudad, utilizando como insumo los datos proporcionados por la Alcaldía de Medellín en el portal [MeData](http://medata.gov.co/dataset/incidentes-viales), en donde se reportan los incidentes viales en la ciudad entre los años 2014 y 2020."),
                             h4("Para ver el informe completo ingrese a nuestro RPubs:"),
                             a("https://rpubs.com/santosb1205/accmedtae"),
                           ) 
                           
                  ),
                  #historico
                  tabPanel("Prediccion", 
                           fluidRow(
                             column(4,
                                    p("En esta sección se muestra la predicción de la accidentalidad para los años 2020 y 2021, usted podrá seleccionar entre dos filtros, uno de tiempo y otro por tipo de accidente, al cargar esta pestaña usted verá por defecto la predicción diaria de todos los tipos de accidente (esperando que carguen los datos) pasando el cursor por encima de la grafica podrá ver como cuantos accidentes ocurrieron en cierto tiempo seleccionado"),
                                    h3("Seleccione por tipo de accidente y ventana de tiempo para predecir"),
                                    selectInput("select_ventana_tiempo",
                                                "Tipo Prediccion:",
                                                choices = ventanas_de_tiempo),
                                    selectInput("select2_tipo_accidente",
                                                "Tipo de accidente:",
                                                choices = tipo_accidente),
                             ),
                             column(8,
                                    plotlyOutput("Prediccion2020", height = "240px", width = "660px"),
                                    plotlyOutput("Prediccion2021", height = "240px", width = "660px"),
                             )
                           ),
                  ),
                  
                  tabPanel("Agrupamiento",
                           fluidRow(
                             column(4,
                                    p("Lo que se muestra en esta pestaña es las comunas del barrio de Medellín agrupadas por su nivel de accidentalidad (se debe esperar un poco que carquen los datos), en el seleccionador de la parte inferior usted podrá seleccionar la comuna de su interés o dando click encima del mapa también podrá ver el nivel de accidentalidad del barrio por su color"),
                                    h3("Seleccione la comuna para ver caracteristicas"),
                                    #textInput("select_comuna", "Comuna:", value = c("Todas")),
                                    selectInput("select_comuna",
                                                "Comuna:",
                                                choices = grupos_de_barrios),
                             ),
                             column(8,
                                    leafletOutput("Agrupamiento"),
                             )
                           ),
                  ),
                  
                )
) 
