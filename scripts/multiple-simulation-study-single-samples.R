source('scripts/partials/base.R')
source('scripts/partials/multiple-simulation-study.R')
library(futile.logger)
library(parallel)
suppressPackageStartupMessages(library(BayesSpec))

parser$add_argument('--metadata')
parser$add_argument('--replicates')
parser$add_argument('--replicate-number', type = 'integer')
args <- parser$parse_args()

log_info <- function(fmt, ...) {
  flog.info(
    paste0('[%d/%d] ', fmt),
    args$replicate_number,
    settings$n_replicates,
    ...
  )
}

log_info('Loading metadata')
metadata <- readRDS(args$metadata)

log_info('Loading replicates')
replicates <- readRDS(args$replicates)

log_info('Running sampler')
samples <- lapply(
  metadata$example_indices,
  function(i) {
    log_info('Starting replicate %d, series %d', args$replicate_number, i)
    adaptspec(
      n_loop = settings$n_iterations,
      n_warm_up = 0,
      data = replicates[[args$replicate_number]][, i],
      n_segments_max = settings$n_segments_max,
      n_bases = settings$n_bases,
      t_min = settings$t_min,
      sigma_squared_alpha = settings$sigma_squared_alpha,
      tau_prior_a = settings$tau_prior_a,
      tau_prior_b = settings$tau_prior_b,
      tau_upper_limit = settings$tau_upper_limit,
      mu_lower = settings$mu_lower,
      mu_upper = settings$mu_upper,
      segment_means = TRUE,
      tuning = list(
        short_moves = settings$short_moves,
        short_move_weights = dnorm(
          settings$short_moves,
          sd = settings$short_move_sd
        ),
        use_single_within = FALSE,
        use_hmc_within = TRUE,
        use_hessian_curvature = TRUE
      ),
      thin = list(
        x_missing = 0
      ),
      detrend = FALSE,
      run_diagnostics = FALSE,
      show_progress = FALSE
    )
  }
)

log_info('Saving to %s', args$output)
saveRDS(samples, args$output)

log_info('Done')
