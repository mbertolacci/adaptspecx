source('scripts/partials/base.R')
source('scripts/partials/multiple-simulation-study.R')
library(futile.logger)
library(parallel)
suppressPackageStartupMessages(library(BayesSpec))

parser$add_argument('--metadata')
parser$add_argument('--samples-directory')
args <- parser$parse_args()

flog.info('Loading metadata')
metadata <- readRDS(args$metadata)

output <- lapply(1 : settings$n_replicates, function(index) {
  flog.info('[%d/%d] Loading samples', index, settings$n_replicates)
  samples_i <- lapply(
    readRDS(file.path(args$samples_directory, sprintf('samples-%d.rds', index))),
    window,
    start = settings$warm_up + 1,
    thin = settings$tvs_thin
  )

  simplify2array(lapply(samples_i, time_varying_spectra_mean, settings$tvs_n_frequencies))
})

flog.info('Saving to %s', args$output)
saveRDS(output, args$output)

flog.info('Done')
