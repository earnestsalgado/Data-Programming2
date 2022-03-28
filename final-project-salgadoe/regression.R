library(lubridate)
library(tidyverse)
library(stargazer)

crimes <- read_csv(file = "Crimes_tidy.csv")

crimes <- crimes %>%
  mutate(month = as.factor(month(crimes$Date)),
         year = as.factor(year(crimes$Date)),
         ward = as.factor(crimes$Ward),
         arrest = crimes$Arrest)

crimes_sub <- crimes %>% 
  select(month, guns, arrest, ward) %>% 
  group_by(month, guns, arrest, ward) %>% 
  summarise(cases = n())

crimes_ols <- lm(cases ~ ., data = crimes_sub)

stargazer(crimes_ols, type = "html", out = "fit_lm.html")
