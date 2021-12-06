library(shiny)
library(shinythemes)
library(rsconnect)
library(leaflet)
library(sf)

tipo_accidente <- c("Todos", "Atropello", "Caida de Ocupante", "Choque", "Incendio", 
                "Volcamiento", "Otro")

barrios <- read_sf("Limite_Barrio_Vereda_Catastral.shp")
grupos_de_barrios <- c("Todas", levels(factor(barrios$NOMBRE_COM)))

ventanas_de_tiempo <- c("Diario", "Semanal", "Mensual")

ui <- fluidPage(theme = shinytheme("yeti"),
                navbarPage(
                  "Accidentalidad-Medallo",
                  tabPanel("Prediccion", 
                           fluidRow(
                             column(4,
                                    h3("Seleccione por tipo de accidente y ventana de tiempo para predecir"),
                                    #textInput("select_comuna", "Comuna:", value = c("Todas")),
                                    selectInput("select_ventana_tiempo",
                                                "Tipo Prediccion:",
                                                choices = ventanas_de_tiempo),
                                    selectInput("select2_tipo_accidente",
                                                "Tipo de accidente:",
                                                choices = tipo_accidente),
                             ),
                             column(8,
                                    
                             )
                           ),
                           ),
                  
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
                                    HTML('<iframe width="560" height="315" src="https://www.youtube.com/embed/dQw4w9WgXcQ?start=46" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>')
                                    # responsive HTML('<pre><div class="video-responsive"><iframe src="https://www.youtube.com/embed/dQw4w9WgXcQ?start=46" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe></div><pre>'),
                             )
                           ),
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
                  
                  tabPanel("Resumen",
                           sidebarPanel(
                             tags$h3("Input:"),
                             textInput("txt1", "Given Name:", ""),
                             textInput("txt2", "Surname:", ""),
                             
                           ),
                           mainPanel(
                             h1("Header 1"),
                             
                             h4("Output 1"),
                             verbatimTextOutput("txtout"),
                             
                           ) 
                           
                  ),
                )
) 
