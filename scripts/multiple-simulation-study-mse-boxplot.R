source('scripts/partials/base.R')
source('scripts/partials/display-settings.R')
source('scripts/partials/multiple-simulation-study.R')

library(dplyr, warn.conflicts = FALSE)
library(gridExtra, warn.conflicts = FALSE)

parser$add_argument('--mse')
args <- parser$parse_args()

mse <- readRDS(args$mse)

plot_mse <- function(data) {
  ggplot(data, aes(label, value)) +
    geom_boxplot()
}

output_tvm <- plot_mse(mse %>% filter(metric == 'tvm')) +
  labs(
    x = NULL,
    y = expression('MSE'['mean'](bold(u)))
  ) +
  theme(
    axis.title.x = element_blank(),
    axis.text.x = element_blank(),
    axis.ticks.x = element_blank()
  )

output_tvs <- plot_mse(mse %>% filter(metric == 'tvs')) +
  labs(
    x = expression(bold(u)),
    y = expression('MSE'['spec'](bold(u)))
  )

ggsave(
  args$output,
  arrangeGrob(
    output_tvm,
    output_tvs,
    heights = c(0.45, 0.55),
    ncol = 1
  ),
  width = display_settings$full_page_plot_width,
  height = (9 / 16) * display_settings$full_page_plot_width,
  units = 'cm'
)
