source('scripts/partials/base.R')
source('scripts/partials/cabs-study.R')
library(futile.logger)
library(dplyr, warn.conflicts = FALSE)

args <- parser$parse_args()

set.seed(20210406)

slow_ar_simulate <- function(model, n_times) {
  output <- rep(NA, n_times)
  output[1] <- rnorm(1)
  for (t in 2 : n_times) {
    output[t] <- (
      model$a + model$b * t / n_times
    ) * output[t - 1] + rnorm(1)
  }
  output
}

model1 <- list(
  a = -0.5,
  b = 1
)
model2 <- list(
  a = -0.9,
  b = 9 / 5
)

n_replicates <- 100
configurations <- expand.grid(
  n_times = c(1000, 2000, 4000),
  n_time_series = c(20, 40, 80)
) %>%
  mutate(
    w = lapply(seq_len(n()), function(i) {
      (seq_len(n_time_series[i]) - 1) / (n_time_series[i] - 1)
    }),
    models = lapply(seq_len(n()), function(i) {
      lapply(w[[i]], function(w_i_j) if (w_i_j < 0.5) model1 else model2)
    }),
    y_replicates = lapply(seq_len(n()), function(i) {
      flog.info('Generating replicate %d', i)
      replicate(
        n_replicates,
        do.call(cbind, lapply(models[[i]], slow_ar_simulate, n_times[i]))
      )
    })
  )

saveRDS(configurations, args$output)
