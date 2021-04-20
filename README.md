This repository contains code to reproduce the results in [``AdaptSPEC-X: Covariate Dependent Spectral Modeling of Multiple Nonstationary Time Series''](https://arxiv.org/abs/1908.06622).

# Getting started

The code has been tested on Ubuntu 18.04 and macOS 10.13. It may work on other systems, but it is not guaranteed.

You need R version 4.0.3 or later, and a working compiler toolchain. Ideally, for maximum performance, you should also install the [fftw3](http://www.fftw.org/) library.

R dependencies are locked using renv.

## Using Anaconda to get R and fftw3

The easiest way to install the required version of R and the recommended library fftw3 is to use [Anaconda](https://anaconda.org/). If you already have R and fftw3, you can skip this step.

Otherwise, once you've installed Anaconda (or [miniconda](https://docs.conda.io/en/latest/miniconda.html)), run

```
conda create -y --name adaptspecx-paper-code
conda activate adaptspecx-paper-code
conda config --env --add channels conda-forge
conda config --env --set channel_priority strict
conda install -y r-base==4.0.3 pkg-config fftw
```

## Other ways to get fftw3 on Ubuntu

Here are some instructions for installing R 4.0.3 on Ubuntu (disclaimer: I have not tried these): [https://rtask.thinkr.fr/installation-of-r-4-0-on-ubuntu-20-04-lts-and-tips-for-spatial-packages/](https://rtask.thinkr.fr/installation-of-r-4-0-on-ubuntu-20-04-lts-and-tips-for-spatial-packages/).

If you have installed R 4.0.3 some other way, you can install fftw3 using:

```
apt install libfftw3-dev
```

## Installing the required packages

Now on the command line go to the repository directory and run:

```
make bootstrap
```

This will install and run `renv` to get all the required packages.

# Getting data

Most of the data you need is already in the data directory. You will need to un-Gzip the `measles.csv.gz` file.  There is one file, `bom_hq.db`, that you need to get yourself. Please see the README.md file in that directory.

# Running the analysis

The code is run on the command line using `make`. Many steps of the analysis are independent and can be run in parallel, limited mostly by the available number of cores and the RAM on your machine.

In all cases, the resulting outputs are put in a `figures` directory. Once finished, each file in that directory corresponds to a figure in the paper.

First, set the number of available cores:

```
export N_CORES=<how many cores you want to use>
```

The machine needs at least 32 GB of RAM, possibly more.

## Simulation studies

You can reproduce the two simulation studies with:

```
OMP_NUM_THREADS=1 make -j $N_CORES multiple_simulation_study cabs_study
```

This is the slowest step because many replicates are generated. You also need around 120 GB of space available to store all the MCMC outputs.

## Rainfall application

You can reproduce the rainfall application with:

```
OMP_NUM_THREADS=$N_CORES make -j 1 monthly_rainfall
```

This runs one job at a time, using `$N_CORES` cores for each job, which may not be optimal. You can alternatively set the `-j` option to more than one to run more jobs at a time. In that case you will probably want to reduce `OMP_NUM_THREADS` to balance the jobs over the cores. For example, if you have 16 cores, it is probably faster to run

```
OMP_NUM_THREADS=4 make -j 4 monthly_rainfall
```

## Measles application

You can reproduce the measles application with:

```
OMP_NUM_THREADS=$N_CORES make -j 1 measles
```

See the previous section for a comment on distributing the jobs over the available cores.

# Note on the version of BayesSpec

The version of BayesSpec used to run the code is a development version and, as of writing, is not in CRAN.

# Troubleshooting

Please contact the author for any help with this repository.
