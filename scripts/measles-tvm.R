source('scripts/partials/base.R')
source('scripts/partials/display-settings.R')
source('scripts/partials/measles.R')
suppressPackageStartupMessages(devtools::load_all('BayesSpec'))
library(dplyr, warn.conflicts = FALSE)
library(futile.logger)
library(lubridate, warn.conflicts = FALSE)

parser$add_argument('--observations')
parser$add_argument('--tvmm')
parser$add_argument('--with-data', action = 'store_true', default = FALSE)
parser$add_argument('--period', default = 'full')
args <- parser$parse_args()

if (args$with_data) {
  flog.info('Loading observations')
  observations <- readRDS(args$observations)
}

flog.info('Loading TVMM')
tvmm_data <- readRDS(args$tvmm)
tvmm_df <- tvmm_data$tvmm
metadata <- tvmm_data$metadata

if (!args$with_data) {
  tvm_range <- range(tvmm_df[, c('lower', 'upper')])
  if (tvm_range[1] < measles_settings$tvm_limits[1] || tvm_range[2] > measles_settings$tvm_limits[2]) {
    print(tvm_range)
    warning('TVM range above is outside of limits')
  }
}

if (args$period == 'before') {
  tvmm_df <- tvmm_df %>% filter(!after_vaccine)
  if (args$with_data) {
    observations <- observations %>% filter(!after_vaccine)
  }
} else if (args$period == 'sdfsdf') {
  tvmm_df <- tvmm_df %>% filter(after_vaccine)
  if (args$with_data) {
    observations <- observations %>% filter(after_vaccine)
  }
} else if (args$period == 'after') {
  tvmm_df <- tvmm_df %>% filter(date > measles_settings$after_success)
  if (args$with_data) {
    observations <- observations %>% filter(week_start > measles_settings$after_success)
  }
}

max_date <- max(tvmm_df$date)

flog.info('Outputting plot')
output <- ggplot()

if (args$with_data) {
  output <- output +
    geom_line(
      data = observations %>%
        left_join(
          metadata,
          by = 'state'
        ),
      mapping = aes(
        x = week_start,
        y = incidence_per_capita
      ),
      na.rm = TRUE
    )
}

output <- output +
  # geom_ribbon(
  #   data = tvmm_df,
  #   mapping = aes(
  #     x = date,
  #     ymin = lower,
  #     ymax = upper
  #   ),
  #   fill = 'red',
  #   alpha = if (args$with_data) 0.5 else 0.3,
  #   na.rm = TRUE
  # ) +
  geom_line(
    data = tvmm_df,
    mapping = aes(
      x = date,
      y = value
    ),
    colour = display_settings$estimated_tvm_colour,
    na.rm = TRUE
  ) +
  geom_label(
    data = metadata %>%
      mutate(date = max_date - days(25 * 52)),
    mapping = aes(
      x = date,
      y = max(tvmm_df$value),
      label = state
    ),
    size = 2,
    colour = 'black',
    label.padding = unit(0.1, 'lines'),
    label.size = 0
  ) +
  facet_grid(
    map_row ~ map_column
  ) +
  labs(x = 'Date', y = expression(hat(mu)(t, bold(u))*' [incidence per 100,000]')) +
  guides(colour = FALSE) +
  theme(
    axis.text.x = element_text(angle = -60, hjust = 0, vjust = 1),
    panel.grid.minor = element_blank(),
    strip.background = element_blank(),
    strip.text = element_blank()
  )

if (args$with_data) {
  output <- output +
    scale_y_continuous(
      trans = 'sqrt',
      breaks = c(10, 100, 600)
    )
} else {
  output <- output +
    scale_y_continuous(
      breaks = scales::pretty_breaks(3),
      limits = if (args$period == 'full') measles_settings$tvm_limits else range(tvmm_df$value)
    )
}

plot_width <- display_settings$full_page_plot_height - 2.5

ggsave(
  args$output,
  output,
  width = plot_width,
  height = 0.65 * plot_width,
  units = 'cm'
)

flog.info('Done')
