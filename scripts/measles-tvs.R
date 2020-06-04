source('scripts/partials/base.R')
source('scripts/partials/display-settings.R')
source('scripts/partials/measles.R')
suppressPackageStartupMessages(devtools::load_all('BayesSpec'))
library(dplyr, warn.conflicts = FALSE)
library(futile.logger)
library(lubridate, warn.conflicts = FALSE)

parser$add_argument('--tvsm')
parser$add_argument('--period', default = 'full')
parser$add_argument('--states', default = 'all')
args <- parser$parse_args()

flog.info('Loading TVSM')
tvsm_data <- readRDS(args$tvsm)
tvsm_df <- tvsm_data$tvsm
metadata <- tvsm_data$metadata

if (args$period == 'before') {
  tvsm_df <- tvsm_df %>% filter(!after_vaccine)
} else if (args$period == 'inter') {
  tvsm_df <- tvsm_df %>%
    filter(
      date > '1950-01-01',
      date <= measles_settings$after_success
    )
} else if (args$period == 'after') {
  tvsm_df <- tvsm_df %>% filter(date > measles_settings$after_success)
}

if (args$states != 'all') {
  tvsm_df <- tvsm_df %>%
    filter(state %in% measles_settings$special_states) %>%
    mutate(state = factor(state, levels = measles_settings$special_states))
  metadata <- metadata %>%
    filter(state %in% measles_settings$special_states) %>%
    mutate(state = factor(state, levels = measles_settings$special_states))
}

tvsm_range <- range(tvsm_df$value)
plot_limits <- measles_settings$tvs_log_power_limits[[args$period]]
if (tvsm_range[1] < plot_limits[1] || tvsm_range[2] > plot_limits[2]) {
  print(tvsm_range)
  print(plot_limits)
  warning('TVSM range wider than plot range')
}

flog.info('Outputting plot')
max_date <- max(tvsm_df$date)
max_frequency <- max(tvsm_df$frequency)
output <- ggplot() +
  geom_rect(
    data = tvsm_df %>% filter(frequency > 0),
    mapping = aes(
      xmin = date,
      xmax = max_date,
      ymin = frequency,
      ymax = max_frequency,
      fill = value
    )
  ) +
  geom_label(
    data = metadata %>%
      mutate(date = max_date - days(
        if (args$states != 'all' && args$period == 'before') {
          10 * 52
        } else {
          25 * 52
        }
      )),
    mapping = aes(
      x = date,
      y = 0.46,
      label = state
    ),
    size = if (args$states == 'all') 2 else 3,
    colour = 'black',
    label.padding = unit(0.1, 'lines'),
    label.size = 0
  ) +
  scale_x_date(
    breaks = list(
      before = as.Date(c('1930-01-01', '1940-01-01', '1950-01-01', '1960-01-01')),
      full = as.Date(c('1940-01-01', '1960-01-01', '1980-01-01', '2000-01-01')),
      inter = as.Date(c('1960-01-01', '1970-01-01', '1980-01-01')),
      after = as.Date(c('1980-01-01', '1990-01-01', '2000-01-01'))
    )[[args$period]],
    date_labels = '%Y'
  ) +
  scale_y_continuous(
    trans = 'sqrt',
    breaks = c(0, 0.1, 0.3, 0.5),
    sec.axis = sec_axis(
      ~ .,
      breaks = c(1 / 52),
      labels = function(x) round(1 / x, 2),
      name = 'Period [weeks]'
    )
  ) +
  labs(x = 'Date', y = expression(omega*' [week'^{-1}*']'), fill = 'Log power') +
  display_settings$tvs_fill_palette(
    limits = plot_limits
  ) +
  theme(
    legend.position = if(args$states == 'all') 'bottom' else 'right',
    axis.text.x = element_text(
      angle = if (args$states == 'all') -60 else 0,
      hjust = if (args$states == 'all') 0 else 0.5,
      vjust = 1
    ),
    panel.grid.major.y = element_blank(),
    panel.grid.minor = element_blank(),
    strip.background = element_blank(),
    strip.text = element_blank()
  )

if (args$states == 'all') {
  output <- output +
    facet_grid(map_row ~ map_column)
} else {
  output <- output +
    facet_wrap(~ state, ncol = 2)
}

plot_width <- display_settings$full_page_plot_height - 2.5

ggsave(
  args$output,
  output,
  width = (
    if (args$states == 'all') {
      plot_width
    } else {
      display_settings$full_page_plot_width
    }
  ),
  height = (
    if (args$states == 'all') {
      0.72 * plot_width
    } else {
      0.43 * display_settings$full_page_plot_height
    }
  ),
  dpi = display_settings$png_plot_dpi,
  units = 'cm'
)

flog.info('Done')
