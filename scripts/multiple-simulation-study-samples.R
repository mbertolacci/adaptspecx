source('scripts/partials/base.R')
source('scripts/partials/multiple-simulation-study.R')
library(futile.logger)
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
samples <- adaptspecx(
  n_loop = settings$n_iterations,
  n_warm_up = 0,
  data = replicates[[args$replicate_number]],
  design_matrix = metadata$design_matrix,
  n_components = settings$n_components,
  component_model = adaptspec_model(
    n_segments_max = settings$n_segments_max,
    n_bases = settings$n_bases,
    t_min = settings$t_min,
    sigma_squared_alpha = settings$sigma_squared_alpha,
    tau_prior_a = settings$tau_prior_a,
    tau_prior_b = settings$tau_prior_b,
    tau_upper_limit = settings$tau_upper_limit,
    mu_lower = settings$mu_lower,
    mu_upper = settings$mu_upper,
    segment_means = TRUE
  ),
  mixture_prior = list(
    tau_prior_nu = settings$tau_prior_nu,
    tau_prior_a_squared = settings$tau_prior_a_squared,
    tau_prior_upper = settings$tau_prior_upper,
    precision = matrix(
      settings$spline_precision_prior,
      nrow = 1 + ncol(metadata$design_matrix) + settings$n_spline_bases,
      ncol = settings$n_components - 1
    ),
    n_bases = settings$n_spline_bases
  ),
  component_tuning = adaptspec_tuning(
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
  show_progress = TRUE
)

log_info('Saving to %s', args$output)
saveRDS(samples, args$output)

log_info('Done')
