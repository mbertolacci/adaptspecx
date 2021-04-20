MEASLES_CHAINS = 1 2 3 4

MEASLES_CSV = data/measles.csv
STATE_CENTROIDS_CSV = data/state-centroids.csv

MEASLES_METADATA = intermediate/measles-metadata.rds
MEASLES_OBSERVATIONS = intermediate/measles-observations.rds
MEASLES_SAMPLES = $(foreach CHAIN,$(MEASLES_CHAINS),intermediate/measles-samples-$(CHAIN).rds)
MEASLES_TVMM = intermediate/measles-tvmm.rds
MEASLES_TVSM = intermediate/measles-tvsm.rds

MEASLES_TVS_DEPS = scripts/measles-tvs.R \
	$(DISPLAY_SETTINGS_SCRIPT) \
	$(BASE_SCRIPT)
MEASLES_TVS_CALL = $(RSCRIPT) scripts/measles-tvs.R

MEASLES_FIGURES = figures/measles-data-summary.txt \
	figures/measles-ts.pdf \
	figures/measles-tvm.pdf \
	figures/measles-tvs.png \
	figures/measles-tvs-before.png \
	figures/measles-tvs-special.png \
	figures/measles-tvs-special-before.png \
	figures/measles-tests.txt

FIGURES += $(MEASLES_FIGURES)
SECONDARY_TARGETS += $(MEASLES_METADATA) \
	$(MEASLES_OBSERVATIONS) \
	$(MEASLES_SAMPLES) \
	$(MEASLES_TVMM) \
	$(MEASLES_TVSM)

measles: $(MEASLES_FIGURES)

figures/measles-data-summary.txt: \
	scripts/measles-data-summary.R \
	$(MEASLES_METADATA) \
	$(MEASLES_OBSERVATIONS) \
	$(BASE_SCRIPT)
	$(RSCRIPT) $< \
		--metadata $(MEASLES_METADATA) \
		--observations $(MEASLES_OBSERVATIONS) \
		--output $@

figures/measles-ts.pdf: \
	scripts/measles-ts.R \
	$(MEASLES_METADATA) \
	$(MEASLES_OBSERVATIONS) \
	$(DISPLAY_SETTINGS_SCRIPT) \
	$(BASE_SCRIPT)
	$(RSCRIPT) $< \
		--observations $(MEASLES_OBSERVATIONS) \
		--metadata $(MEASLES_METADATA) \
		--output $@

figures/measles-tvm.pdf: \
	scripts/measles-tvm.R \
	$(MEASLES_TVMM) \
	$(MEASLES_OBSERVATIONS) \
	$(BASE_SCRIPT) \
	$(DISPLAY_SETTINGS_SCRIPT)
	$(RSCRIPT) $< \
		--observations $(MEASLES_OBSERVATIONS) \
		--tvmm $(MEASLES_TVMM) \
		--output $@

figures/measles-tvs.png: \
	$(MEASLES_TVSM) \
	$(MEASLES_TVS_DEPS)
	$(MEASLES_TVS_CALL) \
		--tvsm $(MEASLES_TVSM) \
		--output $@

figures/measles-tvs-before.png: \
	$(MEASLES_TVSM) \
	$(MEASLES_TVS_DEPS)
	$(MEASLES_TVS_CALL) \
		--tvsm $(MEASLES_TVSM) \
		--period before \
		--output $@

figures/measles-tvs-special.png: \
	$(MEASLES_TVSM) \
	$(MEASLES_TVS_DEPS)
	$(MEASLES_TVS_CALL) \
		--tvsm $(MEASLES_TVSM) \
		--states special \
		--output $@

figures/measles-tvs-special-before.png: \
	$(MEASLES_TVSM) \
	$(MEASLES_TVS_DEPS)
	$(MEASLES_TVS_CALL) \
		--tvsm $(MEASLES_TVSM) \
		--period before \
		--states special \
		--output $@

figures/measles-tests.txt: \
	scripts/measles-tests.R \
	$(MEASLES_SAMPLES) \
	$(MEASLES_METADATA) \
	$(MEASLES_OBSERVATIONS) \
	$(BASE_SCRIPT)
	$(RSCRIPT) $< \
		--metadata $(MEASLES_METADATA) \
		--observations $(MEASLES_OBSERVATIONS) \
		--samples $(MEASLES_SAMPLES) \
		--output $@

$(MEASLES_TVMM): \
	scripts/measles-tvmm.R \
	$(MEASLES_METADATA) \
	$(MEASLES_OBSERVATIONS) \
	$(MEASLES_SAMPLES) \
	$(BASE_SCRIPT)
	$(RSCRIPT) $< \
		--observations $(MEASLES_OBSERVATIONS) \
		--metadata $(MEASLES_METADATA) \
		--samples $(MEASLES_SAMPLES) \
		--output $@

$(MEASLES_TVSM): \
	scripts/measles-tvsm.R \
	$(MEASLES_METADATA) \
	$(MEASLES_OBSERVATIONS) \
	$(BASE_SCRIPT) \
	$(MEASLES_SAMPLES)
	$(RSCRIPT) $< \
		--observations $(MEASLES_OBSERVATIONS) \
		--metadata $(MEASLES_METADATA) \
		--samples $(MEASLES_SAMPLES) \
		--output $@

intermediate/measles-samples-%.rds: \
	scripts/measles-samples.R \
	$(MEASLES_METADATA) \
	$(MEASLES_OBSERVATIONS) \
	$(BASE_SCRIPT)
	$(RSCRIPT) $< \
		--metadata $(MEASLES_METADATA) \
		--observations $(MEASLES_OBSERVATIONS) \
		--output $@

$(MEASLES_OBSERVATIONS): \
	$(MEASLES_METADATA)

$(MEASLES_METADATA): \
	scripts/measles-data.R \
	$(MEASLES_CSV) \
	$(STATE_CENTROIDS_CSV) \
	$(BASE_SCRIPT)
	$(RSCRIPT) $< \
		--measles $(MEASLES_CSV) \
		--state-centroids $(STATE_CENTROIDS_CSV)
