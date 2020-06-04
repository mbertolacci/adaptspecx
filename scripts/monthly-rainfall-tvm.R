source('scripts/partials/base.R')
source('scripts/partials/display-settings.R')
source('scripts/partials/monthly-rainfall.R')
library(dplyr, warn.conflicts = FALSE)
library(futile.logger)

parser$add_argument('--observations')
parser$add_argument('--map')
parser$add_argument('--tvmm')
parser$add_argument('--all', action = 'store_true', default = FALSE)
parser$add_argument('--with-data', action = 'store_true', default = FALSE)
args <- parser$parse_args()

flog.info('Loading data')
if (args$with_data) {
  observations <- readRDS(args$observations)
}
map <- readRDS(args$map)

flog.info('Loading TVMM')
tvmm_data <- readRDS(args$tvmm)
tvmm_df <- tvmm_data$tvmm
tvmm_metadata <- tvmm_data$metadata

if (!args$all) {
  labels <- as.character(tvmm_metadata$label)
  special_labels <- labels[(
    (labels %in% as.character(monthly_rainfall_settings$special_sites)) |
    (substr(labels, 1, 4) == 'Test')
  )]
  tvmm_df <- tvmm_df %>%
    filter(label %in% special_labels)
  tvmm_metadata <- tvmm_data$metadata %>%
    filter(label %in% special_labels)
}

if (args$with_data) {
  tvmm_df <- tvmm_df %>%
    left_join(
      observations %>%
        ungroup() %>%
        mutate(
          label = as.character(site_number),
          date = month_to_date(month)
        ) %>%
        select(label, date, average_rainfall),
      by = c('label', 'date')
    )
}

flog.info('Preparing plot')
is_test_site <- substr(tvmm_metadata$label, 1, 4) == 'Test'
tvmm_metadata$shape <- display_settings[ifelse(
  !is_test_site,
  'special_observed_covariate_shape',
  'unobserved_covariate_shape'
)]
tvmm_metadata$colour <- display_settings[ifelse(
  !is_test_site,
  'special_observed_covariate_colour',
  'unobserved_covariate_colour'
)]
tvmm_metadata$data <- I(lapply(1 : nrow(tvmm_metadata), function(i)
  tvmm_metadata[i, c('longitude', 'latitude', 'shape', 'colour')]
))

max_date <- max(tvmm_df$date)
max_value <- max(tvmm_df$value)

output <- ggplot(tvmm_df)

if (args$with_data) {
  output <- output +
    geom_line(
      aes(date, average_rainfall),
      na.rm = TRUE
    )
}

output <- output +
  # geom_ribbon(
  #   aes(
  #     x = date,
  #     ymin = lower,
  #     ymax = upper
  #   ),
  #   fill = 'red',
  #   alpha = if (args$with_data) 0.5 else 0.3
  # ) +
  geom_line(
    aes(
      x = date,
      y = value
    ),
    colour = display_settings$estimated_tvm_colour
  ) +
  facet_wrap(
    ~ label,
    ncol = if (args$all) 8 else 2
  ) +
  labs(x = 'Date', y = expression(hat(mu)(t, bold(u))*' [mm]')) +
  egg::geom_custom(
    aes(x = max_date, y = max_value, data = data),
    tvmm_metadata,
    grob_fun = make_plot_inset_map(map, 0.95, 0.81)
  )

if (!args$with_data) {
  output <- output +
    scale_y_continuous(limits = monthly_rainfall_settings$tvm_limits)
} else if (args$with_data && args$all) {
  output <- output +
    scale_y_continuous(trans = 'log1p')
}

flog.info('Saving plots')
ggsave(
  args$output,
  output,
  width = if (args$all) 60 else display_settings$full_page_plot_width,
  height = if (args$all) 40 else 10,
  dpi = display_settings$png_plot_dpi,
  units = 'cm'
)

flog.info('Done')
