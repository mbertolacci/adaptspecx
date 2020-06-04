source('scripts/partials/base.R')
source('scripts/partials/monthly-rainfall.R')
library(abind)
suppressPackageStartupMessages(devtools::load_all('BayesSpec'))
library(dplyr, warn.conflicts = FALSE)
library(futile.logger)
library(matrixStats, warn.conflicts = FALSE)

parser$add_argument('--observations')
parser$add_argument('--metadata')
parser$add_argument('--samples', nargs='+')
args <- parser$parse_args()

flog.info('Loading observations')
observations <- readRDS(args$observations)
metadata <- readRDS(args$metadata)

flog.info('Loading samples')
samples <- merge_samples(lapply(args$samples, function(filename) {
  window(
    readRDS(filename),
    start = monthly_rainfall_settings$warm_up + 1,
    thin = monthly_rainfall_settings$tvm_thin
  )
}))

flog.info('Calculating TVM samples')
tvm_samples <- time_varying_mean_samples(
  samples,
  from = 'probabilities'
)

flog.info('Calculating TVMM')
tvmm <- abind(
  apply(tvm_samples, 2 : 3, mean),
  apply(tvm_samples, 2 : 3, quantile, probs = 0.1),
  apply(tvm_samples, 2 : 3, quantile, probs = 0.9),
  along = 3
)
attr(tvmm, 'months') <- sort(unique(observations$month))[
  attr(tvm_samples, 'times')
]
attr(tvmm, 'dates') <- month_to_date(attr(tvmm, 'months'))

site_labels <- as.character(metadata$number)
test_point_labels <- sprintf(
  'Test point %d',
  1 : nrow(monthly_rainfall_settings$test_points)
)
tvmm_metadata <- bind_rows(
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
tvmm_df <- bind_rows(lapply(seq_len(dim(tvmm)[2]), function(i) {
  tvmm_i <- tvmm[, i, ]
  data.frame(
    label = tvmm_metadata$label[i],
    date = attr(tvmm, 'dates'),
    value = tvmm_i[, 1],
    lower = tvmm_i[, 2],
    upper = tvmm_i[, 3],
    stringsAsFactors = FALSE
  )
})) %>%
  mutate(
    label = factor(label, levels = levels(tvmm_metadata$label))
  )

flog.info('Saving to %s', args$output)
saveRDS(list(
  tvmm = tvmm_df,
  metadata = tvmm_metadata
), args$output)

flog.info('Done')
