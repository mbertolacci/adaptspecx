source('scripts/partials/base.R')
source('scripts/partials/display-settings.R')
source('scripts/partials/multiple-simulation-study.R')

library(dplyr, warn.conflicts = FALSE)
library(gridExtra, warn.conflicts = FALSE)

tvm_to_df <- function(tvm, i) {
  tvm_i <- tvm[, i]
  data.frame(
    time = attr(tvm, 'times'),
    value = as.vector(tvm_i)
  )
}

which_quantile <- function(x, prob) {
  order(x)[round(prob * length(x))]
}

parser$add_argument('--tvm')
parser$add_argument('--mse')
args <- parser$parse_args()

tvm <- readRDS(args$tvm)
mse <- readRDS(args$mse)

tvm_true <- tvm_piecewise_ar_category(
  settings$components,
  c(1 : 4, 1 : 4),
  settings$n_times
)
example_points <- paste0('D', 1 : 4)
test_points <- paste0('T', 1 : 4)
column_names <- c(example_points, test_points)

tvm_df <- bind_rows(lapply(seq_along(column_names), function(index) {
  label_i <- column_names[index]

  median_index <- mse %>%
    filter(
      label == label_i,
      metric == 'tvm'
    ) %>%
    slice(which_quantile(value, 0.5)) %>%
    pull(replicate)

  bind_rows(
    tvm_to_df(tvm[[median_index]], index) %>%
      mutate(label = label_i, which = 'Estimate'),
    tvm_to_df(tvm_true, index) %>%
      mutate(label = label_i, which = 'True')
  )
})) %>%
  mutate(
    which = factor(which, levels = c(
      'True',
      'Estimate'
    ))
  )

output <- ggplot(tvm_df, aes(time, value, colour = which)) +
  geom_line() +
  facet_wrap(~ label, ncol = 4) +
  labs(x = expression(t), y = 'Mean', colour = NULL) +
  scale_colour_manual(
    labels = c(
      expression(mu(t, bold(u))),
      expression(hat(mu)(t, bold(u)))
    ),
    values = c(
      display_settings$true_tvm_colour,
      display_settings$estimated_tvm_colour
    )
  ) +
  ylim(-2.2, 2.2)

ggsave(
  args$output,
  output,
  width = display_settings$full_page_plot_width,
  height = (6.2 / 16) * display_settings$full_page_plot_width,
  units = 'cm'
)
