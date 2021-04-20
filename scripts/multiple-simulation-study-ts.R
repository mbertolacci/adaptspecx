source('scripts/partials/base.R')
source('scripts/partials/display-settings.R')
source('scripts/partials/multiple-simulation-study.R')

parser$add_argument('--metadata')
parser$add_argument('--replicates')
args <- parser$parse_args()

metadata <- readRDS(args$metadata)
replicate1 <- readRDS(args$replicates)[[1]]

tvm_true <- tvm_piecewise_ar_category(
  settings$components,
  metadata$category[metadata$example_indices],
  settings$n_times
)

example_data <- do.call(rbind, lapply(seq_along(metadata$example_indices), function(i) {
  index <- metadata$example_indices[i]

  t <- 1 : nrow(replicate1)

  data.frame(
    t,
    mu = tvm_true[, i],
    x = replicate1[, index],
    is_missing = is.na(replicate1[, index]),
    category = sprintf('r[%s]*" = "*%d', SITE_INDEX, metadata$category[index]),
    stringsAsFactors = FALSE
  )
}))

ggsave(
  args$output,
  ggplot(example_data, aes(t)) +
    geom_line(
      mapping = aes(y = x),
      colour = display_settings$data_colour
    ) +
    geom_line(
      mapping = aes(y = mu),
      colour = display_settings$true_tvm_colour,
      size = 0.6
    ) +
    geom_rug(
      data = subset(example_data, is_missing),
      sides = 'b',
      colour = 'red',
      size = 1
    ) +
    facet_wrap(~ category, ncol = 1, labeller = 'label_parsed') +
    labs(
      x = TIME_INDEX
    ),
  width = display_settings$half_page_plot_width,
  height = (8 / 7) * display_settings$half_page_plot_width,
  units = 'cm'
)
