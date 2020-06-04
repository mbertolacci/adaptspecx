source('scripts/partials/base.R')
source('scripts/partials/multiple-simulation-study.R')
library(futile.logger)
library(parallel)
suppressPackageStartupMessages(devtools::load_all('BayesSpec'))

parser$add_argument('--metadata')
parser$add_argument('--samples-directory')
args <- parser$parse_args()

flog.info('Loading metadata')
metadata <- readRDS(args$metadata)

n_cores <- detectCores()
flog.info('Running on %d cores', n_cores)

output <- mclapply(1 : settings$n_replicates, function(index) {
  flog.info('[%d/%d] Loading samples', index, settings$n_replicates)
  samples_i <- window(
    readRDS(file.path(args$samples_directory, sprintf('samples-%d.rds', index))),
    start = settings$warm_up + 1,
    thin = settings$tvm_thin
  )

  flog.info('[%d/%d] Calculating TVM', index, settings$n_replicates)
  samples_subset <- samples_i
  samples_subset$design_matrix <- samples_subset$design_matrix[
    c(metadata$example_indices, (settings$n_time_series + 1) : nrow(metadata$design_matrix)),
  ]

  tvmm <- time_varying_mean_mean(samples_subset, from = 'probabilities')
  tvmq <- apply(
    time_varying_mean_samples(samples_subset, from = 'probabilities'),
    2 : 3,
    quantile,
    probs = c(0.025, 0.975)
  )

  list(
    tvmm = tvmm,
    tvmq = tvmq
  )
}, mc.cores = n_cores)

for (result in output) {
  if (inherits(result, 'try-error')) {
    print(result)
    stop('error')
  }
}

flog.info('Saving to %s', args$output)
saveRDS(output, args$output)

flog.info('Done')
