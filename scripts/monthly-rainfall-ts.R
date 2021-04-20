source('scripts/partials/base.R')
source('scripts/partials/display-settings.R')
source('scripts/partials/monthly-rainfall.R')

library(dplyr, warn.conflicts = FALSE)

parser$add_argument('--map')
parser$add_argument('--metadata')
parser$add_argument('--observations')
parser$add_argument('--all', action = 'store_true', default = FALSE)
args <- parser$parse_args()

map <- readRDS(args$map)

metadata <- readRDS(args$metadata)

observations <- readRDS(args$observations) %>%
  mutate(date = as.Date(sprintf('%s-15', month))) %>%
  mutate(
    is_missing = is.na(average_rainfall)
  )

metadata$site_number <- metadata$number
metadata$data <- I(lapply(1 : nrow(metadata), function(i)
  metadata[i, c('longitude', 'latitude')]
))

if (!args$all) {
  observations <- observations %>%
    filter(site_number %in% monthly_rainfall_settings$special_sites)
  metadata <- metadata %>%
    filter(site_number %in% monthly_rainfall_settings$special_sites)
}

output <- ggplot(mapping = aes(date)) +
  geom_line(
    data = observations,
    mapping = aes(y = average_rainfall),
    colour = display_settings$data_colour
  ) +
  geom_rug(
    data = subset(observations, is_missing),
    sides = 'b',
    colour = 'red',
    size = 1
  ) +
  facet_wrap(
    ~ site_number,
    ncol = if (args$all) 8 else 1
  ) +
  labs(x = 'Date', y = 'Average rainfall [mm]') +
  theme(
    plot.margin = margin(5.5, 38, 5.5, 5.5),
    panel.grid.minor.y = element_blank()
  ) +
  scale_y_continuous(breaks = scales::pretty_breaks(n = 3)) +
  egg::geom_custom(
    aes(x = observations$date[1], y = 0, data = data),
    metadata,
    grob_fun = make_plot_inset_map(
      map,
      x = if (args$all) 0.9 else 1.01,
      y = if (args$all) 0.9 else 0.45,
      shape = display_settings$special_observed_covariate_shape,
      colour = display_settings$special_observed_covariate_colour
    )
  )

ggsave(
  args$output,
  output,
  width = if (args$all) 32 else display_settings$full_page_plot_width - 2,
  height = if (args$all) 65 else 0.5 * display_settings$full_page_plot_width,
  units = 'cm'
)
