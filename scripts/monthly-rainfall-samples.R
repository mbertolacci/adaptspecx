source('scripts/partials/base.R')
source('scripts/partials/monthly-rainfall.R')
suppressPackageStartupMessages(library(BayesSpec))
library(dplyr, warn.conflicts = FALSE)
suppressWarnings(library(lubridate, warn.conflicts = FALSE))
library(tidyr)
library(futile.logger)

# set.seed(201810042)

printf <- function(...) cat(sprintf(...))

parser$add_argument('--metadata')
parser$add_argument('--observations')
args <- parser$parse_args()

flog.info('Loading observations')
observations <- readRDS(args$observations)

flog.info('Widening observations')
observations_wide_df <- observations %>%
  select(site_number, month, average_rainfall) %>%
  spread(site_number, average_rainfall)

flog.info('Validating wide observations')
stopifnot(sort(observations_wide_df$month) == observations_wide_df$month)
all_months <- substring(seq(
  ymd(paste0(min(observations$month), '-01')),
  ymd(paste0(max(observations$month), '-01')),
  by = 'months'
), 1, 7)
stopifnot(sort(observations_wide_df$month) == all_months)

flog.info('Converting observations to matrix')
observations_wide <- observations_wide_df %>%
  select(-month) %>%
  as.matrix()

flog.info('Loading and validating metadata')
metadata <- readRDS(args$metadata)
stopifnot(all(as.character(metadata$number) == colnames(observations_wide)))

flog.info('Constructing and validating design matrix')
design_matrix <- rbind(
  metadata %>%
    select(longitude, latitude) %>%
    as.matrix(),
  monthly_rainfall_settings$test_points
)
stopifnot(design_matrix[, 1] > monthly_rainfall_settings$longitude_lower)
stopifnot(design_matrix[, 1] < monthly_rainfall_settings$longitude_upper)
stopifnot(design_matrix[, 2] > monthly_rainfall_settings$latitude_lower)
stopifnot(design_matrix[, 2] < monthly_rainfall_settings$latitude_upper)

flog.info('Scaling design matrix')
design_matrix <- scale(design_matrix)

flog.info('Running sampler')
samples <- adaptspecx(
  n_loop = monthly_rainfall_settings$n_iterations,
  n_warm_up = 0,
  data = observations_wide,
  design_matrix = design_matrix,
  n_components = monthly_rainfall_settings$n_components,
  component_model = adaptspec_model(
    n_segments_max = floor(nrow(observations_wide) / monthly_rainfall_settings$t_min),
    t_min = monthly_rainfall_settings$t_min,
    n_bases = monthly_rainfall_settings$n_bases,
    sigma_squared_alpha = monthly_rainfall_settings$sigma_squared_alpha,
    tau_prior_a = monthly_rainfall_settings$tau_prior_a,
    tau_prior_b = monthly_rainfall_settings$tau_prior_b,
    tau_upper_limit = monthly_rainfall_settings$tau_upper_limit,
    segment_means = TRUE,
    mu_lower = monthly_rainfall_settings$mu_lower,
    mu_upper = monthly_rainfall_settings$mu_upper
  ),
  mixture_prior = list(
    tau_prior_nu = monthly_rainfall_settings$tau_prior_nu,
    tau_prior_a_squared = monthly_rainfall_settings$tau_prior_a_squared,
    tau_prior_upper = monthly_rainfall_settings$tau_prior_upper,
    precision = matrix(
      monthly_rainfall_settings$spline_precision_prior,
      nrow = 3 + monthly_rainfall_settings$n_spline_bases,
      ncol = monthly_rainfall_settings$n_components - 1
    ),
    n_bases = monthly_rainfall_settings$n_spline_bases
  ),
  component_tuning = adaptspec_tuning(
    short_moves = monthly_rainfall_settings$short_moves,
    short_move_weights = dnorm(
      monthly_rainfall_settings$short_moves,
      sd = monthly_rainfall_settings$short_move_sd
    ),
    use_single_within = FALSE,
    use_hmc_within = TRUE,
    use_hessian_curvature = FALSE
  ),
  thin = list(
    x_missing = 100,
    beta = 10
  ),
  detrend = FALSE,
  run_diagnostics = FALSE,
  show_progress = TRUE
)

flog.info('Saving output')
saveRDS(samples, args$output)

flog.info('Done')
