source('scripts/partials/base.R')
source('scripts/partials/measles.R')
library(abind)
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
    thin = measles_settings$tvm_thin
  )
}))

flog.info('Computing TVMM')
tvm_samples <- time_varying_mean_samples(
  samples,
  time_step = measles_settings$tvm_time_step,
  from = 'probabilities'
)
tvmm <- abind(
  apply(tvm_samples, 2 : 3, mean),
  apply(tvm_samples, 2 : 3, quantile, probs = 0.1),
  apply(tvm_samples, 2 : 3, quantile, probs = 0.9),
  along = 3
)
attr(tvmm, 'times') <- attr(tvm_samples, 'times')

flog.info('Converting to data.frame')
dates <- sort(unique(observations$week_start))
tvmm_df <- bind_rows(lapply(seq_len(dim(tvmm)[2]), function(i) {
  tvmm_i <- tvmm[, i, ]
  data.frame(
    state = metadata$state[i],
    date = dates[attr(tvmm, 'times')],
    value = tvmm_i[, 1],
    lower = tvmm_i[, 2],
    upper = tvmm_i[, 3],
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
  tvmm = tvmm_df,
  metadata = metadata
), args$output)

flog.info('Done')
