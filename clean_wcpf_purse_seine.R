
library(tidyverse)

# raw purse seine data
wcpfc <- read_csv("data/raw/WCPFC_S_PUBLIC_BY_1x1_QTR_FLAG.CSV")

# rename columns 
wcpfc <- wcpfc %>%
  rename(
    year = yy,
    lat = lat_short,
    lon = lon_short,
    flag = flag_id
  )


wcpfc <- wcpfc %>%
  mutate(
    num_sets = sets_una + sets_log + sets_dfad + sets_afad + sets_oth
  )


wcpfc <- wcpfc %>%
  mutate(
    skj_mt = skj_c_una + skj_c_log + skj_c_dfad + skj_c_afad + skj_c_oth,
    yft_mt = yft_c_una + yft_c_log + yft_c_dfad + yft_c_afad + yft_c_oth,
    bet_mt = bet_c_una + bet_c_log + bet_c_dfad + bet_c_afad + bet_c_oth
  )


wcpfc <- wcpfc %>%
  mutate(
    total_effort = days,
    total_catch = skj_mt + yft_mt + bet_mt
  )


wcpfc <- wcpfc %>%
  filter(
    total_effort > 0,
    total_catch > 0
  )


wcpfc <- wcpfc %>%
  mutate(
    lat_mult = ifelse(str_detect(lat, "N"), 1, -1),
    lon_mult = ifelse(str_detect(lon, "E"), 1, -1)
  )

wcpfc <- wcpfc %>%
  mutate(
    lat = lat_mult * as.numeric(str_remove_all(lat, "[:alpha:]")) + 0.5,
    lon = lon_mult * as.numeric(str_remove_all(lon, "[:alpha:]")) + 0.5
  )

# Select final columns for output
ps_clean <- wcpfc %>%
  select(
    year,
    lat,
    lon,
    flag,
    total_effort,
    total_catch
  )

# Save 
write_csv(ps_clean, "data/processed/wcpfc_purse_seine_cleaned.csv")

glimpse(ps_clean)


