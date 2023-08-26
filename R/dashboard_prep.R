# set-up data used for dashboard
# rachel bash
# 8/16/23

library(tidyr)
library(janitor)

data_path <- "data/dashboard_data"

gauge_sf <- read.csv(paste0(data_path, "/gauge_inventory.csv")) %>%
  janitor::clean_names() %>%
  st_as_sf(coords = c("longtitude", "latitude"), crs = 4326) %>%
  mutate(id = paste0(0, as.character(id))) %>%
  filter(id %in% usgs_ids)

st_write(gauge_sf, paste0(data_path, "/tidy/gauge_sf.shp"))

bdays_climate <- readRDS(paste0(data_path, "/bdays_climate_data.rds"))

# unique site names
sites <- unique(bdays_climate$name_description)

usgs_ids <- unique(bdays_climate$id)

segments <- unique(gauge_sf$closest_segment)


# read in flow data
#streamflow
flow <- read.csv("data/daily_flow_all.csv") %>%
  mutate(gauge_id = as.character(site_no))


# load American Whitewater boatable day thresholds for specific river reaches
thresholds <- read.csv(paste0(data_path, "/key_gauges.csv")) %>%
  janitor::clean_names() %>%
  # mutate(across("river", str_replace, "Green/Yampa", "Green-Yampa")) %>%
  # mutate(gauge_id = paste0(0, as.character(gauge_id))) %>%
  filter(segment %in% segments)

# join thresholds and flow together
flow_thresholds <- thresholds %>%
  left_join(flow, by = c("gauge_id")) %>%
  mutate(date = as.Date(date)) %>%
  filter(date >= "1980-01-01") %>%
  # alter name of Gunnison Delta to match map
  mutate(station_nm = case_when(station_nm == "GUNNISON RIVER AT DELTA, CO" ~ "GUNNISON RIVER AT DELTA, CO.",
                                TRUE ~ station_nm))

write.csv(flow_thresholds, paste0(data_path, "/tidy/flow_thresholds.csv"),
          row.names = FALSE)



# linreg results
# read in linreg results
linreg <- readRDS(paste0(data_path, "/linreg_all_sites_NEW.rds")) %>%
  filter(climate_var %in% c("pdsi_may", "spei1y_may", "spi1y_may"))

saveRDS(linreg, paste0(data_path, "/tidy/linreg.rds"))

best_vars <- linreg %>%
  group_by(river, site_name, segment) %>%
  summarise(best_r2 = max(r2),
            climate_var = climate_var[which(r2 == max(r2))])
