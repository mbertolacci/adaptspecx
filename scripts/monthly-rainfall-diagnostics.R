source('scripts/partials/monthly-rainfall.R')
source('scripts/partials/base.R')
suppressPackageStartupMessages(library(BayesSpec))

parser$add_argument('--samples')
args <- parser$parse_args()

ggsave(
  args$output,
  diagnostic_plots(window(
    readRDS(args$samples),
    thin = monthly_rainfall_settings$diagnostics_thin
  )),
  width = 130,
  height = 200,
  units = 'cm',
  limitsize = FALSE
)
