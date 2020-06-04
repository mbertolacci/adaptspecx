measles_settings <- list(
  # Data
  excluded_states = c('AK', 'HI'),
  vaccine_week = 196300,
  after_success = '1981-01-01',
  # MCMC iterations
  n_iterations = 50000,
  warm_up = 10000,
  # Component model
  t_min = 52 * 4,
  n_bases = 60,
  sigma_squared_alpha = 10,
  tau_prior_a = 1.1,
  tau_prior_b = 30,
  tau_upper_limit = 10000,
  mu_lower = 0,
  mu_upper = 20,
  # Mixture model
  n_components = 10,
  n_spline_bases = 20,
  spline_precision_prior = 1 / 100,
  tau_prior_nu = 3,
  tau_prior_a_squared = 100,
  tau_prior_upper = 10000,
  # Proposal
  short_moves = c(-32 : -1, 1 : 32),
  short_move_sd = 8,
  # Outputs
  diagnostics_thin = 100,
  tvm_thin = 10,
  tvm_time_step = 5,
  tvm_limits = c(0, 14.5),
  tvs_thin = 100,
  tvs_n_frequencies = 2 ^ 8,
  tvs_time_step = 26,
  tvs_log_power_limits = list(
    'full' = c(-5.5, 9),
    'before' = c(0, 9),
    'inter' = c(-4, 9),
    'after' = c(-5.5, 2.8)
  ),
  test_thin = 5,
  test_n_frequencies = 2 ^ 8,
  special_states = c('WA', 'ME', 'AZ', 'FL')
)

(function() {
  # A slightly modified form of this: https://codepen.io/jakealbaugh/pen/aONOYM
  state_matrix <- rbind(
    c(NA,NA,NA,NA,NA,NA,NA,NA,02,03,01),
    c(04,05,06,07,08,NA,09,NA,10,11,12),
    c(13,14,15,16,17,18,19,20,21,22,NA),
    c(23,24,25,26,27,28,29,30,31,32,NA),
    c(NA,33,34,36,37,38,39,40,41,NA,NA),
    c(NA,42,35,43,44,45,46,47,NA,NA,NA),
    c(NA,NA,NA,48,NA,NA,NA,49,NA,NA,NA)
  )

  matrix_names <- c(
    'ME', 'VT', 'NH', 'WA', 'MT', 'ND', 'MN', 'WI', 'MI', 'NY', 'MA', 'RI',
    'ID', 'WY', 'SD', 'IA', 'IL', 'IN', 'OH', 'PA', 'NJ', 'CT', 'OR', 'NV',
    'CO', 'NE', 'MO', 'KY', 'WV', 'VA', 'MD', 'DE', 'CA', 'UT', 'NM', 'KS',
    'AR', 'TN', 'NC', 'SC', 'DC', 'AZ', 'OK', 'LA', 'MS', 'AL', 'GA', 'TX',
    'FL'
  )

  state_matrix_reordered <- state_matrix
  state_matrix_reordered[
    match(1 : length(matrix_names), state_matrix)
  ] <- rank(matrix_names)

  ordered_state_to_reordered <- match(
    1 : length(matrix_names),
    state_matrix_reordered
  )

  measles_settings$state_grid <<- cbind(
    row(state_matrix_reordered)[ordered_state_to_reordered],
    col(state_matrix_reordered)[ordered_state_to_reordered]
  )
})()
