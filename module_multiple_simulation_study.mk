MULTIPLE_SIMULATION_STUDY_REPLICATE_NUMBERS = \
	1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 \
	29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 \
	54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 \
	79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100

MULTIPLE_SIMULATION_STUDY_REPLICATES = intermediate/multiple-simulation-study-replicates.rds
MULTIPLE_SIMULATION_STUDY_METADATA = intermediate/multiple-simulation-study-metadata.rds
MULTIPLE_SIMULATION_STUDY_TVMM = intermediate/multiple-simulation-study-tvmm.rds
MULTIPLE_SIMULATION_STUDY_TVSM = intermediate/multiple-simulation-study-tvsm.rds
MULTIPLE_SIMULATION_STUDY_MSE = intermediate/multiple-simulation-study-mse.rds
MULTIPLE_SIMULATION_STUDY_SAMPLES_DIRECTORY = intermediate/multiple-simulation-study-samples
MULTIPLE_SIMULATION_STUDY_SAMPLES_BASE = $(MULTIPLE_SIMULATION_STUDY_SAMPLES_DIRECTORY)/samples
MULTIPLE_SIMULATION_STUDY_SAMPLES = $(foreach REPLICATE,$(MULTIPLE_SIMULATION_STUDY_REPLICATE_NUMBERS),$(MULTIPLE_SIMULATION_STUDY_SAMPLES_BASE)-$(REPLICATE).rds)

MULTIPLE_SIMULATION_STUDY_SINGLE_SAMPLES_DIRECTORY = intermediate/multiple-simulation-study-single-samples
MULTIPLE_SIMULATION_STUDY_SINGLE_SAMPLES_BASE = $(MULTIPLE_SIMULATION_STUDY_SINGLE_SAMPLES_DIRECTORY)/samples
MULTIPLE_SIMULATION_STUDY_SINGLE_SAMPLES = $(foreach REPLICATE,$(MULTIPLE_SIMULATION_STUDY_REPLICATE_NUMBERS),$(MULTIPLE_SIMULATION_STUDY_SINGLE_SAMPLES_BASE)-$(REPLICATE).rds)
MULTIPLE_SIMULATION_STUDY_SINGLE_TVMM = intermediate/multiple-simulation-study-single-tvmm.rds
MULTIPLE_SIMULATION_STUDY_SINGLE_TVSM = intermediate/multiple-simulation-study-single-tvsm.rds
MULTIPLE_SIMULATION_STUDY_SINGLE_MSE = intermediate/multiple-simulation-study-single-mse.rds

$(shell mkdir -p \
		$(MULTIPLE_SIMULATION_STUDY_SAMPLES_DIRECTORY) \
		$(MULTIPLE_SIMULATION_STUDY_SINGLE_SAMPLES_DIRECTORY))

MULTIPLE_SIMULATION_STUDY_FIGURES = figures/multiple-simulation-study-true-categories.pdf \
	figures/multiple-simulation-study-ts.pdf \
	figures/multiple-simulation-study-mse-boxplot.pdf \
	figures/multiple-simulation-study-mse-summary.txt \
	figures/multiple-simulation-study-single-mse-summary.txt \
	figures/multiple-simulation-study-tvm.pdf \
	figures/multiple-simulation-study-tvs.png

FIGURES += $(MULTIPLE_SIMULATION_STUDY_FIGURES)
SECONDARY_TARGETS += $(MULTIPLE_SIMULATION_STUDY_REPLICATES) \
	$(MULTIPLE_SIMULATION_STUDY_METADATA) \
	$(MULTIPLE_SIMULATION_STUDY_TVMM) \
	$(MULTIPLE_SIMULATION_STUDY_TVSM) \
	$(MULTIPLE_SIMULATION_STUDY_MSE) \
	$(MULTIPLE_SIMULATION_STUDY_SAMPLES) \
	$(MULTIPLE_SIMULATION_STUDY_SINGLE_SAMPLES) \
	$(MULTIPLE_SIMULATION_STUDY_SINGLE_TVMM) \
	$(MULTIPLE_SIMULATION_STUDY_SINGLE_TVSM) \
	$(MULTIPLE_SIMULATION_STUDY_SINGLE_MSE)

multiple_simulation_study: $(MULTIPLE_SIMULATION_STUDY_FIGURES)

figures/multiple-simulation-study-true-categories.pdf: \
	scripts/multiple-simulation-study-true-categories.R \
	$(MULTIPLE_SIMULATION_STUDY_METADATA) \
	$(DISPLAY_SETTINGS_SCRIPT) \
	$(BASE_SCRIPT)
	$(RSCRIPT) $< \
		--metadata $(MULTIPLE_SIMULATION_STUDY_METADATA) \
		--output $@

figures/multiple-simulation-study-ts.pdf: \
	scripts/multiple-simulation-study-ts.R \
	$(MULTIPLE_SIMULATION_STUDY_REPLICATES) \
	$(MULTIPLE_SIMULATION_STUDY_METADATA) \
	$(DISPLAY_SETTINGS_SCRIPT) \
	$(BASE_SCRIPT)
	$(RSCRIPT) $< \
		--metadata $(MULTIPLE_SIMULATION_STUDY_METADATA) \
		--replicates $(MULTIPLE_SIMULATION_STUDY_REPLICATES) \
		--output $@

figures/multiple-simulation-study-mse-boxplot.pdf: \
	scripts/multiple-simulation-study-mse-boxplot.R \
	$(MULTIPLE_SIMULATION_STUDY_MSE) \
	$(MULTIPLE_SIMULATION_STUDY_SINGLE_MSE) \
	$(DISPLAY_SETTINGS_SCRIPT) \
	$(BASE_SCRIPT)
	$(RSCRIPT) $< \
		--mse $(MULTIPLE_SIMULATION_STUDY_MSE) \
		--mse-single $(MULTIPLE_SIMULATION_STUDY_SINGLE_MSE) \
		--output $@

figures/multiple-simulation-study-mse-summary.txt: \
	scripts/multiple-simulation-study-mse-summary.R \
	$(MULTIPLE_SIMULATION_STUDY_MSE) \
	$(BASE_SCRIPT)
	$(RSCRIPT) $< \
		--mse $(MULTIPLE_SIMULATION_STUDY_MSE) \
		--output $@

figures/multiple-simulation-study-single-mse-summary.txt: \
	scripts/multiple-simulation-study-mse-summary.R \
	$(MULTIPLE_SIMULATION_STUDY_SINGLE_MSE) \
	$(BASE_SCRIPT)
	$(RSCRIPT) $< \
		--mse $(MULTIPLE_SIMULATION_STUDY_SINGLE_MSE) \
		--output $@

figures/multiple-simulation-study-tvm.pdf: \
	scripts/multiple-simulation-study-tvm.R \
	$(MULTIPLE_SIMULATION_STUDY_TVMM) \
	$(MULTIPLE_SIMULATION_STUDY_MSE) \
	$(DISPLAY_SETTINGS_SCRIPT) \
	$(BASE_SCRIPT)
	$(RSCRIPT) $< \
		--mse $(MULTIPLE_SIMULATION_STUDY_MSE) \
		--tvm $(MULTIPLE_SIMULATION_STUDY_TVMM) \
		--output $@

figures/multiple-simulation-study-tvs.png: \
	scripts/multiple-simulation-study-tvs.R \
	$(MULTIPLE_SIMULATION_STUDY_TVSM) \
	$(MULTIPLE_SIMULATION_STUDY_MSE) \
	$(DISPLAY_SETTINGS_SCRIPT) \
	$(BASE_SCRIPT)
	$(RSCRIPT) $< \
		--mse $(MULTIPLE_SIMULATION_STUDY_MSE) \
		--tvs $(MULTIPLE_SIMULATION_STUDY_TVSM) \
		--output $@

$(MULTIPLE_SIMULATION_STUDY_SINGLE_MSE): \
	scripts/multiple-simulation-study-mse.R \
	$(MULTIPLE_SIMULATION_STUDY_METADATA) \
	$(MULTIPLE_SIMULATION_STUDY_SINGLE_TVMM) \
	$(MULTIPLE_SIMULATION_STUDY_SINGLE_TVSM)
	$(RSCRIPT) $< \
		--metadata $(MULTIPLE_SIMULATION_STUDY_METADATA) \
		--tvm $(MULTIPLE_SIMULATION_STUDY_SINGLE_TVMM) \
		--tvs $(MULTIPLE_SIMULATION_STUDY_SINGLE_TVSM) \
		--output $@

$(MULTIPLE_SIMULATION_STUDY_SINGLE_TVSM): \
	scripts/multiple-simulation-study-single-tvsm.R \
	$(MULTIPLE_SIMULATION_STUDY_SINGLE_SAMPLES) \
	$(MULTIPLE_SIMULATION_STUDY_METADATA) \
	$(BASE_SCRIPT)
	$(RSCRIPT) $< \
		--metadata $(MULTIPLE_SIMULATION_STUDY_METADATA) \
		--samples-directory $(MULTIPLE_SIMULATION_STUDY_SINGLE_SAMPLES_DIRECTORY) \
		--output $@

$(MULTIPLE_SIMULATION_STUDY_SINGLE_TVMM): \
	scripts/multiple-simulation-study-single-tvmm.R \
	$(MULTIPLE_SIMULATION_STUDY_SINGLE_SAMPLES) \
	$(MULTIPLE_SIMULATION_STUDY_METADATA) \
	$(BASE_SCRIPT)
	$(RSCRIPT) $< \
		--metadata $(MULTIPLE_SIMULATION_STUDY_METADATA) \
		--samples-directory $(MULTIPLE_SIMULATION_STUDY_SINGLE_SAMPLES_DIRECTORY) \
		--output $@

$(MULTIPLE_SIMULATION_STUDY_MSE): \
	scripts/multiple-simulation-study-mse.R \
	$(MULTIPLE_SIMULATION_STUDY_METADATA) \
	$(MULTIPLE_SIMULATION_STUDY_TVMM) \
	$(MULTIPLE_SIMULATION_STUDY_TVSM)
	$(RSCRIPT) $< \
		--metadata $(MULTIPLE_SIMULATION_STUDY_METADATA) \
		--tvm $(MULTIPLE_SIMULATION_STUDY_TVMM) \
		--tvs $(MULTIPLE_SIMULATION_STUDY_TVSM) \
		--output $@

$(MULTIPLE_SIMULATION_STUDY_TVSM): \
	scripts/multiple-simulation-study-tvsm.R \
	$(MULTIPLE_SIMULATION_STUDY_SAMPLES) \
	$(MULTIPLE_SIMULATION_STUDY_METADATA) \
	$(BASE_SCRIPT)
	$(RSCRIPT) $< \
		--metadata $(MULTIPLE_SIMULATION_STUDY_METADATA) \
		--samples-directory $(MULTIPLE_SIMULATION_STUDY_SAMPLES_DIRECTORY) \
		--output $@

$(MULTIPLE_SIMULATION_STUDY_TVMM): \
	scripts/multiple-simulation-study-tvmm.R \
	$(MULTIPLE_SIMULATION_STUDY_SAMPLES) \
	$(MULTIPLE_SIMULATION_STUDY_METADATA) \
	$(BASE_SCRIPT)
	$(RSCRIPT) $< \
		--metadata $(MULTIPLE_SIMULATION_STUDY_METADATA) \
		--samples-directory $(MULTIPLE_SIMULATION_STUDY_SAMPLES_DIRECTORY) \
		--output $@

$(MULTIPLE_SIMULATION_STUDY_SINGLE_SAMPLES_BASE)-%.rds: \
	scripts/multiple-simulation-study-single-samples.R \
	$(MULTIPLE_SIMULATION_STUDY_REPLICATES) \
	$(MULTIPLE_SIMULATION_STUDY_METADATA) \
	$(BASE_SCRIPT)
	$(RSCRIPT) $< \
		--metadata $(MULTIPLE_SIMULATION_STUDY_METADATA) \
		--replicates $(MULTIPLE_SIMULATION_STUDY_REPLICATES) \
		--replicate-number $* \
		--output $@

$(MULTIPLE_SIMULATION_STUDY_SAMPLES_BASE)-%.rds: \
	scripts/multiple-simulation-study-samples.R \
	$(MULTIPLE_SIMULATION_STUDY_REPLICATES) \
	$(MULTIPLE_SIMULATION_STUDY_METADATA) \
	$(BASE_SCRIPT)
	$(RSCRIPT) $< \
		--replicates $(MULTIPLE_SIMULATION_STUDY_REPLICATES) \
		--metadata $(MULTIPLE_SIMULATION_STUDY_METADATA) \
		--replicate-number $* \
		--output $@

$(MULTIPLE_SIMULATION_STUDY_REPLICATES): \
	scripts/multiple-simulation-study-replicates.R \
	$(MULTIPLE_SIMULATION_STUDY_METADATA) \
	$(BASE_SCRIPT)
	$(RSCRIPT) $< \
		--metadata $(MULTIPLE_SIMULATION_STUDY_METADATA) \
		--output $@

$(MULTIPLE_SIMULATION_STUDY_METADATA): \
	scripts/multiple-simulation-study-metadata.R $(BASE_SCRIPT)
	$(RSCRIPT) $< \
		--output $@
