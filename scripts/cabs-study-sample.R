source('scripts/partials/base.R')
source('scripts/partials/cabs-study.R')
library(futile.logger)
suppressPackageStartupMessages(library(BayesSpec))

parser$add_argument('--configurations')
parser$add_argument('--configuration-number', type = 'integer')
parser$add_argument('--replicate-number', type = 'integer')
args <- parser$parse_args()

log_info <- function(fmt, ...) {
  flog.info(
    paste0('[%d/%d] ', fmt),
    args$configuration_number,
    args$replicate_number,
    ...
  )
}

log_info('Loading configurations')
configurations <- readRDS(args$configurations)

data <- configurations$y_replicates[[args$configuration_number]][, , args$replicate_number]
design_matrix <- as.matrix(configurations$w[[args$configuration_number]])
n_time_series <- configurations$n_time_series[args$configuration_number]

rm(configurations)
gc()

log_info('Starting sampler')
samples <- adaptspec_lsbp_mixture(
  n_loop = cabs_study_settings$n_loop,
  n_warm_up = 0,
  data = data,
  design_matrix = design_matrix,
  n_components = cabs_study_settings$n_components,
  component_model = adaptspec_model(
    n_segments_max = 10,
    n_bases = cabs_study_settings$n_bases,
    t_min = 50,
    sigma_squared_alpha = 10,
    tau_prior_a = 1.1,
    tau_prior_b = 30,
    tau_upper_limit = 10000,
    segment_means = FALSE
  ),
  spline_prior = list(
    n_bases = cabs_study_settings$n_spline_bases
  ),
  mixture_prior = list(
    tau_prior_nu = 3,
    tau_prior_a_squared = 100,
    tau_prior_upper = 10000,
    precision = matrix(
      1 / 100,
      nrow = 1 + ncol(design_matrix) + cabs_study_settings$n_spline_bases,
      ncol = cabs_study_settings$n_components - 1
    )
  ),
  component_tuning = list(
    short_moves = c(-4 : -1, 1 : 4),
    short_move_weights = dnorm(
      c(-4 : -1, 1 : 4),
      sd = 5
    ),
    use_single_within = FALSE,
    use_hmc_within = TRUE,
    use_hessian_curvature = TRUE
  ),
  start = list(
    categories = rep(0L : 9L, each = n_time_series / 10L)
  ),
  detrend = FALSE,
  run_diagnostics = FALSE,
  show_progress = TRUE
)

log_info('Saving to %s', args$output)
saveRDS(samples, args$output)

log_info('Done')
