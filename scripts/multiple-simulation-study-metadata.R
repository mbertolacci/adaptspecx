source('scripts/partials/base.R')
source('scripts/partials/multiple-simulation-study.R')

set.seed(20180821)

args <- parser$parse_args()

design_matrix <- rbind(data.frame(
  u1 = runif(settings$n_time_series),
  u2 = runif(settings$n_time_series)
), data.frame(
  u1 = settings$test_points[, 1],
  u2 = settings$test_points[, 2]
))

category <- rep(4, nrow(design_matrix))
category[with(design_matrix, {
  u2 < u1
})] <- 1
category[with(design_matrix, {
  sqrt((u1 - 0.25) ^ 2 + (u2 - 0.75) ^ 2) < 0.15
})] <- 2
category[with(design_matrix, {
  sqrt((u1 - 0.75) ^ 2 + (u2 - 0.25) ^ 2) < 0.2
})] <- 3

example_indices <- c(
  36,
  15,
  86,
  40
)

saveRDS(list(
  design_matrix = design_matrix,
  category = category,
  example_indices = example_indices
), args$output)
