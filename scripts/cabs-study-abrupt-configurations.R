source('scripts/partials/base.R')
source('scripts/partials/cabs-study.R')
library(dplyr, warn.conflicts = FALSE)

args <- parser$parse_args()

set.seed(20210406)

ar_simulate <- function(ar, n) {
  as.vector(arima.sim(list(ar = ar), n))
}

piecewise_ar_simulate <- function(model, n_times) {
  do.call(c, lapply(model, function(model_i) {
    ar_simulate(model_i$ar, n_times * model_i$proportion)
  }))
}

model1 <- list(
  list(ar = -0.5, proportion = 0.5),
  list(ar = 0.5, proportion = 0.5)
)
model2 <- list(
  list(ar = -0.9, proportion = 0.5),
  list(ar = 0.9, proportion = 0.5)
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
      replicate(
        n_replicates,
        do.call(cbind, lapply(models[[i]], piecewise_ar_simulate, n_times[i]))
      )
    })
  )

saveRDS(configurations, args$output)
