library(shiny)
library(RColorBrewer)

zipdata <- readRDS("data/superzip.rds")
zipdata <- zipdata[zipdata$adultpop > 2500,]
zipdata$latitude <- jitter(zipdata$latitude)
zipdata$longitude <- jitter(zipdata$longitude)
zipdata <- zipdata[order(zipdata$income),]

shinyServer(function(input, output, session) {
  map <- createLeafletMap(session, "map")

  citiesInBounds <- reactive({
    if (is.null(input$map_bounds))
      return(zipdata[FALSE,])
    bounds <- input$map_bounds
    latRng <- range(bounds$north, bounds$south)
    lngRng <- range(bounds$east, bounds$west)
    
    subset(zipdata,
      latitude >= latRng[1] & latitude <= latRng[2] &
        longitude >= lngRng[1] & longitude <= lngRng[2])
  })
  
  breaks <- reactive({
    if (is.null(input$color))
      return(NULL)
    return(hist(plot=FALSE, zipdata[[input$color]])$breaks)
  })
  
  output$plot <- renderPlot({
    if (nrow(citiesInBounds()) == 0)
      return(NULL)
    
    hist(citiesInBounds()[[input$color]],
      breaks = breaks(),
      main = "Cities in view",
      xlab = input$color,
      xlim = range(zipdata[[input$color]]),
      col = 'green',
      border = 'white')
  })
  
  session$onFlushed(once=TRUE, function() {
    observe({
      colorBy <- input$color
      sizeBy <- input$size
      
      colors <- brewer.pal(7, "Spectral")[cut(zipdata[[colorBy]], 7, labels = FALSE)]
      
      map$clearShapes()
      map$addCircle(
        zipdata$latitude,
        zipdata$longitude,
        (zipdata[[sizeBy]] / max(zipdata[[sizeBy]])) * 1000 * input$scaleFactor,
        zipdata$zipcode,
        list(
          weight=1.2,
          stroke=TRUE,
          fill=TRUE
        ),
        list(
          color = colors
        )
      )
    })
  })
})