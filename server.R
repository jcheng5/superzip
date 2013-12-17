library(shiny)
library(RColorBrewer)
library(scales)
library(lattice)

allzips <- readRDS("data/superzip.rds")
allzips$latitude <- jitter(allzips$latitude)
allzips$longitude <- jitter(allzips$longitude)
allzips$college <- allzips$college * 100
allzips$zipcode <- formatC(allzips$zipcode, width=5, format="d", flag="0")
row.names(allzips) <- allzips$zipcode

# Leaflet bindings are a bit slow; for now we'll just sample to compensate
zipdata <- allzips[sample.int(nrow(allzips), 10000),]
# By ordering by centile, we ensure that the (comparatively rare) SuperZIPs
# will be drawn last and thus be easier to see
zipdata <- zipdata[order(zipdata$centile),]

shinyServer(function(input, output, session) {

  # Create the map
  map <- createLeafletMap(session, "map")

  # A reactive expression that returns the set of zips that are
  # in bounds right now
  zipsInBounds <- reactive({
    if (is.null(input$map_bounds))
      return(zipdata[FALSE,])
    bounds <- input$map_bounds
    latRng <- range(bounds$north, bounds$south)
    lngRng <- range(bounds$east, bounds$west)
    
    subset(zipdata,
      latitude >= latRng[1] & latitude <= latRng[2] &
        longitude >= lngRng[1] & longitude <= lngRng[2])
  })
  
  # Precalculate the breaks we'll need for the two histograms
  centileBreaks <- hist(plot = FALSE, allzips$centile, breaks = 20)$breaks

  # Simple histogram
  output$plotCentile <- renderPlot({
    if (nrow(zipsInBounds()) == 0)
      return(NULL)
    
    hist(zipsInBounds()$centile,
      breaks = centileBreaks,
      main = "SuperZIP score",
      xlab = "Percentile",
      xlim = range(allzips$centile),
      col = '#00DD00',
      border = 'white')
  })
  
  output$plotXY <- renderPlot({
    if (nrow(zipsInBounds()) == 0)
      return(NULL)
    
    # hist(zipsInBounds()$income,
    #   breaks = incomeBreaks,
    #   main = "Income level",
    #   xlab = "Median household income",
    #   xlim = range(allzips$income),
    #   col = '#00DD00',
    #   border = 'white')
    # abline(v = 53.37156, col = 'red', lty = 5)
    print(xyplot(income ~ college, data = zipsInBounds(), xlim = range(allzips$college), ylim = range(allzips$income)))
  })
  
  session$onFlushed(once=TRUE, function() {
    observe({
      colorBy <- input$color
      sizeBy <- input$size

      colorData <- if (colorBy == "superzip") {
        as.numeric(allzips$centile > (100 - input$threshold))
      } else {
        allzips[[colorBy]]
      }
      colors <- brewer.pal(7, "Spectral")[cut(colorData, 7, labels = FALSE)]
      colors <- colors[match(zipdata$zipcode, allzips$zipcode)]
      
      map$clearShapes()
      map$addCircle(
        zipdata$latitude, zipdata$longitude,
        (zipdata[[sizeBy]] / max(zipdata[[sizeBy]])) * 30000,
        zipdata$zipcode,
        list(stroke=FALSE, fill=TRUE, fillOpacity=0.4),
        list(color = colors)
      )
    })
  })

  # When map is clicked, show a popup with city info
  observe({
    map$clearPopups()
    event <- input$map_shape_click
    if (is.null(event))
      return()
    
    isolate({
      selectedZip <- zipdata[zipdata$zipcode == event$id,]
      content <- as.character(tagList(
        tags$h4("Score:", as.integer(selectedZip$centile)),
        tags$strong(HTML(sprintf("%s, %s %s",
          selectedZip$city.x, selectedZip$state.x, selectedZip$zipcode
        ))), tags$br(),
        sprintf("Median household income: %s", dollar(selectedZip$income * 1000)), tags$br(),
        sprintf("Percent of adults with BA: %s%%", as.integer(selectedZip$college)), tags$br(),
        sprintf("Adult population: %s", selectedZip$adultpop)
      ))
      map$showPopup(event$lat, event$lng, content, event$id)
    })
  })
})