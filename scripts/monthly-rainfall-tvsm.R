source('scripts/partials/base.R')
source('scripts/partials/monthly-rainfall.R')

suppressPackageStartupMessages(library(BayesSpec))
library(dplyr, warn.conflicts = FALSE)
library(futile.logger)

parser$add_argument('--observations')
parser$add_argument('--metadata')
parser$add_argument('--samples', nargs='+')
args <- parser$parse_args()

flog.info('Loading data')
observations <- readRDS(args$observations)
metadata <- readRDS(args$metadata)

flog.info('Loading samples')
samples <- merge_samples(lapply(args$samples, function(filename) {
  flog.info('Loading %s', filename)
  window(
    readRDS(filename),
    start = monthly_rainfall_settings$warm_up + 1,
    thin = monthly_rainfall_settings$tvs_thin
  )
}))

flog.info('Calculating TVSM')
tvsm <- time_varying_spectra_mean(
  samples,
  monthly_rainfall_settings$tvs_n_frequencies,
  monthly_rainfall_settings$tvs_time_step,
  from = 'probabilities'
)
attr(tvsm, 'months') <- sort(unique(observations$month))[
  attr(tvsm, 'times')
]
attr(tvsm, 'dates') <- month_to_date(attr(tvsm, 'months'))

site_labels <- as.character(metadata$number)
test_point_labels <- sprintf(
  'Test point %d',
  1 : nrow(monthly_rainfall_settings$test_points)
)
tvsm_metadata <- bind_rows(
  metadata %>%
    mutate(
      label = as.character(number)
    ) %>%
    select(
      label,
      longitude,
      latitude
    ),
  data.frame(
    label = test_point_labels,
    longitude = monthly_rainfall_settings$test_points[, 1],
    latitude = monthly_rainfall_settings$test_points[, 2],
    stringsAsFactors = FALSE
  )
) %>%
  mutate(
    label = factor(label, levels = c(site_labels, test_point_labels))
  )

flog.info('Converting to data.frame')
tvsm_df <- bind_rows(lapply(seq_len(dim(tvsm)[3]), function(i) {
  tvsm_i <- tvsm[, , i]
  data.frame(
    label = tvsm_metadata$label[i],
    date = attr(tvsm, 'dates')[as.vector(col(tvsm_i))],
    frequency = attr(tvsm, 'frequencies')[as.vector(row(tvsm_i))],
    log_spectrum = as.vector(tvsm_i),
    stringsAsFactors = FALSE
  )
})) %>%
  mutate(
    label = factor(label, levels = levels(tvsm_metadata$label))
  )

flog.info('Saving to %s', args$output)
saveRDS(list(
  tvsm = tvsm_df,
  metadata = tvsm_metadata
), args$output)

flog.info('Done')
