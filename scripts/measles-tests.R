source('scripts/partials/base.R')
source('scripts/partials/measles.R')
suppressPackageStartupMessages(devtools::load_all('BayesSpec'))
library(futile.logger)
library(matrixStats, warn.conflicts = FALSE)

printf <- function(...) cat(sprintf(...))
colProportions <- function(x) {
  colSums(x) / nrow(x)
}

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
    start = measles_settings$warm_up + 1,
    thin = measles_settings$test_thin
  )
}))

weeks <- sort(unique(observations$week))
special_weeks <- c(199601, 200301)
tvm_samples <- time_varying_mean_samples(
  samples,
  times = which(weeks %in% special_weeks),
  from = 'probabilities'
)
dimnames(tvm_samples)[[3]] <- metadata$state

tvs_samples <- time_varying_spectra_samples(
  samples,
  n_frequencies = measles_settings$test_n_frequencies,
  times = which(weeks %in% special_weeks),
  from = 'probabilities'
)

frequencies <- attr(tvs_samples, 'frequencies')
log_power_samples <- apply(tvs_samples, c(1, 3, 4), function(log_spectrum) {
  start_end <- c(1, length(log_spectrum))
  log_spectrum[start_end] <- log_spectrum[start_end] - 2
  max_log_spectrum <- max(log_spectrum)
  (
    log(sum(exp(log_spectrum - max_log_spectrum)))
    + max_log_spectrum
    + log(2) + log(frequencies[2] - frequencies[1])
  )
})
dimnames(log_power_samples)[[3]] <- metadata$state

sink(file = args$output)

printf('Posterior probability that TVM[%d] > TVM[%d]\n', special_weeks[2], special_weeks[1])
print(colProportions(tvm_samples[, 2, ] > tvm_samples[, 1, ]))

printf('Posterior mean of TVM[%d] - TVM[%d]\n', special_weeks[2], special_weeks[1])
print(colMeans(tvm_samples[, 2, ] - tvm_samples[, 1, ]))

printf('Posterior probability that log_power[%d] > log_power[%d]\n', special_weeks[2], special_weeks[1])
print(colProportions(log_power_samples[, 2, ] > log_power_samples[, 1, ]))

printf('Posterior mean of log_power[%d] - log_power[%d]\n', special_weeks[2], special_weeks[1])
print(colMeans(log_power_samples[, 2, ] - log_power_samples[, 1, ]))

sink(NULL)