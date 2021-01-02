library(R6)
library(shiny)
library(leaflet)
library(rsconnect)
#----------------------------------------------------------------------------------------------------
r_colors <- rgb(t(col2rgb(colors()) / 255))
names(r_colors) <- colors()
#----------------------------------------------------------------------------------------------------
MapApp = R6Class("MapAppClass",

    #--------------------------------------------------------------------------------
    private = list(
       proxy = NULL,
       junk = NULL,
       points = NULL,
       map = NULL,
       newPoints = function(){
         cbind(rnorm(10) * 2 + 13, rnorm(10) + 48)
         }
       ),

    public = list(
       initialize = function(){
          private$points <- private$newPoints()
          private$map <- leaflet()
          private$map <- addProviderTiles(private$map, providers$Stamen.TonerLite,
                                          options = providerTileOptions(noWrap = TRUE))
          private$map <- setView(private$map, 11.165777, 47.823265, zoom=5)
          },
       #--------------------------------------------------------------------------------
       ui = function(){
          fluidPage(
             tags$style(type = "text/css", "#mymap {width: 90%; height: calc(100vh - 100px) !important;}"),
             leafletOutput("mymap"),
             p(),
             actionButton("recalc", "New points")
             )
          }, # ui
       #--------------------------------------------------------------------------------
       server = function(input, output, session){
          output$mymap <- renderLeaflet(private$map)
          private$proxy <- leafletProxy("mymap", session)
          observeEvent(input$recalc, ignoreInit=TRUE, {
            addMarkers(private$proxy, data=private$newPoints())
            })
          } # server
       #--------------------------------------------------------------------------------
       ) # public
    ) # class
#----------------------------------------------------------------------------------------------------
app <- MapApp$new()

shinyApp(app$ui(), app$server)

