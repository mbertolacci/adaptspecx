source('scripts/partials/base.R')
source('scripts/partials/multiple-simulation-study.R')

library(dplyr, warn.conflicts = FALSE)

parser$add_argument('--mse')
args <- parser$parse_args()

mse <- readRDS(args$mse)
sink(file = args$output)
knitr::kable(
  mse %>%
    group_by(metric, label) %>%
    summarise(
      q25 = quantile(value, probs = 0.25),
      q50 = quantile(value, probs = 0.50),
      q75 = quantile(value, probs = 0.75)
    )
)
sink(NULL)
