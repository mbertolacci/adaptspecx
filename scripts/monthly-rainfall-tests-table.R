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

events <- list(
  list(
    name = 'WW2 drought',
    pairs = list(
      c(2, 1),
      c(2, 3)
    )
  ),
  list(
    name = 'Millenium drought',
    pairs = list(
      c(5, 4)
    )
  ),
  list(
    name = 'Long term',
    pairs = list(
      c(5, 3)
    )
  )
)

sink(file = args$output)

cat('\\bgroup\n')
cat('\\def\\arraystretch{1.2}\n')
cat('\\begin{tabular}{ll|rrrr}\n')
cat('& & \\multicolumn{4}{c}{Site ($\\uvec$)} \\\\\n')
printf(
  'Event & $\\hat{p}(\\cdot \\mid \\xvec)$ & %s \\\\ \\hline \n',
  paste(monthly_rainfall_settings$special_sites, collapse = ' & ')
)
for (event in events) {
  printf(
    '\\hline \n \\multirow{%d}{*}{%s}\n',
    2 * length(event$pairs),
    event$name
  )
  for (pair in event$pairs) {
    i <- pair[1]
    j <- pair[2]
    printf(
      '& $\\mu(\\text{%s}, \\uvec) < \\mu(\\text{%s}, \\uvec)$ & %s \\\\\n',
      special_months[i],
      special_months[j],
      paste(sprintf(
        '%.3f',
        colProportions(tvm_samples[, i, ] < tvm_samples[, j, ])
      ), collapse = ' & ')
    )
    printf(
      '& $\\sigma^2(\\text{%s}, \\uvec) < \\sigma^2(\\text{%s}, \\uvec)$ & %s \\\\\n',
      special_months[i],
      special_months[j],
      paste(sprintf(
        '%.3f',
        colProportions(log_power_samples[, i, ] < log_power_samples[, j, ])
      ), collapse = ' & ')
    )
  }
}
cat('\\end{tabular}\n')
cat('\\egroup\n')

sink(NULL)