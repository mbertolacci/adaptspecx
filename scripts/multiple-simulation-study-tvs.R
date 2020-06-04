source('scripts/partials/base.R')
source('scripts/partials/display-settings.R')
source('scripts/partials/multiple-simulation-study.R')

library(dplyr, warn.conflicts = FALSE)
library(gridExtra, warn.conflicts = FALSE)

tvsm_to_df <- function(tvsm, i) {
  tvsm_i <- tvsm[, , i]
  data.frame(
    time = attr(tvsm, 'times')[as.vector(col(tvsm_i))],
    frequency = attr(tvsm, 'frequencies')[as.vector(row(tvsm_i))],
    log_spectrum = as.vector(tvsm_i)
  )
}

get_legend <- function(a_plot){
  tmp <- ggplot_gtable(ggplot_build(a_plot))
  legend <- which(sapply(tmp$grobs, function(x) x$name) == 'guide-box')
  legend <- tmp$grobs[[legend]]
  return(legend)
}

which_quantile <- function(x, prob) {
  order(x)[round(prob * length(x))]
}

parser$add_argument('--tvs')
parser$add_argument('--mse')
args <- parser$parse_args()

tvs <- readRDS(args$tvs)
mse <- readRDS(args$mse)

tvs_true <- tvs_piecewise_ar_category(
  settings$components,
  c(1 : 4, 1 : 4),
  settings$tvs_n_frequencies,
  settings$n_times
)
example_points <- paste0('D', 1 : 4)
test_points <- paste0('T', 1 : 4)
column_names <- c(example_points, test_points)

tvs_df <- bind_rows(lapply(seq_along(column_names), function(index) {
  label_i <- column_names[index]

  median_index <- mse %>%
    filter(
      label == label_i,
      metric == 'tvs'
    ) %>%
    slice(which_quantile(value, 0.5)) %>%
    pull(replicate)

  bind_rows(
    tvsm_to_df(tvs[[median_index]], index) %>%
      mutate(label = label_i, which = 'Estimate'),
    tvsm_to_df(tvs_true, index) %>%
      mutate(label = label_i, which = 'True')
  )
})) %>%
  mutate(which = factor(
    which,
    levels = c('True', 'Estimate'),
    labels = c(
      expression('log '*f(t, omega, bold(u))),
      expression('log '*hat(f)(t, omega, bold(u)))
    )
  ))

max_time <- max(tvs_df$time)
max_frequency <- max(tvs_df$frequency)
log_power_limits <- range(tvs_df$log_spectrum)

plot_tvs <- function(data) {
  ggplot(
    data,
    aes(
      xmin = time,
      xmax = max_time,
      ymin = frequency,
      ymax = max_frequency,
      fill = log_spectrum
    )
  ) +
    geom_rect() +
    facet_grid(which ~ label, labeller = 'label_parsed') +
    labs(x = NULL, y = NULL, fill = 'Log power') +
    scale_y_continuous(breaks = c(0, 0.5)) +
    display_settings$tvs_fill_palette(
      limits = log_power_limits
    ) +
    theme(
      axis.text.y = element_text(size = rel(0.75)),
      strip.text = element_text(size = rel(0.6))
    )
}

example_plot <- plot_tvs(tvs_df %>% filter(label %in% example_points))
test_point_plot <- plot_tvs(tvs_df %>% filter(label %in% test_points))
legend <- get_legend(test_point_plot)

plot_width <- display_settings$full_page_plot_width
plot_height <- (10 / 16) * display_settings$full_page_plot_width
legend_width <- 2.5
y_axis_label_width <- 0.5
x_axis_label_height <- 0.8

ggsave(
  args$output,
  arrangeGrob(
    example_plot + theme(legend.position = 'none'),
    test_point_plot + theme(legend.position = 'none'),
    legend,
    grid::textGrob(expression(omega), rot = 90, gp = grid::gpar(fontsize = 10)),
    grid::textGrob(expression(t), gp = grid::gpar(fontsize = 10)),
    layout_matrix = rbind(
        c(4, 1, 3),
        c(4, 2, 3),
        c(NA, 5, NA)
    ),
    widths = c(y_axis_label_width, plot_width - y_axis_label_width - legend_width, legend_width),
    heights = c((plot_height - x_axis_label_height) / 2, (plot_height - x_axis_label_height) / 2, x_axis_label_height)
  ),
  width = plot_width,
  height = plot_height,
  units = 'cm',
  dpi = display_settings$png_plot_dpi
)
