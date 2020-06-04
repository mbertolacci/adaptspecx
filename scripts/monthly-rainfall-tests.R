source('scripts/partials/base.R')
source('scripts/partials/monthly-rainfall.R')
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
    start = monthly_rainfall_settings$warm_up + 1,
    thin = monthly_rainfall_settings$test_thin
  )
}))

months <- unique(observations$month)
special_months <- c('1930-01', '1940-01', '1950-01', '1990-01', '2004-01')
samples_subset <- samples
samples_subset$design_matrix <- samples$design_matrix[
  metadata$number %in% monthly_rainfall_settings$special_sites,
]
tvm_samples <- time_varying_mean_samples(
  samples_subset,
  times = which(months %in% special_months),
  from = 'probabilities'
)
dimnames(tvm_samples)[[3]] <- as.character(monthly_rainfall_settings$special_sites)

for_each_pair <- function(fn) {
  for (i in 1 : (length(special_months) - 1)) {
    for (j in (i + 1) : length(special_months)) {
      fn(i, j)
      cat('------\n')
    }
  }
}

probabilities <- c(0.025, 0.1, 0.5, 0.9, 0.975)

sink(file = args$output)

cat('=======\n')
cat('Posterior probability that mean at date 1 is greater than mean at date2 (at the given location):\n')
for_each_pair(function(i, j) {
  printf('Pr(mean[%s] > mean[%s]) =\n', special_months[i], special_months[j])
  print(colProportions(tvm_samples[, i, ] > tvm_samples[, j, ]))
})

cat('=======\n')
cat('Posterior mean and quantiles of mean at date 1 minus mean at date2 (at the given location):\n')
for_each_pair(function(i, j) {
  printf('p(mean[%s] - mean[%s]) =\n', special_months[i], special_months[j])
  print(cbind(
    mean = colMeans(tvm_samples[, i, ] - tvm_samples[, j, ]),
    colQuantiles(tvm_samples[, i, ] - tvm_samples[, j, ], probs = probabilities)
  ))
})

tvs_samples <- time_varying_spectra_samples(
  samples_subset,
  n_frequencies = monthly_rainfall_settings$test_n_frequencies,
  times = which(months %in% special_months),
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
dimnames(log_power_samples)[[3]] <- as.character(monthly_rainfall_settings$special_sites)

cat('=======\n')
cat('Posterior probability that total log power at date 1 is greater than total log power at date2 (at the given location):\n')
for_each_pair(function(i, j) {
  printf('Pr(log_power[%s] > log_power[%s]) =\n', special_months[i], special_months[j])
  print(colProportions(log_power_samples[, i, ] > log_power_samples[, j, ]))
})

cat('=======\n')
cat('Posterior mean and quantiles of log_power at date 1 minus log_power at date2 (at the given location):\n')
for_each_pair(function(i, j) {
  printf('p(log_power[%s] - log_power[%s]) =\n', special_months[i], special_months[j])
  print(cbind(
    mean = colMeans(log_power_samples[, i, ] - log_power_samples[, j, ]),
    colQuantiles(log_power_samples[, i, ] - log_power_samples[, j, ], probs = probabilities)
  ))
})

sink(NULL)