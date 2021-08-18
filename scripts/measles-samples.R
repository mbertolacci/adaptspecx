source('scripts/partials/base.R')
source('scripts/partials/measles.R')
suppressPackageStartupMessages(library(BayesSpec))
library(dplyr, warn.conflicts = FALSE)
library(tidyr)
library(futile.logger)

parser$add_argument('--metadata')
parser$add_argument('--observations')
args <- parser$parse_args()

flog.info('Loading observations')
observations <- readRDS(args$observations) %>%
  select(-state_name, -after_vaccine) %>%
  arrange(week, state)

observations_wide <- observations %>%
  spread(state, incidence_per_capita)

observations_matrix <- observations_wide %>%
  select(-week, -week_start) %>%
  as.matrix()

flog.info('Loading metadata')
metadata <- readRDS(args$metadata) %>%
  arrange(state)
stopifnot(all(metadata$state == colnames(observations_matrix)))

flog.info('Constructing and validating design matrix')
design_matrix <- metadata %>%
  select(longitude, latitude) %>%
  as.matrix() %>%
  scale()

flog.info('Running sampler')
samples <- adaptspecx(
  n_loop = measles_settings$n_iterations,
  n_warm_up = 0,
  data = observations_matrix,
  design_matrix = design_matrix,
  n_components = measles_settings$n_components,
  detrend = FALSE,
  component_model = adaptspec_model(
    n_segments_max = floor(nrow(observations_matrix) / measles_settings$t_min),
    t_min = measles_settings$t_min,
    n_bases = measles_settings$n_bases,
    sigma_squared_alpha = measles_settings$sigma_squared_alpha,
    tau_prior_a = measles_settings$tau_prior_a,
    tau_prior_b = measles_settings$tau_prior_b,
    tau_upper_limit = measles_settings$tau_upper_limit,
    segment_means = TRUE,
    mu_lower = measles_settings$mu_lower,
    mu_upper = measles_settings$mu_upper
  ),
  lsbp_tuning = list(
    n_swap_moves = 1
  ),
  mixture_prior = list(
    tau_prior_nu = measles_settings$tau_prior_nu,
    tau_prior_a_squared = measles_settings$tau_prior_a_squared,
    precision = matrix(
      measles_settings$spline_precision_prior,
      nrow = 3 + measles_settings$n_spline_bases,
      ncol = measles_settings$n_components - 1
    ),
    n_bases = measles_settings$n_spline_bases
  ),
  component_tuning = adaptspec_tuning(
    short_moves = measles_settings$short_moves,
    short_move_weights = dnorm(
      measles_settings$short_moves,
      sd = measles_settings$short_move_sd
    ),
    use_single_within = FALSE,
    use_hmc_within = TRUE,
    use_hessian_curvature = FALSE
  ),
  thin = list(
    x_missing = 100,
    beta = 5
  ),
  run_diagnostics = FALSE,
  show_progress = TRUE
)

flog.info('Saving output to %s', args$output)
saveRDS(samples, args$output)

flog.info('Done')
