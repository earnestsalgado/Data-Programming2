# https://esalgado.shinyapps.io/final-project-salgadoe/
library(sf)
library(tidyverse)
library(lubridate)
library(stringr)
library(spData)
library(scales)
library(RColorBrewer)
library(shiny)
library(shinyWidgets)
library(shinythemes)
library(shinyjs)
library(plotly)
library(DT)

#setwd("/Users/earnestsalgado/Documents/GitHub/final-project-salgadoe/")

crimes <- read_csv("Crimes_tidy.csv")
crimes$Date <- as.Date(crimes$Date)

indicators <- read_csv("Chicago Health Atlas Data Download - Community areas-10-indicators.csv")
indicators_tidy <- indicators %>% 
  filter(Layer == "Community area") %>% # removed rows with descriptions 
  select(-Layer) %>% 
  rename("Community Area" = "Name")

correct_names <- c(indicators[1,7:16])
definitions <- c(indicators[2,7:16])
citations <- c(indicators[3,7:16])

for (i in 1:length(correct_names)) {
  names(indicators_tidy)[5+i] <-correct_names[i]
}
#write.csv(indicators_tidy,"Indicators_tidy.csv", row.names = FALSE)

ui <- fluidPage(# setBackgroundColor("#F5F5F5"),
  theme = shinytheme("yeti"),
  fluidRow(column(width = 3,
                  tags$a(href="https://urbanlabs.uchicago.edu/labs/crime",
                         tags$img(src="https://urbanlabs.uchicago.edu/attachments/04272a21c9b83091761b99c5fc28d716659cdabc/store/fill/800/400/1789/1275/cd25fd6dabc48d115fb28a536eabfbc948cbf5cce6180edcd002c0eaae43/3.2_UrbanLabs_Crime_Maroon.png",
                                  width = 275,
                                  height = 120))),
           column(width = 9, 
                  align = "left",
                  tags$h1("Chicago Violent Crime Statistics & Analysis - Summer 2019"),
                  tags$hr())),
  tabsetPanel(
    tabPanel(title = "Plot",
             fluidRow(column(width = 12, offset = 0.5, 
                             tags$h3("Summer 2019 Crime Types"))),
             fluidRow(column(width = 12,align = "center",
                             setSliderColor("#800000", sliderId = 1),
                             sliderInput(inputId = "sl",
                                         label = "Date range",
                                         min = min(crimes$Date)+2, 
                                         max = max(crimes$Date), 
                                         value = max(crimes$Date), 
                                         ticks = TRUE))),
             plotlyOutput("Crimes"),
             fluidRow(column(width = 3),
                      column(
                        width = 5,
                        align = "center",
                        verbatimTextOutput("crime_stats")
                      )),
             fluidRow(column(width = 3),
                      column(
                        width = 5,
                        align = "center",
                        tableOutput("crime_types")
                      ))), 
    tabPanel(title = "Data Table",
             fluidRow(column(
               width = 12,
               offset = 0.5,
               tags$h3("Summer 2019 Crime List")
             )),
             fluidRow(column(
               width = 12,
               offset = 0.5,
               tags$h5(
                 "This table displays all crimes with associated Case ID, incident and location details, and brief descriptions."
               )
             )), 
             DT::dataTableOutput("Details")),
    tabPanel(title = "Map",
             fluidRow(column(
               width = 12,
               offset = 0.5,
               tags$h3("Stress and Mental Health Indicator Choropleths - Chicago")
             )),
             fluidRow(
               column(
                 width = 6,
                 offset = 0.5,
                 tags$h5(
                   "Click the dropdown to display additional information on indicators\n of mental health by community areas, in comparison to crimes related\n to gun violence by city wards."
                 )
               ),
               column(
                 width = 6,
                 align = "center",
                 selectInput(
                   inputId = "indicators",
                   width = 400,
                   label = "What indicator do you want to compare?",
                   choices = sort(names(indicators_tidy[6:15])),
                   selected = names(indicators_tidy[12])
                 )
               )
             ),
             fluidRow(
               column(
                 width = 6,
                 align = "left",
                 plotlyOutput("Comparison_map")
               ),
               column(
                 width = 6,
                 align = "right",
                 plotlyOutput("Indicators_map")
               )
             )))
)

server <- function(input, output, session) {
  crimes_ts_guns <- crimes %>%
    filter(guns == TRUE) %>% 
    group_by(Date, `Primary Type`) %>% 
    summarise(n = n())
  
# https://stackoverflow.com/questions/22405550/r-shiny-table-with-dates  
  crimes_ts_guns$Date <- as.character(crimes_ts_guns$Date)
  data <- reactive({
    filter(crimes_ts_guns, Date > min(crimes$Date) & Date < input$sl) %>% 
      arrange(desc(n))
  })
  output$crime_types <- renderTable({data() %>% head()})
  plot <- reactive({
    crimes_ts_guns$Date <- as.Date(crimes_ts_guns$Date)
    filter(crimes_ts_guns, Date > min(crimes$Date) & Date < input$sl) %>% 
      arrange(desc(n))
  })
  table <- crimes %>% 
    select(`Case Number`, Date, Block, `Primary Type`, `Description`, 
           `Location Description`, `Arrest`, `Domestic`, `Ward`, `guns`)
  details <- reactive({
    filter(table, Date > min(crimes$Date) & Date < input$sl)
    })
  output$crime_stats <- renderPrint({summary(rnorm(input$sl))})
  output$Details <- DT::renderDataTable(table,
                                        options = list(scrollX = TRUE),
                                        rownames = FALSE)
  output$Crimes <- renderPlotly({
    ggplot(data = plot(), aes(Date,n, color = `Primary Type`)) + 
      geom_line(size = 0.3) + 
      geom_point(aes(shape = `Primary Type`), size = 0.6) +
      scale_color_brewer(palette = "Reds") +
      labs(title = "Type of Crimes Within Guns", x = "Month", y = "Crimes") +
      theme(plot.title = element_text(hjust = 0.5)) +
      theme_bw()
  })

  wards <- st_read("geo_export_879c6150-d672-4c5a-aaec-3d524dff6349.shp")
  wards$ward <- as.numeric(wards$ward)
  crimes$Ward <- as.numeric(crimes$Ward)
  
  gv_wards <- crimes %>%
    group_by(Ward) %>% 
    summarise(`Total gun violent crimes` = n()) %>%
    arrange(-desc(Ward))
  crimes_per_ward <- inner_join(
    wards, gv_wards, by = c("ward" = "Ward")) %>% 
    arrange(desc(`Total gun violent crimes`))
  
  output$Comparison_map <- renderPlotly({
    ggplot() + 
      geom_sf(data = crimes_per_ward, 
              aes(geometry = geometry, 
                  fill = `Total gun violent crimes`)) +
      theme_minimal() + 
      ggtitle("Gun Violent Crimes by Chicago Ward, 2015-2019") +
      scale_fill_gradient(low="lightcyan1", high="red3") +
      theme(plot.title = element_text(hjust = 0.5))
  })
  
  comm_areas <- st_read("geo_export_a2f0d1b0-0da6-48e2-9618-d3248e96804b.shp")
  comm_areas$community <- str_to_title(comm_areas$community)
  comm_indicators <- inner_join(comm_areas, 
                                indicators_tidy, 
                                by = c("community" = "Community Area"))
  
  output$Indicators_map <- renderPlotly({
    if (input$indicators == colnames(indicators_tidy[6])) {
      #plot for choropleth - YEARS PRODUCTIVE LIFE LOST 
      comm_indicators$`Years of Potential Life Lost (YPLL), 2013-2017` <- 
        as.numeric(comm_indicators$`Years of Potential Life Lost (YPLL), 2013-2017`)
      plt <- ggplot() +
        geom_sf(data = comm_indicators,
                aes(geometry = geometry,
                    fill = `Years of Potential Life Lost (YPLL), 2013-2017`)) +
        theme_minimal() +
        scale_fill_gradient(low = "lightcyan1", high = "red3",
                            name = "YPLL") +
        theme(
          plot.title = element_text(hjust = 0.5),
          axis.text.x = element_text(
            angle = 45,
            vjust = 0.5,
            hjust = 1
          )
        )
      #https://datascott.com/blog/subtitles-with-ggplotly/
      #https://stackoverflow.com/questions/63829972/format-position-of-title-and-subtitle-in-ggplotly
      #https://stackoverflow.com/questions/45103559/plotly-adding-a-source-or-caption-to-a-chart
      ggplotly(plt) %>%
        layout(
          margin = list(t = 30),
          title = list(
            x = 0.1,
            text = paste0(
              colnames(indicators_tidy[6]),
              '<br>',
              '<sup>',
              definitions[1],
              '</sup>'
            )
          ),
          annotations = list(
            x = 1.3,
            y = -0.2,
            text = paste("Data source:\n", citations[1],
                         sep = ""),
            showarrow = F,
            xref = 'paper',
            yref = 'paper',
            xanchor = 'right',
            yanchor = 'auto',
            xshift = 0,
            yshift = 0,
            font = list(size = 12, color = "black")
          )
        )
    } else if (input$indicators == colnames(indicators_tidy[7])) {
      #plot for choropleth - MEDIAN HOUSEHOLD INCOME
      comm_indicators$`Median household income, 2015-2019` <-
        as.numeric(comm_indicators$`Median household income, 2015-2019`)
      plt <- ggplot() +
        geom_sf(data = comm_indicators,
                aes(geometry = geometry,
                    fill = `Median household income, 2015-2019`)) +
        theme_minimal() +
        scale_fill_gradient(low = "red3", high = "lightcyan1",
                            name = "U.S. Dollars ($)") +
        theme(
          plot.title = element_text(hjust = 0.5),
          axis.text.x = element_text(
            angle = 45,
            vjust = 0.5,
            hjust = 1
          )
        )
      ggplotly(plt) %>%
        layout(
          margin = list(t = 30),
          title = list(
            x = 0.1,
            text = paste0(
              colnames(indicators_tidy[7]),
              '<br>',
              '<sup>',
              definitions[2],
              '</sup>'
            )
          ),
          annotations =
            list(
              x = 1.3,
              y = -0.2,
              text = paste("Data source:\n", citations[2],
                           sep = ""),
              showarrow = F,
              xref = 'paper',
              yref = 'paper',
              xanchor = 'right',
              yanchor = 'auto',
              xshift = 0,
              yshift = 0,
              font = list(size = 12, color = "black")
            )
        )
    } else if (input$indicators == colnames(indicators_tidy[8])) {
      #plot for choropleth - HARDSHIP INDEX
      comm_indicators$`Hardship Index (score), 2015-2019` <-
        as.numeric(comm_indicators$`Hardship Index (score), 2015-2019`)
      plt <- ggplot() +
        geom_sf(data = comm_indicators,
                aes(geometry = geometry,
                    fill = `Hardship Index (score), 2015-2019`)) +
        theme_minimal() +
        scale_fill_gradient(low = "lightcyan1", high = "red3",
                            name = "Index Score") +
        theme(
          plot.title = element_text(hjust = 0.5),
          axis.text.x = element_text(
            angle = 45,
            vjust = 0.5,
            hjust = 1
          )
        )
      ggplotly(plt) %>%
        layout(
          margin = list(t = 30),
          title = list(
            x = 0.1,
            text = paste0(
              colnames(indicators_tidy[8]),
              '<br>',
              '<sup>',
              definitions[3],
              '</sup>'
            )
          ),
          annotations =
            list(
              x = 1.3,
              y = -0.2,
              text = paste("Data source:\n", citations[3],
                           sep = ""),
              showarrow = F,
              xref = 'paper',
              yref = 'paper',
              xanchor = 'right',
              yanchor = 'auto',
              xshift = 0,
              yshift = 0,
              font = list(size = 12, color = "black")
            )
        )
    } else if (input$indicators == colnames(indicators_tidy[9])) {
      #plot for choropleth - ECONOMIC INDEX
      comm_indicators$`Economic Diversity Index, 2015-2019` <-
        as.numeric(comm_indicators$`Economic Diversity Index, 2015-2019`)
      plt <- ggplot() +
        geom_sf(data = comm_indicators,
                aes(geometry = geometry,
                    fill = `Economic Diversity Index, 2015-2019`)) +
        theme_minimal() +
        scale_fill_gradient(low = "red3", high = "lightcyan1",
                            name = "Index Score") +
        theme(
          plot.title = element_text(hjust = 0.5),
          axis.text.x = element_text(
            angle = 45,
            vjust = 0.5,
            hjust = 1
          )
        )
      ggplotly(plt) %>%
        layout(
          margin = list(t = 30),
          title = list(
            x = 0.1,
            text = paste0(
              colnames(indicators_tidy[9]),
              '<br>',
              '<sup>',
              definitions[4],
              '</sup>'
            )
          ),
          annotations =
            list(
              x = 1.3,
              y = -0.2,
              text = paste("Data source:\n", citations[4],
                           sep = ""),
              showarrow = F,
              xref = 'paper',
              yref = 'paper',
              xanchor = 'right',
              yanchor = 'auto',
              xshift = 0,
              yshift = 0,
              font = list(size = 12, color = "black")
            )
        )
    } else if (input$indicators == colnames(indicators_tidy[10])) {
      #plot for choropleth - SINGLE PARENT HOUSEHOLDS
      comm_indicators$`Single-parent households (% of households), 2015-2019` <-
        as.numeric(comm_indicators$`Single-parent households (% of households), 2015-2019`)
      plt <- ggplot() +
        geom_sf(
          data = comm_indicators,
          aes(geometry = geometry,
              fill = `Single-parent households (% of households), 2015-2019`)
        ) +
        theme_minimal() +
        scale_fill_gradient(low = "lightcyan1", high = "red3",
                            name = "% of Households") +
        theme(
          plot.title = element_text(hjust = 0.5),
          axis.text.x = element_text(
            angle = 45,
            vjust = 0.5,
            hjust = 1
          )
        )
      ggplotly(plt) %>%
        layout(
          margin = list(t = 30),
          title = list(
            x = 0.1,
            text = paste0(
              colnames(indicators_tidy[10]),
              '<br>',
              '<sup>',
              definitions[5],
              '</sup>'
            )
          ),
          annotations =
            list(
              x = 1.3,
              y = -0.2,
              text = paste("Data source:\n", citations[5],
                           sep = ""),
              showarrow = F,
              xref = 'paper',
              yref = 'paper',
              xanchor = 'right',
              yanchor = 'auto',
              xshift = 0,
              yshift = 0,
              font = list(size = 12, color = "black")
            )
        )
    } else if (input$indicators == colnames(indicators_tidy[11])) {
      #plot for choropleth - UNEMPLOYMENT RATE
      comm_indicators$`Unemployment rate (%), 2015-2019` <-
        as.numeric(comm_indicators$`Unemployment rate (%), 2015-2019`)
      plt <- ggplot() +
        geom_sf(data = comm_indicators,
                aes(geometry = geometry,
                    fill = `Unemployment rate (%), 2015-2019`)) +
        theme_minimal() +
        scale_fill_gradient(low = "lightcyan1", high = "red3",
                            name = "Percent Unemployed") +
        theme(
          plot.title = element_text(hjust = 0.5),
          axis.text.x = element_text(
            angle = 45,
            vjust = 0.5,
            hjust = 1
          )
        )
      ggplotly(plt) %>%
        layout(
          margin = list(t = 30),
          title = list(
            x = 0.1,
            text = paste0(
              colnames(indicators_tidy[11]),
              '<br>',
              '<sup>',
              definitions[6],
              '</sup>'
            )
          ),
          annotations =
            list(
              x = 1.3,
              y = -0.2,
              text = paste("Data source:\n", citations[6],
                           sep = ""),
              showarrow = F,
              xref = 'paper',
              yref = 'paper',
              xanchor = 'right',
              yanchor = 'auto',
              xshift = 0,
              yshift = 0,
              font = list(size = 12, color = "black")
            )
        )
    } else if (input$indicators == colnames(indicators_tidy[12])) {
      #plot for choropleth - POVERTY RATE
      comm_indicators$`Poverty rate (% of residents), 2015-2019` <-
        as.numeric(comm_indicators$`Poverty rate (% of residents), 2015-2019`)
      plt <- ggplot() +
        geom_sf(data = comm_indicators,
                aes(geometry = geometry,
                    fill = `Poverty rate (% of residents), 2015-2019`)) +
        scale_fill_gradient(low = "lightcyan1", high = "red3",
                            name = "% of Residents") +
        theme_minimal() +
        theme(
          plot.title = element_text(hjust = 0.5),
          axis.text.x = element_text(
            angle = 45,
            vjust = 0.5,
            hjust = 1
          )
        )
      ggplotly(plt) %>%
        layout(
          margin = list(t = 30),
          title = list(
            x = 0.1,
            text = paste0(
              colnames(indicators_tidy[12]),
              '<br>',
              '<sup>',
              definitions[7],
              '</sup>'
            )
          ),
          annotations =
            list(
              x = 1.3,
              y = -0.2,
              text = paste("Data source:\n", citations[7],
                           sep = ""),
              showarrow = F,
              xref = 'paper',
              yref = 'paper',
              xanchor = 'right',
              yanchor = 'auto',
              xshift = 0,
              yshift = 0,
              font = list(size = 12, color = "black")
            )
        )
    } else if (input$indicators == colnames(indicators_tidy[13])) {
      #plot for choropleth - POPULATION
      comm_indicators$`Population (residents), 2015-2019` <-
        as.numeric(comm_indicators$`Population (residents), 2015-2019`)
      plt <- ggplot() +
        geom_sf(data = comm_indicators,
                aes(geometry = geometry,
                    fill = `Population (residents), 2015-2019`)) +
        theme_minimal() +
        scale_fill_gradient(low = "lightcyan1", high = "red3",
                            name = "Total Residents") +
        theme(
          plot.title = element_text(hjust = 0.5),
          axis.text.x = element_text(
            angle = 45,
            vjust = 0.5,
            hjust = 1
          )
        )
      ggplotly(plt) %>%
        layout(
          margin = list(t = 30),
          title = list(
            x = 0.1,
            text = paste0(
              colnames(indicators_tidy[13]),
              '<br>',
              '<sup>',
              definitions[8],
              '</sup>'
            )
          ),
          annotations =
            list(
              x = 1.3,
              y = -0.2,
              text = paste("Data source:\n", citations[8],
                           sep = ""),
              showarrow = F,
              xref = 'paper',
              yref = 'paper',
              xanchor = 'right',
              yanchor = 'auto',
              xshift = 0,
              yshift = 0,
              font = list(size = 12, color = "black")
            )
        )
    } else if (input$indicators == colnames(indicators_tidy[14])) {
      #plot for choropleth - SUICIDE MORTALITY
      comm_indicators$`Suicide mortality (count of deaths), 2015-2019` <-
        as.numeric(comm_indicators$`Suicide mortality (count of deaths), 2015-2019`)
      plt <- ggplot() +
        geom_sf(data = comm_indicators,
                aes(geometry = geometry,
                    fill = `Suicide mortality (count of deaths), 2015-2019`)) +
        theme_minimal() +
        scale_fill_gradient(low = "lightcyan1", high = "red3",
                            name = "Count of Deaths") +
        theme(
          plot.title = element_text(hjust = 0.5),
          axis.text.x = element_text(
            angle = 45,
            vjust = 0.5,
            hjust = 1
          )
        )
      ggplotly(plt) %>%
        layout(
          margin = list(t = 30),
          title = list(
            x = 0.1,
            text = paste0(
              colnames(indicators_tidy[14]),
              '<br>',
              '<sup>',
              definitions[9],
              '</sup>'
            )
          ),
          annotations =
            list(
              x = 1.3,
              y = -0.2,
              text = paste("Data source:\n", citations[9],
                           sep = ""),
              showarrow = F,
              xref = 'paper',
              yref = 'paper',
              xanchor = 'right',
              yanchor = 'auto',
              xshift = 0,
              yshift = 0,
              font = list(size = 12, color = "black")
            )
        )
    } else if (input$indicators == colnames(indicators_tidy[15])) {
      #plot for choropleth - LIFE EXPECTANCY
      comm_indicators$`Life expectancy (years), 2019` <-
        as.numeric(comm_indicators$`Life expectancy (years), 2019`)
      plt <- ggplot() +
        geom_sf(data = comm_indicators,
                aes(geometry = geometry,
                    fill = `Life expectancy (years), 2019`)) +
        theme_minimal() +
        scale_fill_gradient(low = "red3", high = "lightcyan1",
                            name = "Years") +
        theme(
          plot.title = element_text(hjust = 0.5),
          axis.text.x = element_text(
            angle = 45,
            vjust = 0.5,
            hjust = 1
          )
        )
      ggplotly(plt) %>%
        layout(
          margin = list(t = 30),
          title = list(
            x = 0.1,
            text = paste0(
              colnames(indicators_tidy[15]),
              '<br>',
              '<sup>',
              definitions[10],
              '</sup>'
            )
          ),
          annotations =
            list(
              x = 1.3,
              y = -0.2,
              text = paste("Data source:\n", citations[10],
                           sep = ""),
              showarrow = F,
              xref = 'paper',
              yref = 'paper',
              xanchor = 'right',
              yanchor = 'auto',
              xshift = 0,
              yshift = 0,
              font = list(size = 12, color = "black")
            )
        )
    }
  })
}
shinyApp(ui = ui, server = server)
