source('scripts/partials/base.R')
source('scripts/partials/cabs-study.R')
library(futile.logger)
library(dplyr, warn.conflicts = FALSE)

mean_square_error <- function(x) mean(x ^ 2)

parser$add_argument('--configurations')
parser$add_argument('--tvsm-base')
args <- parser$parse_args()

flog.info('Loading configurations')
configurations <- readRDS(args$configurations)

flog.info('Calculating MSE')
mse_df <- configurations %>%
  select(
    n_times,
    n_time_series
  ) %>%
  mutate(
    mse = do.call(rbind, lapply(1 : n(), function(i) {
      tvsm <- readRDS(sprintf('%s-%d.rds', args$tvsm_base, i))
      sapply(seq_len(dim(tvsm$estimated)[4]), function(replicate) {
        mean_square_error(tvsm$estimated[, , , replicate] - tvsm$truth)
      })
    })),
    mse_mean = rowMeans(mse),
    mse_sd = matrixStats::rowSds(mse)
  )

flog.info('Saving')
saveRDS(mse_df, args$output)

flog.info('Done')
