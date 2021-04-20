source('scripts/partials/base.R')
source('scripts/partials/cabs-study.R')
library(dplyr, warn.conflicts = FALSE)

printf <- function(...) cat(sprintf(...))
paste_cols <- function(...) paste0(..., collapse = ' & ')

parser$add_argument('--tvs-mse-abrupt')
parser$add_argument('--tvs-mse-slow')
args <- parser$parse_args()

base_df <- data.frame(
  n_times = c(1000, 1000, 1000, 2000, 2000, 2000, 4000, 4000, 4000),
  n_time_series = c(20, 40, 80, 20, 40, 80, 20, 40, 80)
)

cabs_abrupt_df <- base_df
cabs_abrupt_df$mse_mean <- c(
  0.1190, 0.1130, 0.1079, 0.0748, 0.0755, 0.0702, 0.0617, 0.0610, 0.0607
)
cabs_abrupt_df$mse_sd <- c(
  0.0580, 0.0598, 0.0557, 0.0252, 0.0274, 0.0230, 0.0121, 0.0133, 0.0135
)

cabs_slow_df <- base_df
cabs_slow_df$mse_mean <- c(
  0.0353, 0.0260, 0.0206, 0.0249, 0.0185, 0.0148, 0.0177, 0.0137, 0.0110
)
cabs_slow_df$mse_sd <- c(
  0.0052, 0.0031, 0.0026, 0.0035, 0.0017, 0.0013, 0.0019, 0.0012, 0.0009
)

adaptspec_abrupt_df <- base_df %>%
  left_join(
    readRDS(args$tvs_mse_abrupt) %>%
      select(n_times, n_time_series, mse_mean, mse_sd),
    by = c('n_times', 'n_time_series')
  )

adaptspec_slow_df <- base_df %>%
  left_join(
    readRDS(args$tvs_mse_slow) %>%
      select(n_times, n_time_series, mse_mean, mse_sd),
    by = c('n_times', 'n_time_series')
  )

sink(file = args$output)
cat('\\begin{tabular}{ll|lll|lll} \n\\hline \\hline\n')
cat(' & &', paste_cols(
  sprintf(
    '\\multicolumn{3}{c%s}{\\textbf{%s}}',
    c('|', ''),
    c('Abruptly varying', 'Slowly varying')
  )
), '\\\\\n \\hline')
cat(paste_cols(
  sprintf(
    '\\multicolumn{1}{c%s}{%s}',
    c('', '|', '', '', '|', '', '', ''),
    c('$n$', '$N$', 'CABS', 'AdaptSPEC-X', 'Ratio', 'CABS', 'AdaptSPEC-X', 'Ratio')
  )
), '\\\\\n \\hline')
for (i in seq_len(nrow(base_df))) {
  printf(
    '%d & %d & %.04f (%.04f) & %.04f (%.04f) & %.01f & %.04f (%.04f) & %.04f (%.04f) & %.01f \\\\\n',
    base_df$n_times[i],
    base_df$n_time_series[i],
    cabs_abrupt_df$mse_mean[i],
    cabs_abrupt_df$mse_sd[i],
    adaptspec_abrupt_df$mse_mean[i],
    adaptspec_abrupt_df$mse_sd[i],
    cabs_abrupt_df$mse_mean[i] / adaptspec_abrupt_df$mse_mean[i],
    cabs_slow_df$mse_mean[i],
    cabs_slow_df$mse_sd[i],
    adaptspec_slow_df$mse_mean[i],
    adaptspec_slow_df$mse_sd[i],
    cabs_slow_df$mse_mean[i] / adaptspec_slow_df$mse_mean[i]
  )
}
cat('\\hline\n')
cat('\\end{tabular}\n')
sink(NULL)
