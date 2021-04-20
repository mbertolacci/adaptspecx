monthly_rainfall_settings <- list(
  # Data
  start_date = '1914-09-01',
  end_date = '2004-06-30',
  special_sites = c(
    # Broomehill (SWWA)
    10525,
    # Oenpelli (NT)
    14042,
    # Wentworth Post Office (SEA, near Mildura)
    47053,
    # Moruya Heads Pilot Station (South coast NSW)
    69018
    # 9519,
    # 14042,
    # 24511,
    # 84016
  ),
  # MCMC iterations
  n_iterations = 50000,
  warm_up = 10000,
  # Component model
  # t_min = 12 * 10,
  t_min = 12 * 5,
  n_bases = 60,
  sigma_squared_alpha = 10,
  tau_prior_a = 1.1,
  tau_prior_b = 30,
  tau_upper_limit = 10000,
  mu_lower = 0,
  mu_upper = 30,
  # Mixture model
  n_components = 25,
  n_spline_bases = 20,
  spline_precision_prior = 1 / 100,
  tau_prior_nu = 3,
  tau_prior_a_squared = 100,
  tau_prior_upper = 10000,
  # Proposal
  short_moves = c(-32 : -1, 1 : 32),
  short_move_sd = 8,
  # Outputs
  test_points = rbind(
    ## Near Carnarvon
    c(114.0158, -24.32130),
    ## Near Townsville
    c(146.5203, -19.28451),
    ## Near Sydney
    c(150.311223, -34.027168),
    ## Near Melbourne
    c(144.4887, -37.75274)
  ),
  tvm_thin = 20,
  tvm_limits = c(0, 4),
  tvs_log_power_limits = c(-2.4, 6),
  tvs_thin = 100,
  tvs_n_frequencies = 2 ^ 7,
  tvs_time_step = 5,
  diagnostics_thin = 100,
  clustering_thin = 100,
  test_thin = 10,
  test_n_frequencies = 2 ^ 8
)

month_to_date <- function(x) as.Date(sprintf('%s-15', x))

make_plot_inset_map <- function(map, x, y, colour = NULL, shape = NULL) {
  function(location) {
    if (!is.null(colour)) location$colour <- colour
    if (!is.null(shape)) location$shape <- shape
    gridExtra::arrangeGrob(ggplotGrob(
      ggplot() +
        geom_polygon(
          aes(long, lat, group = group),
          map,
          fill = NA,
          colour = '#888888',
          size = 0.2
        ) +
        geom_point(
          aes(longitude, latitude),
          location,
          colour = location$colour,
          shape = location$shape
        ) +
        coord_quickmap() +
        labs(x = NULL, y = NULL) +
        xlim(0.97 * min(map$long), 1.01 * max(map$long)) +
        theme(
          axis.title.x = element_blank(),
          axis.text.x = element_blank(),
          axis.ticks.x = element_blank(),
          axis.title.y = element_blank(),
          axis.text.y = element_blank(),
          axis.ticks.y = element_blank(),
          panel.grid = element_blank(),
          panel.background = element_rect(fill = 'white', colour = 'white')
        )
    ), vp = grid::viewport(
      x = x,
      y = y,
      height = unit(1.25, 'cm')
    ))
  }
}
