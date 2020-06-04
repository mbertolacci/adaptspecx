library(methods)
suppressPackageStartupMessages(library(argparse))
library(ggplot2)

theme_set(theme_bw())
theme_replace(
  legend.background = element_blank(),
  legend.key = element_blank(),
  panel.background = element_blank(),
  strip.background = element_blank(),
  plot.background = element_blank(),
  panel.border = element_blank()
)

parser <- ArgumentParser()
parser$add_argument('--output')

scale_fill_wes_palette_c <- function(name, n = 100, ...) {
  scale_fill_gradientn(
    colours = wesanderson::wes_palette(name, n, type = 'continuous'),
    ...
  )
}
