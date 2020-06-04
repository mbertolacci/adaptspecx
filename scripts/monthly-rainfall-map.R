source('scripts/partials/base.R')
source('scripts/partials/display-settings.R')
source('scripts/partials/monthly-rainfall.R')

library(dplyr, warn.conflicts = FALSE)

parser$add_argument('--map')
parser$add_argument('--metadata')
args <- parser$parse_args()

map <- readRDS(args$map)

metadata <- readRDS(args$metadata) %>%
  mutate(
    is_special = number %in% monthly_rainfall_settings$special_sites
  )

test_point_data <- data.frame(
  longitude = monthly_rainfall_settings$test_points[, 1],
  latitude = monthly_rainfall_settings$test_points[, 2],
  label = sprintf('Test point %d', 1 : nrow(monthly_rainfall_settings$test_points)),
  text_longitude = c(116, 151, 134, 135),
  text_latitude = c(-18, -15, -38, -42)
)

metadata$text_longitude <- NA
metadata$text_latitude <- NA
metadata$text_longitude[metadata$is_special] <- c(116, 125, 130, 152)
metadata$text_latitude[metadata$is_special] <- c(-37, -11, -35, -40)

ggsave(
  args$output,
  ggplot() +
    geom_polygon(
      mapping = aes(long, lat, group = group),
      data = map,
      fill = NA,
      colour = '#888888',
      size = 0.2
    ) +
    geom_point(
      data = metadata %>% filter(!is_special),
      mapping = aes(longitude, latitude),
      shape = display_settings$observed_covariate_shape,
      colour = display_settings$observed_covariate_colour
    ) +
    geom_point(
      data = metadata %>% filter(is_special),
      mapping = aes(longitude, latitude),
      shape = display_settings$special_observed_covariate_shape,
      colour = display_settings$special_observed_covariate_colour,
      size = 3
    ) +
    geom_point(
      data = test_point_data,
      mapping = aes(longitude, latitude),
      shape = display_settings$unobserved_covariate_shape,
      colour = display_settings$unobserved_covariate_colour,
      size = 2.5
    ) +
    geom_segment(
      data = metadata %>% filter(is_special),
      mapping = aes(
        x = text_longitude,
        xend = longitude,
        y = text_latitude,
        yend = latitude
      ),
      colour = display_settings$special_observed_covariate_colour,
      linetype = 3
    ) +
    geom_segment(
      data = test_point_data,
      mapping = aes(
        x = text_longitude,
        xend = longitude,
        y = text_latitude,
        yend = latitude
      ),
      colour = display_settings$unobserved_covariate_colour,
      linetype = 3
    ) +
    geom_label(
      data = metadata %>% filter(is_special),
      mapping = aes(
        text_longitude,
        text_latitude,
        label = number
      ),
      colour = display_settings$special_observed_covariate_colour,
      label.size = 0
    ) +
    geom_label(
      data = test_point_data,
      mapping = aes(
        text_longitude,
        text_latitude,
        label = label
      ),
      colour = display_settings$unobserved_covariate_colour,
      label.size = 0
    ) +
    labs(x = 'Longitude', y = 'Latitude') +
    coord_quickmap() +
    theme(
      panel.grid.minor = element_blank()
    ),
  width = 0.7 * display_settings$full_page_plot_width,
  height = (7.5 / 8) * 0.7 * display_settings$full_page_plot_width,
  units = 'cm'
)
