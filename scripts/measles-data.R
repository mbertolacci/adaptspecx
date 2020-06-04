source('scripts/partials/base.R')
source('scripts/partials/measles.R')
library(dplyr, warn.conflicts = FALSE)
library(lubridate, warn.conflicts = FALSE)
library(tidyr)

parser$add_argument('--measles')
parser$add_argument('--state-centroids')
args <- parser$parse_args()

measles_raw <- read.csv(args$measles, stringsAsFactors = FALSE)

year_range <- floor(range(measles_raw$week) / 100)
date_range <- as.Date(c(
  sprintf('%d-01-01', year_range[1]),
  sprintf('%d-01-01', year_range[2] + 1)
))
stopifnot(strftime(date_range[1], '%a') == 'Sun')
all_sundays <- seq(date_range[1], date_range[2], by = 'weeks')
all_weeks <- unique(100 * epiyear(all_sundays) + epiweek(all_sundays))

observations <- do.call(rbind, lapply(unique(measles_raw$state), function(state_i) {
  measles_raw_state <- measles_raw %>% filter(state == state_i)

  incidence_per_capita_full <- rep(NA, length(all_weeks))
  incidence_per_capita_full[match(
    measles_raw_state$week, all_weeks
  )] <- measles_raw_state$incidence_per_capita
  data.frame(
    week = all_weeks,
    week_start = all_sundays,
    state = state_i,
    state_name = tools::toTitleCase(tolower(measles_raw_state$state_name[1])),
    incidence_per_capita = incidence_per_capita_full,
    stringsAsFactors = FALSE
  )
})) %>%
  mutate(after_vaccine = week > measles_settings$vaccine_week) %>%
  arrange(week, state)

metadata <- read.csv(args$state_centroids, stringsAsFactors = FALSE) %>%
  slice(-1) %>%
  select(state_name = State, latitude_longitude = `Latitude..Longitude`) %>%
  filter(nchar(state_name) > 1) %>%
  separate(
    latitude_longitude,
    c('latitude', 'longitude'),
    sep = ', ',
    convert = TRUE
  ) %>%
  mutate(
    state = ifelse(
      state_name == 'DC',
      'DC',
      observations$state[match(state_name, observations$state_name)]
    )
  ) %>%
  arrange(state)

observations <- observations %>%
  filter(!(state %in% measles_settings$excluded_states))

metadata <- metadata %>%
  filter(!(state %in% measles_settings$excluded_states))

regions <- lapply(list(
  c('Connecticut', 'Maine', 'Massachusetts', 'New Hampshire', 'Rhode Island', 'Vermont'),
  c('New Jersey', 'New York'),
  c('Delaware', 'DC', 'Maryland', 'Pennsylvania', 'Virginia', 'West Virginia'),
  c('Alabama', 'Florida', 'Georgia', 'Kentucky', 'Mississippi', 'North Carolina', 'South Carolina', 'Tennessee'),
  c('Illinois', 'Indiana', 'Michigan', 'Minnesota', 'Ohio', 'Wisconsin'),
  c('Arkansas', 'Louisiana', 'New Mexico', 'Oklahoma', 'Texas'),
  c('Iowa', 'Kansas', 'Missouri', 'Nebraska'),
  c('Colorado', 'Montana', 'North Dakota', 'South Dakota', 'Utah', 'Wyoming'),
  c('Arizona', 'California', 'Hawaii', 'Nevada'),
  c('Alaska', 'Idaho', 'Oregon', 'Washington')
), function(states_names) {
  states_names[states_names %in% metadata$state_name]
})

state_name_to_state <- metadata$state
names(state_name_to_state) <- metadata$state_name

state_to_region_number <- do.call(c, lapply(1 : length(regions), function(region_number) {
  rep(region_number, length(regions[[region_number]]))
}))
names(state_to_region_number) <- do.call(c, lapply(regions, function(region) {
  na.exclude(state_name_to_state[region])
}))

state_to_region_order <- do.call(c, lapply(regions, seq_along))
names(state_to_region_order) <- names(state_to_region_number)

metadata <- metadata %>%
  mutate(
    region_number = state_to_region_number[state],
    region_order = state_to_region_order[state]
  )

saveRDS(metadata, 'intermediate/measles-metadata.rds')
saveRDS(observations, 'intermediate/measles-observations.rds')
