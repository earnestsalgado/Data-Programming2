library(tidyverse)

# First, subsetting dataset 1: Crimes 

crimes <- read_csv(file = "Crimes_-_2001_to_Present.csv")

crimes_2019 <- crimes %>%
  filter(Year == 2019)

crimes_2019$Date <- as.POSIXct(strptime(crimes_2019$Date, format = "%m/%d/%Y"))

crimes_summer2019 <- crimes_2019 %>%
  filter(Date >= "2019/06/01",
         Date <= "2019/09/30")

write_csv(crimes_summer2019, "Crimes_summer2019_.csv")
