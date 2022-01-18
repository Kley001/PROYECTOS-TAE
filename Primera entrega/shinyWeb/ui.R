library(shiny)
library(shinythemes)
library(rsconnect)
library(leaflet)
library(sf)
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
                             column(4,
                                    h2("Presentado por:"),
                                    p("Juan Esteban Carvajal Molina"),
                                    p("Jelssin Donnovan Robledo Mena"),
                                    p("Jesús David Santos Montes"),
                                    p("Daniel Andrés Toro Aguirre"),
                                    p("Kleider Stiven Vásquez Gómez"),
                             ),
                             column(8,
                                    h1("Video explicativo web app"),
                                    HTML('<iframe width="560" height="315" src="https://www.youtube.com/embed/uLC_pkZ-x7o" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>')
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
                  
                  tabPanel("Historico",
                           fluidRow(
                             column(4,
                                    h3("Seleccione entre que años y de que tipo de accidente desea ver el historico"),
                                    sliderInput("slider_año",
                                                "Años:",
                                                min = 2014,
                                                max = 2019,
                                                value = c(2014, 2019)),
                                    selectInput("select_tipo_accidente",
                                                "Tipo de accidente:",
                                                choices = tipo_accidente),
                             ),
                             column(8,
                                    leafletOutput("Historico")
                             )
                           ),
                  ),
                  tabPanel("Prediccion", 
                           fluidRow(
                             column(4,
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
