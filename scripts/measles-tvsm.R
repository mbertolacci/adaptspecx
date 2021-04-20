source('scripts/partials/base.R')
source('scripts/partials/measles.R')
suppressPackageStartupMessages(library(BayesSpec))
library(dplyr, warn.conflicts = FALSE)
library(futile.logger)

parser$add_argument('--metadata')
parser$add_argument('--observations')
parser$add_argument('--samples', nargs='+')
args <- parser$parse_args()

flog.info('Loading observations and metadata')
observations <- readRDS(args$observations)
metadata <- readRDS(args$metadata) %>%
  mutate(
    map_row = measles_settings$state_grid[, 1],
    map_column = measles_settings$state_grid[, 2]
  )

flog.info('Loading and merging samples')
samples <- merge_samples(lapply(args$samples, function(filename) {
  flog.info('Loading %s', filename)
  window(
    readRDS(filename),
    start = measles_settings$warm_up + 1,
    thin = measles_settings$tvs_thin
  )
}))

flog.info('Computing TVSM')
dates <- sort(unique(observations$week_start))
tvsm <- time_varying_spectra_mean(
  samples,
  measles_settings$tvs_n_frequencies,
  measles_settings$tvs_time_step,
  from = 'probabilities'
)

flog.info('Converting to data.frame')
tvsm_df <- bind_rows(lapply(seq_len(dim(tvsm)[3]), function(i) {
  tvsm_i <- tvsm[, , i]
  data.frame(
    state = metadata$state[i],
    date = dates[attr(tvsm, 'times')[as.vector(col(tvsm_i))]],
    frequency = attr(tvsm, 'frequencies')[as.vector(row(tvsm_i))],
    value = as.vector(tvsm_i),
    stringsAsFactors = FALSE
  )
})) %>%
  left_join(
    metadata %>% select(
      state,
      map_row,
      map_column
    ),
    by = 'state'
  ) %>%
  left_join(
    observations %>% select(
      state,
      date = week_start,
      after_vaccine
    ),
    by = c('state', 'date')
  )

flog.info('Saving')
saveRDS(list(
  tvsm = tvsm_df,
  metadata = metadata
), args$output)

flog.info('Done')
