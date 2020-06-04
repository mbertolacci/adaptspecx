library(dplyr, warn.conflicts = FALSE)
source('scripts/partials/base.R')

printf <- function(...) cat(sprintf(...))

parser$add_argument('--metadata')
parser$add_argument('--observations')
args <- parser$parse_args()

metadata <- readRDS(args$metadata)
observations <- readRDS(args$observations)

sink(file = args$output)
printf('Number of sites = %d\n', nrow(metadata))
printf('Number of observations = %d\n', nrow(observations))
printf('Number of months = %d\n', length(unique(observations$month)))
printf('Number of zero months = %d\n', sum(observations$average_rainfall == 0, na.rm = TRUE))
printf('Number of missing months in total = %d\n', sum(is.na(observations$average_rainfall)))
cat('Site with most missing months:\n')
print(
  observations %>%
    group_by(site_number) %>%
    summarise(
      n_missing = sum(is.na(average_rainfall)),
      proportion_missing = n_missing / n()
    ) %>%
    arrange(-n_missing)
)
sink(NULL)
