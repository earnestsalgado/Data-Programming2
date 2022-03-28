
library(tidyverse)
library(sf)

# Subset
# crimes <- read_csv(file = "Crimes_-_2001_to_Present.csv")

crimes_2019 <- crimes %>%
  filter(Year == 2019)

crimes_2019$Date <- as.POSIXct(strptime(crimes_2019$Date, format = "%m/%d/%Y"))

crimes_summer2019 <- crimes_2019 %>%
  filter(Date >= "2019/06/01",
         Date <= "2019/09/30")

# write_csv(crimes_summer2019, "Crimes_summer2019_.csv")
# Tidy
crimes <- read_csv(file = "Crimes_summer2019_.csv")
colSums(is.na(crimes))

crimes_drop_na <- crimes %>% 
  select(-`Updated On`) %>% 
  drop_na(`X Coordinate`, `Y Coordinate`, Ward)

crimes_gundummy <- crimes_drop_na %>% 
  mutate(guns = str_detect(crimes_drop_na$Description, "HANDGUN|GUN|FIREARM|RIFLE"))

# write_csv(crimes_gundummy, "Crimes_tidy.csv")

# Time series
crimes_ts <- crimes_gundummy %>%
  group_by(Date, guns) %>% 
  summarise(n = n())

ts_crimes <- ggplot(crimes_ts, aes(Date,n, color = guns)) + 
  geom_line()

ggsave(filename = "Time Series - Crimes.png", 
       plot = ts_crimes,
       bg = "white")

adf.test(crimes_ts$n, nlag = NULL, output = TRUE)
acf(crimes_ts$n)

# Takeaways:
# - Most of crimes does not involve guns.
# - Autocorrelation is present

crimes_ts_guns <- crimes_gundummy %>%
  filter(guns == TRUE) %>% 
  group_by(Date, `Primary Type`) %>% 
  summarise(n = n())

ggplot(crimes_ts_guns, aes(Date,n, color = `Primary Type`)) + 
  geom_line() +
  labs(title = "Type of Crimes Within Guns") +
  theme(plot.title = element_text(hjust = 0.5)) +
  theme_bw()

# Takeaways: 
# - Most of crimes that involves guns are weapons violations. 
# - Robbery comes in second place.
# - Other offenses comes in third place.
# - Assaults is the less common type.
# - Crimes which involves guns does not include other expected types, as theft or burglary

# Map
wards <- st_read("geo_export_879c6150-d672-4c5a-aaec-3d524dff6349.shp")
wards$ward <- as.numeric(wards$ward)
crimes_wards <- inner_join(crimes, wards, by = c("Ward" = "ward"))

crimes_per_ward <- crimes_wards %>%
  group_by(Ward) %>% 
  summarise(total_crimes = n())

crimes_per_ward <- inner_join(wards, crimes_per_ward, by = c("ward" = "Ward"))

ggplot() +
  geom_sf(data = crimes_per_ward, aes(geometry = geometry, 
                                      fill = total_crimes)) +
  theme_minimal() + 
  ggtitle("Crimes by Chicago Ward - Summer 2019") +
  scale_fill_gradient(low="lightblue2", high="red") +
  theme(plot.title = element_text(hjust = 0.5))



