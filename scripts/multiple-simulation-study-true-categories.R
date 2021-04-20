source('scripts/partials/base.R')
source('scripts/partials/display-settings.R')
source('scripts/partials/multiple-simulation-study.R')

library(dplyr, warn.conflicts = FALSE)
library(sp)

parser$add_argument('--metadata')
args <- parser$parse_args()

metadata <- readRDS(args$metadata)

design_matrix <- metadata$design_matrix[1 : settings$n_time_series, ]
design_matrix$label <- NA
design_matrix$label[metadata$example_indices] <- sprintf(
  'D%d',
  1 : length(metadata$example_indices)
)
test_design_matrix <- metadata$design_matrix[
  (settings$n_time_series + 1) : nrow(metadata$design_matrix),
] %>%
  mutate(label = sprintf('T%d', 1 : n()))

angles <- seq(0, 2 * pi, length.out = 100)

top_left_circle <- cbind(
  0.25 + 0.15 * cos(angles),
  0.75 + 0.15 * sin(angles)
)
top_left_triangle <- rbind(
  c(0, 0),
  c(0, 1),
  c(1, 1),
  c(0, 0)
)
bottom_right_circle <- cbind(
  0.75 + 0.2 * cos(angles),
  0.25 + 0.2 * sin(angles)
)
bottom_right_triangle <- rbind(
  c(0, 0),
  c(1, 1),
  c(1, 0),
  c(0, 0)
)

category_sp <- SpatialPolygonsDataFrame(SpatialPolygons(list(
  Polygons(list(
    Polygon(top_left_triangle),
    Polygon(top_left_circle, hole = TRUE)
  ), 'top_left_triangle'),
  Polygons(list(Polygon(top_left_circle)), 'top_left_circle'),
  Polygons(list(
    Polygon(bottom_right_triangle),
    Polygon(bottom_right_circle, hole = TRUE)
  ), 'bottom_right_triangle'),
  Polygons(list(Polygon(bottom_right_circle)), 'bottom_right_circle')
)), data.frame(
  id = c(
    'top_left_triangle',
    'top_left_circle',
    'bottom_right_triangle',
    'bottom_right_circle'
  ),
  category = factor(c(4, 2, 1, 3))
), match.ID = 'id')

category_data <- fortify(category_sp) %>%
  select(u1 = long, u2 = lat, id, group) %>%
  left_join(
    category_sp@data,
    by = 'id'
  )

design_matrix$nudge1 <- NA
design_matrix$nudge2 <- NA

design_matrix$nudge1[
  !is.na(design_matrix$label)
] <- c(0.08, 0.07, 0.07, 0.07)
design_matrix$nudge2[
  !is.na(design_matrix$label)
] <- c(-0.02, -0.06, 0.06, 0.06)

test_design_matrix$nudge1 <- c(0, -0.08, 0.07, 0.07)
test_design_matrix$nudge2 <- c(0.07, 0, -0.06, 0.06)

ggsave(
  args$output,
  ggplot(
    mapping = aes(u1, u2)
  ) +
    geom_polygon(
      data = category_data,
      mapping = aes(group = group, fill = category)
    ) +
    geom_point(
      data = design_matrix %>% filter(is.na(label)),
      shape = display_settings$observed_covariate_shape,
      colour = display_settings$observed_covariate_colour
    ) +
    geom_point(
      data = design_matrix %>% filter(!is.na(label)),
      shape = display_settings$special_observed_covariate_shape,
      colour = display_settings$special_observed_covariate_colour,
      size = 2.5
    ) +
    geom_text(
      data = design_matrix,
      mapping = aes(x = u1 + nudge1, y = u2 + nudge2, label = label),
      colour = display_settings$special_observed_covariate_colour,
      na.rm = TRUE
    ) +
    geom_point(
      data = test_design_matrix,
      shape = display_settings$unobserved_covariate_shape,
      colour = display_settings$unobserved_covariate_colour,
      size = 2
    ) +
    geom_text(
      data = test_design_matrix,
      mapping = aes(x = u1 + nudge1, y = u2 + nudge2, label = label),
      colour = display_settings$unobserved_covariate_colour
    ) +
    scale_fill_manual(values = wesanderson::wes_palette('Moonrise3', 4)[c(1, 3, 2, 4)]) +
    coord_fixed() +
    labs(x = expression(u[1]), y = expression(u[2]), fill = expression(r[j]*' =')) +
    theme(
      legend.position = 'top'
    ),
  width = display_settings$half_page_plot_width,
  height = (8 / 7) * display_settings$half_page_plot_width,
  units = 'cm'
)
