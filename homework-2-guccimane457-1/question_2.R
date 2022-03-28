# Data Skills 2 - R
## Winter Quarter 2022, Homework 2

library(sf)
library(tidyverse)
library(stringr)
library(spData)
library(scales)
library(RColorBrewer)

# Examining Chicago Public Libraries per zipcode
# https://data.cityofchicago.org/Education/Libraries-Locations-Contact-Information-and-Usual-/x8fc-8rcq
path <- "/Users/earnestsalgado/Documents/GitHub/homework-2-guccimane457-1/"

chi_lib <- read_csv(file.path(path, "Libraries_-_Locations___Contact_Information__and_Usual_Hours_of_Operation.csv"))
chicago_shape <- st_read(file.path(path, "geo_export_b81b3a22-6fc3-4ad2-be66-ef92267ba78d.shp"))

# format zip codes
chi_lib$ZIP <- as.numeric(chi_lib$ZIP)
libraries_perzip <- chi_lib %>% 
  group_by(ZIP) %>% 
  summarise(`Total Libraries` = n())

chicago_shape$zip <- as.numeric(chicago_shape$zip)
chi_lib_zip <- inner_join(libraries_perzip, chicago_shape, by = c("ZIP" = "zip"))

#plot for choropleth
ggplot() +
  geom_sf(data = chi_lib_zip, aes(geometry = geometry, 
                                  fill = `Total Libraries`)) +
  theme_minimal() + 
  ggtitle("Chicago Public Libraries by Zip Code") +
  scale_fill_gradient(low="lightblue2", high="red") +
  theme(plot.title = element_text(hjust = 0.5))

# Examining Possible Food Deserts by number of grocery stores per zipcode
# https://data.cityofchicago.org/Health-Human-Services/Grocery-Store-Status/3e26-zek2
groc_stores <- read_csv(file.path(path, "Grocery_Store_Status.csv")) %>% 
  filter(`New status` == "OPEN")

# format zip codes
groc_stores$Zip <- groc_stores$Zip <- strtrim(groc_stores$Zip , 5) %>% 
  replace_na('60804') %>%
  as.numeric(groc_stores$Zip)

stores_perzip <- groc_stores %>% 
  group_by(Zip) %>% 
  summarise(`Total Grocery Stores` = n())

chi_groc_zip <- inner_join(stores_perzip, chicago_shape, by = c("Zip" = "zip"))

#plot for choropleth
ggplot() +
  geom_sf(data = chi_groc_zip, aes(geometry = geometry, 
                                  fill = `Total Grocery Stores`)) +
  theme_minimal() + 
  ggtitle("Chicago Grocery Stores by Zip Code") +
  scale_fill_gradient(low="navy", high="yellow") +
  theme(plot.title = element_text(hjust = 0.5))

# end