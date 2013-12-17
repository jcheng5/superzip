library(shiny)
library(leaflet)

vars <- c(
  "SuperZIP" = "superzip",
  "Centile score" = "centile",
  "College education" = "college",
  "Median income" = "income",
  "SuperZIP score" = "centile",
  "Population" = "adultpop"
)

shinyUI(fluidPage(class="outer",
  tags$head(includeCSS("styles.css")),
  fluidRow(class="map-row",
    column(8, class="map-column",
      leafletMap("map", width="100%", height="100%",
        initialTileLayer = "http://{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png",
        initialTileLayerAttribution = HTML('Maps by <a href="http://www.mapbox.com/">Mapbox</a>'),
        options=list(
          center = c(37.45, -93.85),
          zoom = 4,
          maxBounds = list(list(17, -180), list(59, 180))
        )
      )
    ),
    column(4,
      h2("ZIPs by Shiny"),
      selectInput("color", "Color", vars),
      selectInput("size", "Size", vars, selected = "Population"),
      numericInput("scaleFactor", "Size factor", value = 50),
      plotOutput("plot", height = 350),
      tags$cite('Data compiled for ',
        tags$em('Coming Apart: The State of White America, 1960–2010'),
        ' by Charles Murray (Crown Forum, 2012).')
    )
  )
))