source('scripts/partials/base.R')
source('scripts/partials/measles.R')
suppressPackageStartupMessages(library(BayesSpec))

parser$add_argument('--samples')
args <- parser$parse_args()

ggsave(
  args$output,
  diagnostic_plots(window(
    readRDS(args$samples),
    thin = measles_settings$diagnostics_thin
  )),
  width = 130,
  height = 200,
  units = 'cm',
  limitsize = FALSE
)
