TIME_INDEX <- 't'
SITE_INDEX <- 'j'
COMPONENT_INDEX <- 'h'

display_settings <- list(
  full_page_plot_width = 17,
  full_page_plot_height = 22,
  half_page_plot_width = 7,
  png_plot_dpi = 400,
  data_colour = 'black',
  true_tvm_colour = 'deepskyblue3',
  estimated_tvm_colour = 'firebrick2',
  observed_covariate_shape = 3,
  observed_covariate_colour = 'black',
  special_observed_covariate_shape = 1,
  special_observed_covariate_colour = 'forestgreen',
  unobserved_covariate_shape = 5,
  unobserved_covariate_colour = 'red',
  tvs_fill_palette = function(...) scale_fill_wes_palette_c(
    name = 'Zissou1',
    ...
  )
)