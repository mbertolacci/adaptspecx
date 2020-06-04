RSCRIPT = Rscript --vanilla

CHAINS = 1 2 3 4
REPLICATES = 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100

FIGURES = figures/multiple-simulation-study-true-categories.pdf \
	figures/multiple-simulation-study-ts.pdf \
	figures/multiple-simulation-study-mse-boxplot.pdf \
	figures/multiple-simulation-study-mse-summary.txt \
	figures/multiple-simulation-study-tvm.pdf \
	figures/multiple-simulation-study-tvs.png \
	figures/monthly-rainfall-map.pdf \
	figures/monthly-rainfall-ts.pdf \
	figures/monthly-rainfall-data-summary.txt \
	$(foreach CHAIN,$(CHAINS),figures/monthly-rainfall-diagnostics-$(CHAIN).png) \
	figures/monthly-rainfall-tvm.pdf \
	figures/monthly-rainfall-tvm-all.pdf \
	figures/monthly-rainfall-tvs.png \
	figures/monthly-rainfall-tvs-all.png \
	figures/monthly-rainfall-tvs-unscaled.png \
	figures/monthly-rainfall-tvs-unscaled-all.png \
	$(foreach CHAIN,$(CHAINS),figures/monthly-rainfall-mcmc-statistics-$(CHAIN).txt) \
	figures/monthly-rainfall-tests.txt \
	figures/monthly-rainfall-tests-table.tex \
	figures/measles-data-summary.txt \
	figures/measles-ts.pdf \
	$(foreach CHAIN,$(CHAINS),figures/measles-diagnostics-$(CHAIN).png) \
	figures/measles-tvm.pdf \
	figures/measles-tvm-before.pdf \
	figures/measles-tvm-after.pdf \
	figures/measles-tvs.png \
	figures/measles-tvs-before.png \
	figures/measles-tvs-inter.png \
	figures/measles-tvs-after.png \
	figures/measles-tvs-special.png \
	figures/measles-tvs-special-before.png \
	$(foreach CHAIN,$(CHAINS),figures/measles-mcmc-statistics-$(CHAIN).txt) \
	figures/measles-tests.txt


# Partials
BASE_SCRIPT = scripts/partials/base.R
DISPLAY_SETTINGS_SCRIPT = scripts/partials/display-settings.R

# Scripts
MCMC_STATISTICS_SCRIPT = scripts/mcmc-statistics.R

AUSTRALIA_MAP = data/australia-map.rds
BOM_HQ = data/bom_hq.db

all: $(FIGURES)

## Multiple simulation study

MULTIPLE_SIMULATION_STUDY_REPLICATES = intermediate/multiple-simulation-study-replicates.rds
MULTIPLE_SIMULATION_STUDY_METADATA = intermediate/multiple-simulation-study-metadata.rds
MULTIPLE_SIMULATION_STUDY_TVMM = intermediate/multiple-simulation-study-tvmm.rds
MULTIPLE_SIMULATION_STUDY_TVSM = intermediate/multiple-simulation-study-tvsm.rds
MULTIPLE_SIMULATION_STUDY_MSE = intermediate/multiple-simulation-study-mse.rds
MULTIPLE_SIMULATION_STUDY_SAMPLES_DIRECTORY = intermediate/multiple-simulation-study-samples
MULTIPLE_SIMULATION_STUDY_SAMPLES_BASE = $(MULTIPLE_SIMULATION_STUDY_SAMPLES_DIRECTORY)/samples
MULTIPLE_SIMULATION_STUDY_SAMPLES = $(foreach REPLICATE,$(REPLICATES),$(MULTIPLE_SIMULATION_STUDY_SAMPLES_BASE)-$(REPLICATE).rds)

figures/multiple-simulation-study-true-categories.pdf: scripts/multiple-simulation-study-true-categories.R $(MULTIPLE_SIMULATION_STUDY_METADATA) $(DISPLAY_SETTINGS_SCRIPT) $(BASE_SCRIPT)
	$(RSCRIPT) $< \
		--metadata $(MULTIPLE_SIMULATION_STUDY_METADATA) \
		--output $@

figures/multiple-simulation-study-ts.pdf: scripts/multiple-simulation-study-ts.R $(MULTIPLE_SIMULATION_STUDY_REPLICATES) $(MULTIPLE_SIMULATION_STUDY_METADATA) $(DISPLAY_SETTINGS_SCRIPT) $(BASE_SCRIPT)
	$(RSCRIPT) $< \
		--metadata $(MULTIPLE_SIMULATION_STUDY_METADATA) \
		--replicates $(MULTIPLE_SIMULATION_STUDY_REPLICATES) \
		--output $@

figures/multiple-simulation-study-mse-boxplot.pdf: scripts/multiple-simulation-study-mse-boxplot.R $(MULTIPLE_SIMULATION_STUDY_MSE) $(DISPLAY_SETTINGS_SCRIPT) $(BASE_SCRIPT)
	$(RSCRIPT) $< \
		--mse $(MULTIPLE_SIMULATION_STUDY_MSE) \
		--output $@

figures/multiple-simulation-study-mse-summary.txt: scripts/multiple-simulation-study-mse-summary.R $(MULTIPLE_SIMULATION_STUDY_MSE) $(BASE_SCRIPT)
	$(RSCRIPT) $< \
		--mse $(MULTIPLE_SIMULATION_STUDY_MSE) \
		--output $@

figures/multiple-simulation-study-tvm.pdf: scripts/multiple-simulation-study-tvm.R $(MULTIPLE_SIMULATION_STUDY_TVMM) $(MULTIPLE_SIMULATION_STUDY_MSE) $(DISPLAY_SETTINGS_SCRIPT) $(BASE_SCRIPT)
	$(RSCRIPT) $< \
		--mse $(MULTIPLE_SIMULATION_STUDY_MSE) \
		--tvm $(MULTIPLE_SIMULATION_STUDY_TVMM) \
		--output $@

figures/multiple-simulation-study-tvs.png: scripts/multiple-simulation-study-tvs.R $(MULTIPLE_SIMULATION_STUDY_TVSM) $(MULTIPLE_SIMULATION_STUDY_MSE) $(DISPLAY_SETTINGS_SCRIPT) $(BASE_SCRIPT)
	$(RSCRIPT) $< \
		--mse $(MULTIPLE_SIMULATION_STUDY_MSE) \
		--tvs $(MULTIPLE_SIMULATION_STUDY_TVSM) \
		--output $@

$(MULTIPLE_SIMULATION_STUDY_MSE): scripts/multiple-simulation-study-mse.R $(MULTIPLE_SIMULATION_STUDY_METADATA) $(MULTIPLE_SIMULATION_STUDY_TVMM) $(MULTIPLE_SIMULATION_STUDY_TVSM)
	$(RSCRIPT) $< \
		--metadata $(MULTIPLE_SIMULATION_STUDY_METADATA) \
		--tvm $(MULTIPLE_SIMULATION_STUDY_TVMM) \
		--tvs $(MULTIPLE_SIMULATION_STUDY_TVSM) \
		--output $@

$(MULTIPLE_SIMULATION_STUDY_TVSM): scripts/multiple-simulation-study-tvsm.R $(MULTIPLE_SIMULATION_STUDY_SAMPLES) $(MULTIPLE_SIMULATION_STUDY_METADATA) $(BASE_SCRIPT)
	$(RSCRIPT) $< \
		--metadata $(MULTIPLE_SIMULATION_STUDY_METADATA) \
		--samples-directory $(MULTIPLE_SIMULATION_STUDY_SAMPLES_DIRECTORY) \
		--output $@

$(MULTIPLE_SIMULATION_STUDY_TVMM): scripts/multiple-simulation-study-tvmm.R $(MULTIPLE_SIMULATION_STUDY_SAMPLES) $(MULTIPLE_SIMULATION_STUDY_METADATA) $(BASE_SCRIPT)
	$(RSCRIPT) $< \
		--metadata $(MULTIPLE_SIMULATION_STUDY_METADATA) \
		--samples-directory $(MULTIPLE_SIMULATION_STUDY_SAMPLES_DIRECTORY) \
		--output $@

$(MULTIPLE_SIMULATION_STUDY_SAMPLES_BASE)-%.rds: scripts/multiple-simulation-study-samples.R $(MULTIPLE_SIMULATION_STUDY_REPLICATES) $(MULTIPLE_SIMULATION_STUDY_METADATA) $(BASE_SCRIPT)
	$(RSCRIPT) $< \
		--replicates $(MULTIPLE_SIMULATION_STUDY_REPLICATES) \
		--metadata $(MULTIPLE_SIMULATION_STUDY_METADATA) \
		--replicate-number $* \
		--output $@

$(MULTIPLE_SIMULATION_STUDY_REPLICATES): scripts/multiple-simulation-study-replicates.R $(MULTIPLE_SIMULATION_STUDY_METADATA) $(BASE_SCRIPT)
	$(RSCRIPT) $< \
		--metadata $(MULTIPLE_SIMULATION_STUDY_METADATA) \
		--output $@

$(MULTIPLE_SIMULATION_STUDY_METADATA): scripts/multiple-simulation-study-metadata.R $(BASE_SCRIPT)
	$(RSCRIPT) $< \
		--output $@

## Monthly rainfall

MONTHLY_RAINFALL_METADATA = intermediate/monthly-rainfall-metadata.rds
MONTHLY_RAINFALL_OBSERVATIONS = intermediate/monthly-rainfall-observations.rds
MONTHLY_RAINFALL_SAMPLES = $(foreach CHAIN,$(CHAINS),intermediate/monthly-rainfall-samples-$(CHAIN).rds)

MONTHLY_RAINFALL_TS_DEPS = scripts/monthly-rainfall-ts.R $(AUSTRALIA_MAP) $(MONTHLY_RAINFALL_METADATA) $(MONTHLY_RAINFALL_OBSERVATIONS) $(DISPLAY_SETTINGS_SCRIPT) $(BASE_SCRIPT)
MONTHLY_RAINFALL_TS_CALL = $(RSCRIPT) scripts/monthly-rainfall-ts.R \
		--map $(AUSTRALIA_MAP) \
		--metadata $(MONTHLY_RAINFALL_METADATA) \
		--observations $(MONTHLY_RAINFALL_OBSERVATIONS)

MONTHLY_RAINFALL_TVM_DEPS = scripts/monthly-rainfall-tvm.R $(MONTHLY_RAINFALL_OBSERVATIONS) $(AUSTRALIA_MAP) $(DISPLAY_SETTINGS_SCRIPT) $(BASE_SCRIPT)
MONTHLY_RAINFALL_TVM_CALL = $(RSCRIPT) scripts/monthly-rainfall-tvm.R \
	--observations $(MONTHLY_RAINFALL_OBSERVATIONS) \
	--map $(AUSTRALIA_MAP)

MONTHLY_RAINFALL_TVS_DEPS = scripts/monthly-rainfall-tvs.R $(AUSTRALIA_MAP) $(DISPLAY_SETTINGS_SCRIPT) $(BASE_SCRIPT)
MONTHLY_RAINFALL_TVS_CALL = $(RSCRIPT) scripts/monthly-rainfall-tvs.R \
	--map $(AUSTRALIA_MAP)

figures/monthly-rainfall-map.pdf: scripts/monthly-rainfall-map.R $(AUSTRALIA_MAP) $(MONTHLY_RAINFALL_METADATA) $(DISPLAY_SETTINGS_SCRIPT) $(BASE_SCRIPT)
	$(RSCRIPT) $< \
		--map $(AUSTRALIA_MAP) \
		--metadata $(MONTHLY_RAINFALL_METADATA) \
		--output $@

figures/monthly-rainfall-ts.pdf: $(MONTHLY_RAINFALL_TS_DEPS)
	$(MONTHLY_RAINFALL_TS_CALL) \
		--output $@

figures/monthly-rainfall-data-summary.txt: scripts/monthly-rainfall-data-summary.R $(MONTHLY_RAINFALL_METADATA) $(MONTHLY_RAINFALL_OBSERVATIONS) $(BASE_SCRIPT)
	$(RSCRIPT) $< \
		--metadata $(MONTHLY_RAINFALL_METADATA) \
		--observations $(MONTHLY_RAINFALL_OBSERVATIONS) \
		--output $@

figures/monthly-rainfall-diagnostics-%.png: scripts/monthly-rainfall-diagnostics.R intermediate/monthly-rainfall-samples-%.rds $(BASE_SCRIPT)
	$(RSCRIPT) $< \
		--samples intermediate/monthly-rainfall-samples-$*.rds \
		--output $@

figures/monthly-rainfall-tvm.pdf: intermediate/monthly-rainfall-tvmm.rds $(MONTHLY_RAINFALL_TVM_DEPS)
	$(MONTHLY_RAINFALL_TVM_CALL) \
		--tvmm intermediate/monthly-rainfall-tvmm.rds \
		--output $@

figures/monthly-rainfall-tvm-all.pdf: intermediate/monthly-rainfall-tvmm.rds $(MONTHLY_RAINFALL_TVM_DEPS)
	$(MONTHLY_RAINFALL_TVM_CALL) \
		--all \
		--tvmm intermediate/monthly-rainfall-tvmm.rds \
		--output $@

figures/monthly-rainfall-tvs.png: intermediate/monthly-rainfall-tvsm.rds $(MONTHLY_RAINFALL_TVS_DEPS)
	$(MONTHLY_RAINFALL_TVS_CALL) \
		--tvsm intermediate/monthly-rainfall-tvsm.rds \
		--output $@

figures/monthly-rainfall-tvs-all.png: intermediate/monthly-rainfall-tvsm.rds $(MONTHLY_RAINFALL_TVS_DEPS)
	$(MONTHLY_RAINFALL_TVS_CALL) \
	    --all \
		--tvsm intermediate/monthly-rainfall-tvsm.rds \
		--output $@

figures/monthly-rainfall-tvs-unscaled.png: intermediate/monthly-rainfall-tvsm.rds $(MONTHLY_RAINFALL_TVS_DEPS)
	$(MONTHLY_RAINFALL_TVS_CALL) \
		--unscaled \
		--tvsm intermediate/monthly-rainfall-tvsm.rds \
		--output $@

figures/monthly-rainfall-tvs-unscaled-all.png: intermediate/monthly-rainfall-tvsm.rds $(MONTHLY_RAINFALL_TVS_DEPS)
	$(MONTHLY_RAINFALL_TVS_CALL) \
		--all \
		--unscaled \
		--tvsm intermediate/monthly-rainfall-tvsm.rds \
		--output $@

figures/monthly-rainfall-mcmc-statistics-%.txt: $(MCMC_STATISTICS_SCRIPT) intermediate/monthly-rainfall-samples-%.rds $(MONTHLY_RAINFALL_METADATA) $(BASE_SCRIPT)
	$(RSCRIPT) $< \
		--samples intermediate/monthly-rainfall-samples-$*.rds \
		--metadata $(MONTHLY_RAINFALL_METADATA) \
		--output $@

figures/monthly-rainfall-tests.txt: scripts/monthly-rainfall-tests.R $(MONTHLY_RAINFALL_SAMPLES) $(MONTHLY_RAINFALL_OBSERVATIONS) $(MONTHLY_RAINFALL_METADATA) $(BASE_SCRIPT)
	$(RSCRIPT) $< \
		--samples $(MONTHLY_RAINFALL_SAMPLES) \
		--observations $(MONTHLY_RAINFALL_OBSERVATIONS) \
		--metadata $(MONTHLY_RAINFALL_METADATA) \
		--output $@

figures/monthly-rainfall-tests-table.tex: scripts/monthly-rainfall-tests-table.R $(MONTHLY_RAINFALL_SAMPLES) $(MONTHLY_RAINFALL_OBSERVATIONS) $(MONTHLY_RAINFALL_METADATA) $(BASE_SCRIPT)
	$(RSCRIPT) $< \
		--samples $(MONTHLY_RAINFALL_SAMPLES) \
		--observations $(MONTHLY_RAINFALL_OBSERVATIONS) \
		--metadata $(MONTHLY_RAINFALL_METADATA) \
		--output $@

intermediate/monthly-rainfall-tvmm.rds: scripts/monthly-rainfall-tvmm.R $(MONTHLY_RAINFALL_SAMPLES) $(MONTHLY_RAINFALL_OBSERVATIONS) $(MONTHLY_RAINFALL_METADATA) $(BASE_SCRIPT)
	$(RSCRIPT) $< \
		--samples $(MONTHLY_RAINFALL_SAMPLES) \
		--observations $(MONTHLY_RAINFALL_OBSERVATIONS) \
		--metadata $(MONTHLY_RAINFALL_METADATA) \
		--output $@

intermediate/monthly-rainfall-tvsm.rds: scripts/monthly-rainfall-tvsm.R $(MONTHLY_RAINFALL_SAMPLES) $(MONTHLY_RAINFALL_OBSERVATIONS) $(MONTHLY_RAINFALL_METADATA) $(BASE_SCRIPT)
	$(RSCRIPT) $< \
		--samples $(MONTHLY_RAINFALL_SAMPLES) \
		--observations $(MONTHLY_RAINFALL_OBSERVATIONS) \
		--metadata $(MONTHLY_RAINFALL_METADATA) \
		--output $@

intermediate/monthly-rainfall-samples-%.rds: scripts/monthly-rainfall-samples.R $(MONTHLY_RAINFALL_METADATA) $(MONTHLY_RAINFALL_OBSERVATIONS) $(BASE_SCRIPT)
	$(RSCRIPT) $< \
		--metadata $(MONTHLY_RAINFALL_METADATA) \
		--observations $(MONTHLY_RAINFALL_OBSERVATIONS) \
		--output $@

$(MONTHLY_RAINFALL_OBSERVATIONS): $(MONTHLY_RAINFALL_METADATA)
$(MONTHLY_RAINFALL_METADATA): scripts/monthly-rainfall-data.R $(BOM_HQ) $(BASE_SCRIPT)
	$(RSCRIPT) $<


## Measles

MEASLES_METADATA = intermediate/measles-metadata.rds
MEASLES_OBSERVATIONS = intermediate/measles-observations.rds
MEASLES_CSV = data/measles.csv.gz
STATE_CENTROIDS_CSV = data/state-centroids.csv

MEASLES_TS_DEPS = scripts/measles-ts.R $(MEASLES_METADATA) $(MEASLES_OBSERVATIONS) $(DISPLAY_SETTINGS_SCRIPT) $(BASE_SCRIPT)
MEASLES_TS_CALL = $(RSCRIPT) scripts/measles-ts.R \
	--observations $(MEASLES_OBSERVATIONS) \
	--metadata $(MEASLES_METADATA)

MEASLES_TVM_DEPS = scripts/measles-tvm.R $(BASE_SCRIPT) $(DISPLAY_SETTINGS_SCRIPT) $(MEASLES_OBSERVATIONS)
MEASLES_TVM_CALL = $(RSCRIPT) scripts/measles-tvm.R --observations $(MEASLES_OBSERVATIONS)
MEASLES_TVMM_DEPS = scripts/measles-tvmm.R $(MEASLES_METADATA) $(MEASLES_OBSERVATIONS) $(BASE_SCRIPT)
MEASLES_TVMM_CALL = $(RSCRIPT) scripts/measles-tvmm.R \
	--observations $(MEASLES_OBSERVATIONS) \
	--metadata $(MEASLES_METADATA)

MEASLES_TVS_DEPS = scripts/measles-tvs.R $(DISPLAY_SETTINGS_SCRIPT) $(BASE_SCRIPT)
MEASLES_TVS_CALL = $(RSCRIPT) scripts/measles-tvs.R
MEASLES_TVSM_DEPS = scripts/measles-tvsm.R $(MEASLES_METADATA) $(MEASLES_OBSERVATIONS) $(BASE_SCRIPT)
MEASLES_TVSM_CALL = $(RSCRIPT) scripts/measles-tvsm.R \
	--observations $(MEASLES_OBSERVATIONS) \
	--metadata $(MEASLES_METADATA)

MEASLES_SAMPLES = $(foreach CHAIN,$(CHAINS),intermediate/measles-samples-$(CHAIN).rds)

figures/measles-data-summary.txt: scripts/measles-data-summary.R $(MEASLES_METADATA) $(MEASLES_OBSERVATIONS) $(BASE_SCRIPT)
	$(RSCRIPT) $< \
		--metadata $(MEASLES_METADATA) \
		--observations $(MEASLES_OBSERVATIONS) \
		--output $@

figures/measles-ts.pdf: $(MEASLES_TS_DEPS)
	$(MEASLES_TS_CALL) \
		--output $@

figures/measles-ts-before.pdf: $(MEASLES_TS_DEPS)
	$(MEASLES_TS_CALL) \
		--period before \
		--output $@

figures/measles-ts-after.pdf: $(MEASLES_TS_DEPS)
	$(MEASLES_TS_CALL) \
		--period after \
		--output $@

figures/measles-diagnostics-%.png: scripts/measles-diagnostics.R intermediate/measles-samples-%.rds $(BASE_SCRIPT)
	$(RSCRIPT) $< \
		--samples intermediate/measles-samples-$*.rds \
		--output $@

figures/measles-tvm.pdf: intermediate/measles-tvmm.rds $(MEASLES_TVM_DEPS)
	$(MEASLES_TVM_CALL) \
		--tvmm intermediate/measles-tvmm.rds \
		--output $@

figures/measles-tvm-before.pdf: intermediate/measles-tvmm.rds $(MEASLES_TVM_DEPS)
	$(MEASLES_TVM_CALL) \
		--tvmm intermediate/measles-tvmm.rds \
		--period before \
		--output $@

figures/measles-tvm-after.pdf: intermediate/measles-tvmm.rds $(MEASLES_TVM_DEPS)
	$(MEASLES_TVM_CALL) \
		--tvmm intermediate/measles-tvmm.rds \
		--period after \
		--output $@

figures/measles-tvs.png: intermediate/measles-tvsm.rds $(MEASLES_TVS_DEPS)
	$(MEASLES_TVS_CALL) \
		--tvsm intermediate/measles-tvsm.rds \
		--output $@

figures/measles-tvs-before.png: intermediate/measles-tvsm.rds $(MEASLES_TVS_DEPS)
	$(MEASLES_TVS_CALL) \
		--tvsm intermediate/measles-tvsm.rds \
		--period before \
		--output $@

figures/measles-tvs-inter.png: intermediate/measles-tvsm.rds $(MEASLES_TVS_DEPS)
	$(MEASLES_TVS_CALL) \
		--tvsm intermediate/measles-tvsm.rds \
		--period inter \
		--output $@

figures/measles-tvs-after.png: intermediate/measles-tvsm.rds $(MEASLES_TVS_DEPS)
	$(MEASLES_TVS_CALL) \
		--tvsm intermediate/measles-tvsm.rds \
		--period after \
		--output $@

figures/measles-tvs-special.png: intermediate/measles-tvsm.rds $(MEASLES_TVS_DEPS)
	$(MEASLES_TVS_CALL) \
		--tvsm intermediate/measles-tvsm.rds \
		--states special \
		--output $@

figures/measles-tvs-special-before.png: intermediate/measles-tvsm.rds $(MEASLES_TVS_DEPS)
	$(MEASLES_TVS_CALL) \
		--tvsm intermediate/measles-tvsm.rds \
		--period before \
		--states special \
		--output $@

figures/measles-mcmc-statistics-%.txt: $(MCMC_STATISTICS_SCRIPT) intermediate/measles-samples-%.rds $(MEASLES_METADATA) $(BASE_SCRIPT)
	$(RSCRIPT) $< \
		--samples intermediate/measles-samples-$*.rds \
		--metadata $(MEASLES_METADATA) \
		--output $@

figures/measles-tests.txt: scripts/measles-tests.R $(MEASLES_SAMPLES) $(MEASLES_METADATA) $(MEASLES_OBSERVATIONS) $(BASE_SCRIPT)
	$(RSCRIPT) $< \
		--metadata $(MEASLES_METADATA) \
		--observations $(MEASLES_OBSERVATIONS) \
		--samples $(MEASLES_SAMPLES) \
		--output $@

intermediate/measles-tvmm.rds: $(MEASLES_SAMPLES) $(MEASLES_TVMM_DEPS)
	$(MEASLES_TVMM_CALL) \
		--samples $(MEASLES_SAMPLES) \
		--output $@

intermediate/measles-tvsm.rds: $(MEASLES_SAMPLES) $(MEASLES_TVSM_DEPS)
	$(MEASLES_TVSM_CALL) \
		--samples $(MEASLES_SAMPLES) \
		--output $@

intermediate/measles-samples-%.rds: scripts/measles-samples.R $(MEASLES_METADATA) $(MEASLES_OBSERVATIONS) $(BASE_SCRIPT)
	$(RSCRIPT) $< \
		--metadata $(MEASLES_METADATA) \
		--observations $(MEASLES_OBSERVATIONS) \
		--output $@

$(MEASLES_OBSERVATIONS): $(MEASLES_METADATA)
$(MEASLES_METADATA): scripts/measles-data.R $(MEASLES_CSV) $(STATE_CENTROIDS_CSV) $(BASE_SCRIPT)
	$(RSCRIPT) $< \
		--measles $(MEASLES_CSV) \
		--state-centroids $(STATE_CENTROIDS_CSV)


## Catch-all for intermediate files

# NOTE(mgnb): catches anything not above; can be used when no inputs requires
intermediate/%.rds: scripts/%.R $(BASE_SCRIPT)
	Rscript $< --output $@


# This prevents these intermediate files from being deleted because they have
# no formal corresponding target
.SECONDARY: $(MONTHLY_RAINFALL_SAMPLES) $(MEASLES_SAMPLES)

$(shell mkdir -p intermediate figures)
