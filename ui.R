library(shiny)
library(leaflet)

# Choices for drop-downs
vars <- c(
  "Is SuperZIP?" = "superzip",
  "Centile score" = "centile",
  "College education" = "college",
  "Median income" = "income",
  "Population" = "adultpop"
)


shinyUI(fluidPage(class="outer",

  tags$head(
    # Include our custom CSS
    includeCSS("styles.css"),
    # Load and initialize jQuery UI library's "draggable" behavior.
    # Any element with the class "draggable" can then be dragged by the user.
    tags$script(src="lib/jqueryui/js/jquery-ui-1.10.3.custom.min.js"),
    tags$script("$(function(){$('.draggable').draggable();});")
  ),

  leafletMap("map", width="100%", height="100%",
    initialTileLayer = "http://{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png",
    initialTileLayerAttribution = HTML('Maps by <a href="http://www.mapbox.com/">Mapbox</a>'),
    options=list(
      center = c(37.45, -93.85),
      zoom = 4,
      maxBounds = list(list(9, -130), list(80, -38)) # Show US only
    )
  ),

  column(4, id = "controls", class="modal draggable",

    h2("ZIP explorer"),

    selectInput("color", "Color", vars),
    selectInput("size", "Size", vars, selected = "Population"),
    conditionalPanel("input.color == 'superzip' || input.size == 'superzip'",
      # Only prompt for threshold when coloring or sizing by superzip
      numericInput("threshold", "SuperZIP threshold (top n percentile)", 5)
    ),

    plotOutput("histCentile", height = 200),
    plotOutput("scatterCollegeIncome", height = 250)

  ),

  tags$div(id="cite",
    'Data compiled for ', tags$em('Coming Apart: The State of White America, 1960–2010'), ' by Charles Murray (Crown Forum, 2012).'
  )
))
