MONTHLY_RAINFALL_CHAINS = 1 2 3 4

MONTHLY_RAINFALL_METADATA = intermediate/monthly-rainfall-metadata.rds
MONTHLY_RAINFALL_OBSERVATIONS = intermediate/monthly-rainfall-observations.rds
MONTHLY_RAINFALL_SAMPLES = $(foreach CHAIN,$(MONTHLY_RAINFALL_CHAINS),intermediate/monthly-rainfall-samples-$(CHAIN).rds)
MONTHLY_RAINFALL_TVMM = intermediate/monthly-rainfall-tvmm.rds
MONTHLY_RAINFALL_TVSM = intermediate/monthly-rainfall-tvsm.rds

MONTHLY_RAINFALL_TVS_DEPS = scripts/monthly-rainfall-tvs.R $(AUSTRALIA_MAP) \
	$(DISPLAY_SETTINGS_SCRIPT) \
	$(BASE_SCRIPT)
MONTHLY_RAINFALL_TVS_CALL = $(RSCRIPT) scripts/monthly-rainfall-tvs.R \
	--map $(AUSTRALIA_MAP)

MONTHLY_RAINFALL_FIGURES = figures/monthly-rainfall-map.pdf \
	figures/monthly-rainfall-ts.pdf \
	figures/monthly-rainfall-data-summary.txt \
	figures/monthly-rainfall-tvm.pdf \
	figures/monthly-rainfall-tvs.png \
	figures/monthly-rainfall-tvs-unscaled.png \
	figures/monthly-rainfall-tests-table.tex

FIGURES += $(MONTHLY_RAINFALL_FIGURES)
SECONDARY_TARGETS += $(MONTHLY_RAINFALL_METADATA) \
	$(MONTHLY_RAINFALL_OBSERVATIONS) \
	$(MONTHLY_RAINFALL_SAMPLES) \
	$(MONTHLY_RAINFALL_TVMM) \
	$(MONTHLY_RAINFALL_TVSM)

monthly_rainfall: $(MONTHLY_RAINFALL_FIGURES)

figures/monthly-rainfall-map.pdf: \
	scripts/monthly-rainfall-map.R \
	$(AUSTRALIA_MAP) \
	$(MONTHLY_RAINFALL_METADATA) \
	$(DISPLAY_SETTINGS_SCRIPT) \
	$(BASE_SCRIPT)
	$(RSCRIPT) $< \
		--map $(AUSTRALIA_MAP) \
		--metadata $(MONTHLY_RAINFALL_METADATA) \
		--output $@

figures/monthly-rainfall-ts.pdf: \
	scripts/monthly-rainfall-ts.R \
	$(AUSTRALIA_MAP) \
	$(MONTHLY_RAINFALL_METADATA) \
	$(MONTHLY_RAINFALL_OBSERVATIONS) \
	$(DISPLAY_SETTINGS_SCRIPT) \
	$(BASE_SCRIPT)
	$(RSCRIPT) $< \
		--map $(AUSTRALIA_MAP) \
		--metadata $(MONTHLY_RAINFALL_METADATA) \
		--observations $(MONTHLY_RAINFALL_OBSERVATIONS) \
		--output $@

figures/monthly-rainfall-data-summary.txt: \
	scripts/monthly-rainfall-data-summary.R \
	$(MONTHLY_RAINFALL_METADATA) \
	$(MONTHLY_RAINFALL_OBSERVATIONS) \
	$(BASE_SCRIPT)
	$(RSCRIPT) $< \
		--metadata $(MONTHLY_RAINFALL_METADATA) \
		--observations $(MONTHLY_RAINFALL_OBSERVATIONS) \
		--output $@

figures/monthly-rainfall-tvm.pdf: \
	scripts/monthly-rainfall-tvm.R \
	$(MONTHLY_RAINFALL_TVMM) \
	$(MONTHLY_RAINFALL_OBSERVATIONS) \
	$(AUSTRALIA_MAP) \
	$(DISPLAY_SETTINGS_SCRIPT) \
	$(BASE_SCRIPT)
	$(RSCRIPT) $< \
		--observations $(MONTHLY_RAINFALL_OBSERVATIONS) \
		--map $(AUSTRALIA_MAP) \
		--tvmm $(MONTHLY_RAINFALL_TVMM) \
		--output $@

figures/monthly-rainfall-tvs.png: \
	$(MONTHLY_RAINFALL_TVSM) \
	$(MONTHLY_RAINFALL_TVS_DEPS)
	$(MONTHLY_RAINFALL_TVS_CALL) \
		--tvsm $(MONTHLY_RAINFALL_TVSM) \
		--output $@

figures/monthly-rainfall-tvs-unscaled.png: \
	$(MONTHLY_RAINFALL_TVSM) \
	$(MONTHLY_RAINFALL_TVS_DEPS)
	$(MONTHLY_RAINFALL_TVS_CALL) \
		--unscaled \
		--tvsm $(MONTHLY_RAINFALL_TVSM) \
		--output $@

figures/monthly-rainfall-tests-table.tex: \
	scripts/monthly-rainfall-tests-table.R \
	$(MONTHLY_RAINFALL_SAMPLES) \
	$(MONTHLY_RAINFALL_OBSERVATIONS) \
	$(MONTHLY_RAINFALL_METADATA) $(BASE_SCRIPT)
	$(RSCRIPT) $< \
		--samples $(MONTHLY_RAINFALL_SAMPLES) \
		--observations $(MONTHLY_RAINFALL_OBSERVATIONS) \
		--metadata $(MONTHLY_RAINFALL_METADATA) \
		--output $@

$(MONTHLY_RAINFALL_TVMM): \
	scripts/monthly-rainfall-tvmm.R \
	$(MONTHLY_RAINFALL_SAMPLES) \
	$(MONTHLY_RAINFALL_OBSERVATIONS) \
	$(MONTHLY_RAINFALL_METADATA) \
	$(BASE_SCRIPT)
	$(RSCRIPT) $< \
		--samples $(MONTHLY_RAINFALL_SAMPLES) \
		--observations $(MONTHLY_RAINFALL_OBSERVATIONS) \
		--metadata $(MONTHLY_RAINFALL_METADATA) \
		--output $@

$(MONTHLY_RAINFALL_TVSM): \
	scripts/monthly-rainfall-tvsm.R \
	$(MONTHLY_RAINFALL_SAMPLES) \
	$(MONTHLY_RAINFALL_OBSERVATIONS) \
	$(MONTHLY_RAINFALL_METADATA) $(BASE_SCRIPT)
	$(RSCRIPT) $< \
		--samples $(MONTHLY_RAINFALL_SAMPLES) \
		--observations $(MONTHLY_RAINFALL_OBSERVATIONS) \
		--metadata $(MONTHLY_RAINFALL_METADATA) \
		--output $@

intermediate/monthly-rainfall-samples-%.rds: \
	scripts/monthly-rainfall-samples.R \
	$(MONTHLY_RAINFALL_METADATA) \
	$(MONTHLY_RAINFALL_OBSERVATIONS) \
	$(BASE_SCRIPT)
	$(RSCRIPT) $< \
		--metadata $(MONTHLY_RAINFALL_METADATA) \
		--observations $(MONTHLY_RAINFALL_OBSERVATIONS) \
		--output $@

$(MONTHLY_RAINFALL_OBSERVATIONS): $(MONTHLY_RAINFALL_METADATA)
$(MONTHLY_RAINFALL_METADATA): \
	scripts/monthly-rainfall-data.R $(BOM_HQ) $(BASE_SCRIPT)
	$(RSCRIPT) $<
