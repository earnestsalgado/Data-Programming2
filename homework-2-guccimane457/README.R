library(tidyverse)
library(ggplot2)

path <- "/Users/earnestsalgado/Documents/GitHub/homework-2-guccimane457"

# Question 1 ------

# Fix first 4 rows in both files!
total <- read_csv(file.path(path, "SAEMP25N total.csv"), skip = 4)
industry <- read_csv(file.path(path, "SAEMP25N by industry.csv"), skip = 4)

# Drop extra rows, footers
industry <- filter(industry, LineCode != "NA")
total <- filter(total, GeoName != "NA")

# merge into one df
emplshare_industry <- merge(industry, total, by = "GeoFips")

# Computing values as share of total employment
# First convert df column to numeric type: 
# https://stackoverflow.com/questions/2288485/how-to-convert-a-data-frame-column-to-numeric-type
emplshare_industry[, 5:6] <- sapply(emplshare_industry[, 5:6], as.numeric)
emplshare_industry <- emplshare_industry %>% mutate(
  "2000" = round(emplshare_industry$`2000.x` / emplshare_industry$`2000.y`, 5),
  "2017" = round(emplshare_industry$`2017.x` / emplshare_industry$`2017.y`, 5))

# Drop extra columns
drop_cols = c("GeoFips",
              "GeoName.y",
              "2000.x",
              "2017.x",
              "2000.y",
              "2017.y",
              "LineCode")

emplshare_industry <- select(emplshare_industry, -one_of(drop_cols))

# Tidy Data using gather and spread: https://www.youtube.com/watch?v=1ELALQlO-yM
emplshare_industry <- emplshare_industry %>%
  gather("Year", "Employment Share", 3:4) %>%
  spread(Description, "Employment Share")

# Fix and Rename columns
emplshare_industry <- rename(
  emplshare_industry, 
  "State" = `GeoName.x`,
  "Arts_Entertain_Rec" = `Arts, entertainment, and recreation`,
  "Education" = `Educational services`,
  "Farming" = `Farm employment`,
  "Finance_Insur" = `Finance and insurance`,
  "Government" = `Government and government enterprises`,
  "Healthcare_Social" = `Health care and social assistance`,
  "Mining_Quar_Oil_Gas" = `Mining, quarrying, and oil and gas extraction`,
  "Retail" = `Retail trade`)

# save .csv to repo
output <- write.csv(
  emplshare_industry,
  "/Users/earnestsalgado/Documents/GitHub/homework-2-guccimane457/data.csv", 
  row.names = FALSE)

# Question 2A ------
# Find states with top five share of manufacturing employment in the year 2000
# Data manipulation tools: https://www.youtube.com/watch?v=Zc_ufg4uW4U
top5m <- emplshare_industry %>% 
  select("State", "Year", "Manufacturing") %>%
  spread("Year", "Manufacturing") %>%
  arrange(desc(`2000`)) %>%
  head(5) %>% 
  mutate("Change in Employment Share"= `2000` - `2017`)

# show share of employment in manufacturing change between 2000 and 2017.
top5m_change <- top5m %>%
  select(-"Change in Employment Share") %>%
  gather("Year", "Employment Share", 2:3) 

# Use a basic plot to display the information.
# http://www.sthda.com/english/wiki/ggplot2-line-plot-quick-start-guide-r-software-and-data-visualization
top5m_change %>%
  ggplot(aes(x = `Year`, y = `Employment Share`, group = `State`, 
             fill = `State`)) +
  geom_line(aes(color = `State`)) +
  geom_point(aes(color = `State`)) +
  ggtitle("States with Highest Share of Manufacturing Employment") + 
  theme(plot.title = element_text(hjust = 0.5))

# Question 2B ------

# Show states with highest concentration of employment and those industries
top5_2000_emp <- emplshare_industry %>%
  gather("Description", "Employment Share", 3:12) %>%
  arrange(desc(`Employment Share`)) %>%
  filter(`Year` == 2000)

top5_2017_emp <- emplshare_industry %>%
  gather("Description", "Employment Share", 3:12) %>%
  arrange(desc(`Employment Share`)) %>%
  filter(`Year` == 2017)

# end