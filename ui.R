library(shiny)
library(leaflet)

vars <- c(
  "Is SuperZIP?" = "superzip",
  "Centile score" = "centile",
  "College education" = "college",
  "Median income" = "income",
  "Population" = "adultpop"
)

shinyUI(fluidPage(class="outer",
  tags$head(
    includeCSS("styles.css"),
    tags$script(src="//code.jquery.com/ui/1.10.3/jquery-ui.js")
  ),
  leafletMap("map", width="100%", height="100%",
    initialTileLayer = "http://{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png",
    #initialTileLayer = NULL,
    initialTileLayerAttribution = HTML('Maps by <a href="http://www.mapbox.com/">Mapbox</a>'),
    options=list(
      center = c(37.45, -93.85),
      zoom = 4,
      maxBounds = list(list(9, -130), list(80, -38))
    )
  ),
  column(4, id = "controls", class="modal draggable",
    h2("ZIP explorer"),
    selectInput("color", "Color", vars),
    conditionalPanel("input.color == 'superzip'",
      numericInput("threshold", "SuperZIP threshold (top n percentile)", 5)
    ),
    selectInput("size", "Size", vars, selected = "Population"),
    #numericInput("scaleFactor", "Size factor", value = 50),
    plotOutput("plotCentile", height = 200),
    plotOutput("plotXY", height = 250)
  ),
  tags$script("$('.draggable').draggable();"),
  tags$div(id="cite",
    tags$cite('Data compiled for ',
      tags$em('Coming Apart: The State of White America, 1960–2010'),
      ' by Charles Murray (Crown Forum, 2012).'
    )
  )
))