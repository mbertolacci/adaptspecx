source('scripts/partials/base.R')

parser$add_argument('--metadata')
parser$add_argument('--samples')
args <- parser$parse_args()

metadata <- readRDS(args$metadata)
samples <- readRDS(args$samples)

sink(file = args$output)
print(samples$component_tuning)
print(tail(samples$log_posterior))
print(table(samples$categories[
  nrow(samples$categories),
  1 : nrow(metadata)
]))
print(samples$statistics)
for (name in names(samples$component_statistics[[1]])) {
  cat('=======', name, '\n')
  print(sapply(samples$component_statistics, getElement, name))
}
sink(NULL)
