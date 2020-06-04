source('scripts/partials/base.R')
source('scripts/partials/display-settings.R')
source('scripts/partials/monthly-rainfall.R')

library(dplyr, warn.conflicts = FALSE)
library(lubridate, warn.conflicts = FALSE)
library(withr)
library(futile.logger)
library(gridExtra, warn.conflicts = FALSE)

parser$add_argument('--map')
parser$add_argument('--tvsm')
parser$add_argument('--all', action = 'store_true', default = FALSE)
parser$add_argument('--unscaled', action = 'store_true', default = FALSE)
args <- parser$parse_args()

flog.debug('Loading data')
map <- readRDS(args$map)

flog.debug('Loading TVSM')
tvsm_data <- readRDS(args$tvsm)

tvsm_df <- tvsm_data$tvsm
tvsm_metadata <- tvsm_data$metadata

if (!args$all) {
  labels <- as.character(tvsm_metadata$label)
  special_labels <- labels[(
    (labels %in% as.character(monthly_rainfall_settings$special_sites)) |
    (substr(labels, 1, 4) == 'Test')
  )]

  tvsm_df <- tvsm_df %>%
    filter(label %in% special_labels)
  tvsm_metadata <- tvsm_data$metadata %>%
    filter(label %in% special_labels)
}

if (!args$all && !args$unscaled) {
  log_spectrum_range <- range(tvsm_df$log_spectrum)
  if (
    log_spectrum_range[1] < monthly_rainfall_settings$tvs_log_power_limits[1] ||
    log_spectrum_range[2] > monthly_rainfall_settings$tvs_log_power_limits[2]
  ) {
    cat('Log spectrum range is\n')
    print(log_spectrum_range)
    stop('Log spectrum range too narrow')
  }
}

flog.info('Preparing plot')
is_test_site <- substr(tvsm_metadata$label, 1, 4) == 'Test'
tvsm_metadata$shape <- display_settings[ifelse(
  !is_test_site,
  'special_observed_covariate_shape',
  'unobserved_covariate_shape'
)]
tvsm_metadata$colour <- display_settings[ifelse(
  !is_test_site,
  'special_observed_covariate_colour',
  'unobserved_covariate_colour'
)]
tvsm_metadata$data <- I(lapply(1 : nrow(tvsm_metadata), function(i)
  tvsm_metadata[i, c('longitude', 'latitude', 'shape', 'colour')]
))

plot_set <- function(tvsm_df, tvsm_metadata, ncol, limits) {
  max_date <- max(tvsm_df$date)
  max_frequency <- max(tvsm_df$frequency)
  output <- ggplot() +
    geom_rect(
      # HACK(mgnb): secondary axes are misbehaving with trans = 'sqrt' if 0
      # is included
      data = tvsm_df %>% filter(frequency > 0),
      mapping = aes(
        xmin = date,
        xmax = max_date,
        ymin = frequency,
        ymax = max_frequency,
        fill = log_spectrum
      )
    ) +
    facet_wrap(~ label, ncol = ncol) +
    scale_y_continuous(
      trans = 'sqrt',
      breaks = c(0, 0.1, 0.2, 0.3, 0.4, 0.5),
      sec.axis = sec_axis(
        ~ .,
        breaks = c(1 / 6, 1 / 12),
        labels = function(x) round(1 / x, 2),
        name = if (args$unscaled) NULL else 'Period [months]'
      )
    ) +
    labs(
      x = 'Date',
      y = expression(omega*' [month'^{-1}*']'),
      fill = 'Log power'
    ) +
    egg::geom_custom(
      aes(x = max_date, y = max_frequency, data = data),
      tvsm_metadata,
      grob_fun = make_plot_inset_map(map, 0.91, 0.88)
    )

  if (!missing(limits)) {
    output <- output + display_settings$tvs_fill_palette(limits = limits)
  } else {
    output <- output + display_settings$tvs_fill_palette()
  }

  output
}

if (!args$unscaled) {
  plot_width <- if (args$all) 40 else display_settings$full_page_plot_width
  plot_height <- if (args$all) 70 else (display_settings$full_page_plot_height - 3.5)
  output <- plot_set(
    tvsm_df,
    tvsm_metadata,
    if (args$all) 8 else 2,
    monthly_rainfall_settings$tvs_log_power_limits
  ) +
    theme(legend.position = 'bottom')
} else {
  all_plots <- lapply(1 : nrow(tvsm_metadata), function(i) {
    tvsm_metadata_i <- tvsm_metadata[i, ]

    plot_set(
      tvsm_df %>% filter(label == tvsm_metadata$label[i]),
      tvsm_metadata[i, ],
      1
    ) +
      labs(
        x = NULL,
        y = NULL,
        fill = 'Log power'
      ) +
      theme(
        legend.margin = margin(0, 0, 0, 0),
        legend.title = element_text(size = 8),
        legend.key.width = unit(0.75, 'line')
      )
  })

  plot_width <- if (args$all) 60 else display_settings$full_page_plot_width
  plot_height <- if (args$all) 70 else (display_settings$full_page_plot_height - 3)
  y_axis_label_width <- 0.5
  secondary_y_axis_label_width <- 0.5
  x_axis_label_height <- 0.8

  output <- arrangeGrob(
    arrangeGrob(grobs = all_plots, ncol = 2),
    grid::textGrob(expression(omega*' [month'^{-1}*']'), rot = 90),
    grid::textGrob('Date'),
    grid::textGrob('Period [months]', rot = -90),
    layout_matrix = rbind(
      c(2, 1, 4),
      c(2, 1, 4),
      c(NA, 3, NA)
    ),
    widths = c(
      y_axis_label_width,
      plot_width - y_axis_label_width - secondary_y_axis_label_width,
      secondary_y_axis_label_width
    ),
    heights = c(
      (plot_height - x_axis_label_height) / 2,
      (plot_height - x_axis_label_height) / 2,
      x_axis_label_height
    )
  )
}

flog.info('Saving plots')
ggsave(
  args$output,
  output,
  width = plot_width,
  height = plot_height,
  units = 'cm',
  dpi = display_settings$png_plot_dpi
)

flog.info('Done')
