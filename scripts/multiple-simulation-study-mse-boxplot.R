source('scripts/partials/base.R')
source('scripts/partials/display-settings.R')
source('scripts/partials/multiple-simulation-study.R')

library(dplyr, warn.conflicts = FALSE)
library(patchwork)

parser$add_argument('--mse')
parser$add_argument('--mse-single')
args <- parser$parse_args()

mse <- readRDS(args$mse)
mse_single <- readRDS(args$mse_single)

JOINT_NAME <- 'AdaptSPEC-X'
INDEPENDENT_NAME <- 'AdaptSPEC,\nindependently'

plot_mse <- function(data, data_single) {
  bind_rows(
    data %>% mutate(which = JOINT_NAME),
    data_single %>% mutate(which = INDEPENDENT_NAME)
  ) %>%
    mutate(which = factor(which, c(JOINT_NAME, INDEPENDENT_NAME))) %>%
    ggplot(aes(label, value, colour = which, linetype = which)) +
      geom_boxplot(position = position_dodge()) +
      scale_colour_manual(
        values = c('black', '#008800')
      ) +
      scale_linetype_manual(
        values = c('solid', 'longdash')
      ) +
      labs(colour = NULL, linetype = NULL)
}

output_tvm <- plot_mse(
  mse %>% filter(metric == 'tvm'),
  mse_single %>% filter(metric == 'tvm')
) +
  labs(
    x = NULL,
    y = expression('MSE'['mean'](bold(u)))
  ) +
  theme(
    axis.title.x = element_blank(),
    axis.text.x = element_blank(),
    axis.ticks.x = element_blank()
  )

output_tvs <- plot_mse(
  mse %>% filter(metric == 'tvs'),
  mse_single %>% filter(metric == 'tvs')
) +
  labs(
    x = expression(bold(u)),
    y = expression('MSE'['spec'](bold(u)))
  )

output <- output_tvm +
  output_tvs +
  plot_layout(ncol = 1, guides = 'collect')

ggsave(
  args$output,
  output,
  width = display_settings$full_page_plot_width,
  height = (7 / 16) * display_settings$full_page_plot_width,
  units = 'cm'
)
