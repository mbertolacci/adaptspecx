source('scripts/partials/base.R')
source('scripts/partials/multiple-simulation-study.R')

set.seed(20180821)

parser$add_argument('--metadata')
args <- parser$parse_args()

generate_piecewise_ar <- function(model, n_times) {
  do.call(c, lapply(1 : length(model), function(i) {
    model[[i]]$mean + arima.sim(
      model = model[[i]]$arima_model,
      n = round(model[[i]]$proportion * n_times)
    )
  }))
}

metadata <- readRDS(args$metadata)

replicates <- lapply(1 : settings$n_replicates, function(i) {
  observations <- matrix(0, nrow = settings$n_times, ncol = settings$n_time_series)
  for (index in 1 : settings$n_time_series) {
    observations[, index] <- generate_piecewise_ar(
      settings$components[[metadata$category[index]]],
      settings$n_times
    )
    observations[
      sample.int(
        settings$n_times,
        round(settings$n_times * settings$proportion_missing)
      ),
      index
    ] <- NA
  }

  observations
})

saveRDS(replicates, args$output)
