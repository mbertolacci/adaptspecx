source('scripts/partials/base.R')
source('scripts/partials/cabs-study.R')
library(futile.logger)
suppressPackageStartupMessages(library(BayesSpec))

piecewise_ar_tvs <- function(model, n_frequencies, n_times, time_step = 1) {
  frequencies <- seq(0, 0.5, length.out = n_frequencies)
  output <- do.call(cbind, lapply(seq_len(length(model)), function(segment) {
    spectrum_raw <- TSA::ARMAspec(
      list(ar = model[[segment]]$ar),
      freq = frequencies,
      plot = FALSE
    )
    matrix(
      rep(log(spectrum_raw$spec[, 1]), round(model[[segment]]$proportion * n_times)),
      nrow = length(frequencies)
    )
  }))
  times <- seq(1, n_times, by = time_step)
  output <- output[, times]
  attr(output, 'frequencies') <- frequencies
  attr(output, 'times') <- times
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
  piecewise_ar_tvs,
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
