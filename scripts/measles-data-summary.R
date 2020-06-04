source('scripts/partials/base.R')
source('scripts/partials/measles.R')
library(dplyr, warn.conflicts = FALSE)

printf <- function(...) cat(sprintf(...))

parser$add_argument('--metadata')
parser$add_argument('--observations')
args <- parser$parse_args()

metadata <- readRDS(args$metadata)
observations <- readRDS(args$observations)

sink(file = args$output)
printf('Number of states = %d\n', nrow(metadata))
printf('Number of observations = %d\n', nrow(observations))
printf('Start date = %s\n', min(observations$week_start))
printf('End date = %s\n', max(observations$week_start))
printf('Number of weeks = %d\n', length(unique(observations$week_start)))
printf('Number of zero weeks = %d\n', sum(observations$incidence_per_capita == 0, na.rm = TRUE))
printf('Number of missing weeks in total = %d\n', sum(is.na(observations$incidence_per_capita)))
cat('States with most missing weeks:\n')
print(
  observations %>%
    group_by(state) %>%
    summarise(n_missing = sum(is.na(incidence_per_capita))) %>%
    arrange(-n_missing)
)
sink(NULL)
