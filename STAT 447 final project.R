library(rstan)
library(dplyr)
library(tidyr)


df <- read.csv("v50_PM10_1970_2015 (1)(TOTALS BY COUNTRY).csv") %>%
  # Remove all auto-generated empty columns
  select(-matches("^X(\\.?\\d+)?$")) %>%
  # Convert and pivot
  mutate(across(starts_with("Y_"), as.numeric)) %>%
  pivot_longer(
    cols = starts_with("Y_"),
    names_to = "year",
    values_to = "pm25",
    values_drop_na = TRUE
  )

stan_data <- list(
  N = nrow(df),
  n_years = length(grep("^Y_", names(df))),
  pm25 = as.matrix(select(df, starts_with("Y_"))),
  annex = ifelse(df$IPCC.Annex == "Annex_I", 1, 0),
  country_id = as.numeric(factor(df$ISO_A3)),
  region_id = as.numeric(factor(df$World.Region)),
  J = length(unique(df$ISO_A3)),
  K = length(unique(df$World.Region))
)

# Center years (1970-2015 becomes 0-45)
years <- as.numeric(gsub("Y_", "", grep("^Y_", names(df), value = TRUE)))
stan_data$year_c <- years - min(years)

spatial_model <- stan(
  file = "spatial_model_rao.stan",
  data = stan_data,
  chains = 4,
  iter = 2000,  # 400 total iterations (200 warmup + 200 sampling)
)

print(spatial_model, pars = c("alpha", "beta_year", "beta_annex", "beta_interaction"))