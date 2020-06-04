This repository contains code to reproduce the results in [``AdaptSPEC-X: Covariate Dependent Spectral Modeling of Multiple Nonstationary Time Series''](https://arxiv.org/abs/1908.06622).

# How to run this code

The code has been tested on Ubuntu 18.04 and macOS 10.13. It may work on other systems, but it is not guaranteed.

First, you need to install the following packages in R:

```r
# Install from CRAN
install.packages(c(
  'RSQLite', 'RSpectra', 'Rcpp', 'RcppEigen', 'argparse', 'assist', 'coda',
  'dbplyr', 'devtools', 'dplyr', 'futile.logger', 'ggplot2', 'gridExtra',
  'lubridate', 'matrixStats', 'tensor', 'tidyr', 'wesanderson', 'withr'
))

# Install from github
devtools::install_github('mbertolacci/acoda')
```

In order to speed up the code, it is best to install `fftw3`. For Ubuntu, this can be done on the command line with:

```
apt install libfftw3-dev
```

You also need to reconstruct one data file from sources; see the [README.md file in the data directory](data/README.md).

Finally, you should be able to run the code from the command line with:

```
make
```

If you system has a lot of RAM and CPUs, you may want to run with `make -j4` to speed this up.

# Note on the version of BayesSpec

The version of BayesSpec used to run the code is included in this repository. You can get the latest copy from [CRAN](https://cran.r-project.org/package=BayesSpec), but it is not guaranteed to work.

# Troubleshooting

Please contact the author for any help with this repository.
