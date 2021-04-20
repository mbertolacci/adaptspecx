source('scripts/partials/base.R')
source('scripts/partials/cabs-study.R')
library(futile.logger)
suppressPackageStartupMessages(library(BayesSpec))

slow_ar_tvs <- function(model, n_frequencies, n_times, time_step = 1) {
  frequencies <- seq(0, 0.5, length.out = n_frequencies)

  output <- matrix(
    NA,
    ncol = n_times / time_step,
    nrow = n_frequencies
  )
  for (i in seq_len(n_times / time_step)) {
    ar_i <- model$a + model$b * (time_step * (i - 1) + 1) / n_times
    spectrum_raw <- TSA::ARMAspec(
      list(ar = ar_i),
      freq = frequencies,
      plot = FALSE
    )
    output[, i] <- log(spectrum_raw$spec[, 1])
  }
  attr(output, 'frequencies') <- frequencies
  attr(output, 'times') <- seq(1, n_times, by = time_step)
  output
}

parser$add_argument('--samples-directory')
parser$add_argument('--configurations')
parser$add_argument('--configuration-number', type = 'integer')
args <- parser$parse_args()

log_info <- function(fmt, ...) {
  flog.info(
    paste0('[%d] ', fmt),
    args$configuration_number,
    ...
  )
}

log_info('Loading configurations')
configurations <- readRDS(args$configurations)

models <- configurations$models[[args$configuration_number]]
n_times <- configurations$n_times[args$configuration_number]
n_replicates <- dim(configurations$y_replicates[[args$configuration_number]])[3]

time_step <- n_times / 100

rm(configurations)
gc()

tvs_true <- abind::abind(lapply(
  models,
  slow_ar_tvs,
  cabs_study_settings$n_frequencies,
  n_times,
  time_step
), along = 3)

log_info('Computing TVSMs')
tvsm <- abind::abind(lapply(seq_len(n_replicates), function(replicate) {
  samples <- window(
    readRDS(file.path(args$samples_directory, sprintf(
      'samples-%d-%d.rds',
      args$configuration_number,
      replicate
    ))),
    start = cabs_study_settings$warm_up + 1,
    thin = cabs_study_settings$thin
  )
  time_varying_spectra_mean(
    samples,
    cabs_study_settings$n_frequencies,
    time_step
  )
}), along = 4)

log_info('Saving to %s', args$output)
saveRDS(list(
  truth = tvs_true,
  estimated = tvsm
), args$output)

log_info('Done')
