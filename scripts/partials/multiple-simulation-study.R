tvm_piecewise_ar <- function(model, n_times) {
  output <- do.call(c, lapply(1 : length(model), function(segment) {
    rep(model[[segment]]$mean, round(model[[segment]]$proportion * n_times))
  }))
  attr(output, 'times') <- 1 : n_times
  output
}

tvm_piecewise_ar_category <- function(components, category, n_times) {
  output <- matrix(NA, nrow = n_times, ncol = length(category))
  for (i in 1 : length(category)) {
    output[, i] <- tvm_piecewise_ar(components[[category[i]]], n_times)
  }
  attr(output, 'times') <- 1 : n_times
  output
}

tvs_piecewise_ar <- function(model, n_frequencies, n_times) {
  frequencies <- seq(0, 0.5, length.out = n_frequencies)
  output <- do.call(cbind, lapply(1 : length(model), function(segment) {
    spectrum_raw <- TSA::ARMAspec(
      model[[segment]]$arima_model,
      freq = frequencies,
      plot = FALSE
    )
    matrix(
      rep(log(spectrum_raw$spec[, 1]), round(model[[segment]]$proportion * n_times)),
      nrow = length(frequencies)
    )
  }))
  attr(output, 'frequencies') <- frequencies
  attr(output, 'times') <- 1 : n_times
  output
}

tvs_piecewise_ar_category <- function(components, category, n_frequencies, n_times) {
  output <- array(NA, dim = c(n_frequencies, n_times, length(category)))
  for (i in 1 : length(category)) {
    output[, , i] <- tvs_piecewise_ar(components[[category[i]]], n_frequencies, n_times)
  }
  attr(output, 'frequencies') <- seq(0, 0.5, length.out = n_frequencies)
  attr(output, 'times') <- 1 : n_times
  output
}

settings <- list(
  # Data
  n_replicates = 100,
  n_time_series = 100,
  n_times = 256,
  proportion_missing = 0.1,
  components = list(
    list(
      list(mean = -1.5, arima_model = list(ar = c(1.5, -0.75)), proportion = 0.5),
      list(mean = -2, arima_model = list(ar = c(-0.8)), proportion = 0.5)
    ),
    list(
      list(mean = 1, arima_model = list(ar = c(-0.8)), proportion = 0.5),
      list(mean = -1, arima_model = list(ar = c(-0.8)), proportion = 0.5)
    ),
    list(
      list(mean = 0, arima_model = list(ar = c(1.5, -0.75)), proportion = 1)
    ),
    list(
      list(mean = 1, arima_model = list(ar = c(0.2)), proportion = 0.5),
      list(mean = 1, arima_model = list(ar = c(1.5, -0.75)), proportion = 0.5)
    )
  ),
  test_points = rbind(
    c(0.375, 0.15),
    c(0.25, 0.775),
    c(0.7, 0.22),
    c(0.625, 0.8)
  ),
  # Sampler
  n_iterations = 50000,
  warm_up = 10000,
  # Mixture model
  n_components = 25,
  # Component model
  n_segments_max = 4,
  n_bases = 15,
  t_min = 40,
  sigma_squared_alpha = 10,
  tau_prior_a = 1.1,
  tau_prior_b = 30,
  tau_upper_limit = 10000,
  mu_lower = -10,
  mu_upper = 10,
  # Spline prior
  n_spline_bases = 10,
  # Mixture prior
  spline_precision_prior = 1 / 100,
  tau_prior_nu = 3,
  tau_prior_a_squared = 100,
  tau_prior_upper = 10000,
  # Proposal
  short_moves = c(-4 : -1, 1 : 4),
  short_move_sd = 5,
  # Outputs
  tvm_thin = 100,
  tvs_thin = 100,
  tvs_n_frequencies = 64
)
