source('scripts/partials/base.R')
source('scripts/partials/display-settings.R')
source('scripts/partials/multiple-simulation-study.R')

library(dplyr, warn.conflicts = FALSE)
library(tidyr)

parser$add_argument('--metadata')
parser$add_argument('--tvm')
parser$add_argument('--tvs')
args <- parser$parse_args()

metadata <- readRDS(args$metadata)
tvm <- readRDS(args$tvm)
tvs <- readRDS(args$tvs)

tvm_true <- tvm_piecewise_ar_category(
  settings$components,
  c(1 : 4, 1 : 4),
  settings$n_times
)

tvs_true <- tvs_piecewise_ar_category(
  settings$components,
  c(1 : 4, 1 : 4),
  settings$tvs_n_frequencies,
  settings$n_times
)

column_names <- c(paste0('D', 1 : 4), paste0('T', 1 : 4))

mse_tvm <- t(sapply(tvm, function(tvm_i) {
  colMeans((tvm_i - tvm_true) ^ 2)
}))
colnames(mse_tvm) <- column_names

mse_tvs <- t(sapply(tvs, function(tvs_i) {
  apply((tvs_i - tvs_true) ^ 2, 3, mean)
}))
colnames(mse_tvs) <- column_names

gather_mse <- function(data) {
  data %>%
    as.data.frame() %>%
    mutate(replicate = 1 : n()) %>%
    gather(label, value, -replicate)
}

output <- rbind(
  gather_mse(mse_tvm) %>%
    mutate(metric = 'tvm'),
  gather_mse(mse_tvs) %>%
    mutate(metric = 'tvs')
)

saveRDS(output, args$output)
