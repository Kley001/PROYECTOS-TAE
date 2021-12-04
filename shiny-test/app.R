library(shiny)
library(shinythemes)
library(rsconnect)

ui <- fluidPage(theme = shinytheme("yeti"),
                tags$head(
                # Note the wrapping of the string in HTML()
                tags$style(HTML("<pre>
                .video-responsive {
                position: relative;
                padding-bottom: 56.25%; /* 16/9 ratio */
                padding-top: 30px; /* IE6 workaround*/
                height: 0;
                overflow: hidden;
                }
                
                .video-responsive iframe,
                .video-responsive object,
                .video-responsive embed {
                position: absolute;
                top: 0;
                left: 0;
                width: 100%;
                height: 100%;
                }</pre>"))),
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
                                    HTML('<iframe width="560" height="315" src="https://www.youtube.com/embed/dQw4w9WgXcQ?start=46" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>')
                                    # responsive HTML('<pre><div class="video-responsive"><iframe src="https://www.youtube.com/embed/dQw4w9WgXcQ?start=46" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe></div><pre>'),
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
                  tabPanel("Historico", 
                           #sidebarPanel(
                           #tags$h3("Input:"),
                           #dateInput("desde", "desde:"),
                           #dateInput("hasta", "hasta:"),
                           #dateRangeInput("fechas", label = h3("Mostrar entre")),
                           #sliderInput("range", "Age:",min = 2014, max = 2018, value = c(2014,2018)),
                           
                           #), 
                           
                           mainPanel(
                             h1("Video explicativo web app"),
                             HTML('<pre><div class="video-responsive"><iframe src="https://www.youtube.com/embed/dQw4w9WgXcQ?start=46" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe></div><pre>'),
                             
                             h4("Output 1"),
                             verbatimTextOutput("txtout"),
                             
                           ) 
                           ),
                  tabPanel("Agrupamiento", "This panel is intentionally left blank"),
                  tabPanel("Prediccion", "This panel is intentionally left blank"),
                  tabPanel("dia a dia", "This panel is intentionally left blank"),
                  
                )
) 

 
server <- function(input, output) {
  
  output$txtout <- renderText({
    paste( input$txt1, input$txt2, sep = " " )
  })
} # server


shinyApp(ui = ui, server = server)
