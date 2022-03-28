# __Question 3 (40%):__ 
# shiny url:https://esalgado.shinyapps.io/homework-2-guccimane457-1/

library(sf)
library(tidyverse)
library(stringr)
library(spData)
library(scales)
library(RColorBrewer)
library(shiny)
library(plotly)

#setwd("/Users/earnestsalgado/Documents/GitHub/homework-2-guccimane457-1/")
chi_lib <- read_csv("Libraries_-_Locations___Contact_Information__and_Usual_Hours_of_Operation.csv")

ui <- fluidPage(
  fluidRow(
    column(width = 3,
# link image: https://community.rstudio.com/t/shiny-html-image-hyperlink/49113           
           tags$a(href="https://www.chipublib.org", 
                  tags$img(src="https://www.chipublib.org/wp-content/uploads/sites/3/2016/04/CPLreverse_web_200x200.png",
                      width = 125,
                      height= 125))),
    column(width = 9,
           align = "center",
           tags$h3("Hours and Contact Information"),
           tags$hr())
  ),
  fluidRow(
    column(width = 4, align = "center",
           selectInput(inputId = "hours_contactinfo",
                       label = "Select A Library",
                       choices = chi_lib$NAME)),
    column(width = 8, align = "right",
           tableOutput("hours_contactinfo"))
  ),
  fluidRow(
    column(width = 2, offset = 2,
           align = "center",
           checkboxInput(inputId = "street",
                         label = "Toggle Streets",
                         value = FALSE)),
    column(width = 5, offset = 3,
           align = "center",
           sliderInput(inputId = "sl",
                       label = "Total Libraries per Zip Code",
                       min = 1, max = 5, value = 1, ticks = TRUE))
  ),
  fluidRow(
    column(width = 7,
           plotlyOutput("libzip")),
    column(width = 5,
           tableOutput("library_disp"))
  )
)

server <- function(input, output) {
  chicago_shape <- st_read("geo_export_b81b3a22-6fc3-4ad2-be66-ef92267ba78d.shp")
  chi_lib$ZIP <- as.numeric(chi_lib$ZIP)
  libraries_perzip <- chi_lib %>% 
    group_by(ZIP) %>% 
    summarise(`Total Libraries` = n())
  
  chicago_shape$zip <- as.numeric(chicago_shape$zip)
  chi_lib_zip <- inner_join(
    libraries_perzip, chicago_shape, by = c("ZIP" = "zip"))
  
  # adding streets layer https://data.cityofchicago.org/Transportation/Major-Streets/ueqs-5wr6
  major_sts <- st_read("Major_Streets.shp")
  st_crs(chicago_shape) == st_crs(major_sts)
  chicago_shape <- st_transform(chicago_shape, 4326)
  major_sts <- st_transform(major_sts, 4326)
  
  # Density table associated with slider
  density <- chi_lib %>% 
    select(NAME, ADDRESS, ZIP) %>%
    group_by(ZIP) %>%
    mutate(Density = n()) %>%
    arrange(-desc(NAME))
  
  # Table displaying hours and phone no.
  hrs_contactinfo <- chi_lib %>%
    select(NAME, `HOURS OF OPERATION`, PHONE)
    
  data <- reactive({
    filter(density, Density == input$sl)
  })
  
  hrs_num <- reactive({
    filter(hrs_contactinfo, NAME == input$hours_contactinfo)
  })
  
  output$hours_contactinfo <- renderTable({hrs_num()})
  div(tableOutput("hours_contactinfo"), style = "font-size: 50%")
  
  output$libzip <- renderPlotly({
    if (input$street == FALSE) {
      plt <- ggplot() + geom_sf(data = chi_lib_zip, 
                                aes(geometry = geometry, 
                                    fill = `Total Libraries`)) + 
        theme_minimal() + 
        ggtitle("Chicago Public Libraries by Zip Code") +
        scale_fill_gradient(low="lightblue2", high="red") +
        theme(plot.title = element_text(hjust = 0.5))
      ggplotly(plt)
    } else if (input$street == TRUE) {
      plt <- ggplot() + geom_sf(data = chi_lib_zip, 
                                aes(geometry = geometry, 
                                    fill = `Total Libraries`)) + 
        geom_sf(data = major_sts) + 
        theme_minimal() + 
        ggtitle("Chicago Public Libraries by Zip Code") +
        scale_fill_gradient(low="lightblue2", high="red") +
        theme(plot.title = element_text(hjust = 0.5))
      ggplotly(plt)
    }
  })
  output$library_disp <- renderTable({data()})
  div(tableOutput("library_disp"), style = "font-size: 50%")
}

shinyApp(ui = ui, server = server)

# end