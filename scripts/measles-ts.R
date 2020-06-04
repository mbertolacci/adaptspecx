source('scripts/partials/base.R')
source('scripts/partials/display-settings.R')
source('scripts/partials/measles.R')
library(dplyr, warn.conflicts = FALSE)
library(futile.logger)
library(lubridate, warn.conflicts = FALSE)
library(tidyr)

parser$add_argument('--metadata')
parser$add_argument('--observations')
parser$add_argument('--period', default = 'full')
args <- parser$parse_args()

metadata <- readRDS(args$metadata)
observations <- readRDS(args$observations)

metadata <- metadata %>%
  mutate(
    map_row = measles_settings$state_grid[, 1],
    map_column = measles_settings$state_grid[, 2]
  )

observations <- observations %>%
  left_join(
    metadata %>% select(
      state,
      map_row,
      map_column
    ),
    by = 'state'
  )

if (args$period == 'before') {
  observations <- observations %>% filter(!after_vaccine)
} else if (args$period == 'after') {
  observations <- observations %>% filter(week_start > measles_settings$after_success)
}

max_date <- max(observations$week_start)

output <- ggplot() +
  geom_line(
    data = observations,
    mapping = aes(
      x = week_start,
      y = incidence_per_capita
    ),
    colour = display_settings$data_colour,
    na.rm = TRUE,
    size = 0.1
  ) +
  geom_label(
    data = metadata %>%
      mutate(date = max_date - days(40 * 52)),
    mapping = aes(
      x = date,
      y = if (args$period == 'full') {
        610
      } else {
        max(observations$incidence_per_capita, na.rm = TRUE)
      },
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
  scale_y_continuous(
    trans = if (args$period == 'after') 'log1p' else 'sqrt',
    breaks = if (args$period == 'after') {
      c(0, 1, 10)
    } else {
      c(10, 100, 600)
    }
  ) +
  labs(x = 'Date', y = 'Incidence per 100,000') +
  guides(colour = FALSE) +
  theme(
    axis.text.x = element_text(angle = -60, hjust = 0, vjust = 1),
    panel.grid.minor = element_blank(),
    strip.background = element_blank(),
    strip.text = element_blank()
  )

plot_width <- display_settings$full_page_plot_height - 2.5

ggsave(
  args$output,
  output,
  width = plot_width,
  height = 0.65 * plot_width,
  units = 'cm'
)
