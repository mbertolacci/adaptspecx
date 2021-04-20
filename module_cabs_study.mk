CABS_STUDY_CONFIGURATION_NUMBERS = 1 2 3 4 5 6 7 8 9
CABS_STUDY_REPLICATE_NUMBERS = \
	1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 \
	29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 \
	54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 \
	79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100

CABS_STUDY_SETTINGS_SCRIPT = scripts/partials/cabs-study.R

CABS_STUDY_ABRUPT_SAMPLES_DIRECTORY = intermediate/cabs-study-abrupt-samples
CABS_STUDY_SLOW_SAMPLES_DIRECTORY = intermediate/cabs-study-slow-samples

CABS_STUDY_ABRUPT_CONFIGURATIONS = intermediate/cabs-study-abrupt-configurations.rds
CABS_STUDY_ABRUPT_SAMPLES_BASE = $(CABS_STUDY_ABRUPT_SAMPLES_DIRECTORY)/samples
CABS_STUDY_ABRUPT_SAMPLES = \
	$(foreach REPLICATE,$(CABS_STUDY_REPLICATE_NUMBERS),$(CABS_STUDY_ABRUPT_SAMPLES_BASE)-1-$(REPLICATE).rds) \
	$(foreach REPLICATE,$(CABS_STUDY_REPLICATE_NUMBERS),$(CABS_STUDY_ABRUPT_SAMPLES_BASE)-2-$(REPLICATE).rds) \
	$(foreach REPLICATE,$(CABS_STUDY_REPLICATE_NUMBERS),$(CABS_STUDY_ABRUPT_SAMPLES_BASE)-3-$(REPLICATE).rds) \
	$(foreach REPLICATE,$(CABS_STUDY_REPLICATE_NUMBERS),$(CABS_STUDY_ABRUPT_SAMPLES_BASE)-4-$(REPLICATE).rds) \
	$(foreach REPLICATE,$(CABS_STUDY_REPLICATE_NUMBERS),$(CABS_STUDY_ABRUPT_SAMPLES_BASE)-5-$(REPLICATE).rds) \
	$(foreach REPLICATE,$(CABS_STUDY_REPLICATE_NUMBERS),$(CABS_STUDY_ABRUPT_SAMPLES_BASE)-6-$(REPLICATE).rds) \
	$(foreach REPLICATE,$(CABS_STUDY_REPLICATE_NUMBERS),$(CABS_STUDY_ABRUPT_SAMPLES_BASE)-7-$(REPLICATE).rds) \
	$(foreach REPLICATE,$(CABS_STUDY_REPLICATE_NUMBERS),$(CABS_STUDY_ABRUPT_SAMPLES_BASE)-8-$(REPLICATE).rds) \
	$(foreach REPLICATE,$(CABS_STUDY_REPLICATE_NUMBERS),$(CABS_STUDY_ABRUPT_SAMPLES_BASE)-9-$(REPLICATE).rds)
CABS_STUDY_ABRUPT_TVSM_BASE = intermediate/cabs-study-abrupt-tvsm
CABS_STUDY_ABRUPT_TVSM = $(foreach CONFIGURATION,$(CABS_STUDY_CONFIGURATION_NUMBERS),$(CABS_STUDY_ABRUPT_TVSM_BASE)-$(CONFIGURATION).rds)
CABS_STUDY_ABRUPT_TVS_MSE = intermediate/cabs-study-abrupt-tvs-mse.rds

CABS_STUDY_SLOW_CONFIGURATIONS = intermediate/cabs-study-slow-configurations.rds
CABS_STUDY_SLOW_SAMPLES_BASE = $(CABS_STUDY_SLOW_SAMPLES_DIRECTORY)/samples
CABS_STUDY_SLOW_SAMPLES = \
	$(foreach REPLICATE,$(CABS_STUDY_REPLICATE_NUMBERS),$(CABS_STUDY_SLOW_SAMPLES_BASE)-1-$(REPLICATE).rds) \
	$(foreach REPLICATE,$(CABS_STUDY_REPLICATE_NUMBERS),$(CABS_STUDY_SLOW_SAMPLES_BASE)-2-$(REPLICATE).rds) \
	$(foreach REPLICATE,$(CABS_STUDY_REPLICATE_NUMBERS),$(CABS_STUDY_SLOW_SAMPLES_BASE)-3-$(REPLICATE).rds) \
	$(foreach REPLICATE,$(CABS_STUDY_REPLICATE_NUMBERS),$(CABS_STUDY_SLOW_SAMPLES_BASE)-4-$(REPLICATE).rds) \
	$(foreach REPLICATE,$(CABS_STUDY_REPLICATE_NUMBERS),$(CABS_STUDY_SLOW_SAMPLES_BASE)-5-$(REPLICATE).rds) \
	$(foreach REPLICATE,$(CABS_STUDY_REPLICATE_NUMBERS),$(CABS_STUDY_SLOW_SAMPLES_BASE)-6-$(REPLICATE).rds) \
	$(foreach REPLICATE,$(CABS_STUDY_REPLICATE_NUMBERS),$(CABS_STUDY_SLOW_SAMPLES_BASE)-7-$(REPLICATE).rds) \
	$(foreach REPLICATE,$(CABS_STUDY_REPLICATE_NUMBERS),$(CABS_STUDY_SLOW_SAMPLES_BASE)-8-$(REPLICATE).rds) \
	$(foreach REPLICATE,$(CABS_STUDY_REPLICATE_NUMBERS),$(CABS_STUDY_SLOW_SAMPLES_BASE)-9-$(REPLICATE).rds)
CABS_STUDY_SLOW_TVSM_BASE = intermediate/cabs-study-slow-tvsm
CABS_STUDY_SLOW_TVSM = $(foreach CONFIGURATION,$(CABS_STUDY_CONFIGURATION_NUMBERS),$(CABS_STUDY_SLOW_TVSM_BASE)-$(CONFIGURATION).rds)
CABS_STUDY_SLOW_TVS_MSE = intermediate/cabs-study-slow-tvs-mse.rds

$(shell mkdir -p \
		$(CABS_STUDY_ABRUPT_SAMPLES_DIRECTORY) \
		$(CABS_STUDY_SLOW_SAMPLES_DIRECTORY))

CABS_STUDY_FIGURES = figures/cabs-study-table.tex
FIGURES += $(CABS_STUDY_FIGURES)
SECONDARY_TARGETS += $(CABS_STUDY_ABRUPT_CONFIGURATIONS) \
	$(CABS_STUDY_ABRUPT_SAMPLES) \
	$(CABS_STUDY_ABRUPT_TVSM) \
	$(CABS_STUDY_ABRUPT_TVS_MSE) \
	$(CABS_STUDY_SLOW_CONFIGURATIONS) \
	$(CABS_STUDY_SLOW_SAMPLES) \
	$(CABS_STUDY_SLOW_TVSM) \
	$(CABS_STUDY_SLOW_TVS_MSE)

cabs_study: $(CABS_STUDY_FIGURES)

## Figures

figures/cabs-study-table.tex: \
	scripts/cabs-study-table.R \
	$(CABS_STUDY_ABRUPT_TVS_MSE) \
	$(CABS_STUDY_SLOW_TVS_MSE)
	Rscript $< \
		--tvs-mse-abrupt $(CABS_STUDY_ABRUPT_TVS_MSE) \
		--tvs-mse-slow $(CABS_STUDY_SLOW_TVS_MSE) \
		--output $@

## Abrupt

$(CABS_STUDY_ABRUPT_TVS_MSE): \
	scripts/cabs-study-tvs-mse.R \
	$(CABS_STUDY_ABRUPT_TVSM) \
	$(CABS_STUDY_ABRUPT_CONFIGURATIONS) \
	$(CABS_STUDY_SETTINGS_SCRIPT) \
	$(BASE_SCRIPT)
	$(RSCRIPT) $< \
		--tvsm-base $(CABS_STUDY_ABRUPT_TVSM_BASE) \
		--configurations $(CABS_STUDY_ABRUPT_CONFIGURATIONS) \
		--output $@

$(CABS_STUDY_ABRUPT_TVSM_BASE)-%.rds: \
	scripts/cabs-study-abrupt-tvsm.R \
	$(CABS_STUDY_ABRUPT_SAMPLES) \
	$(CABS_STUDY_ABRUPT_CONFIGURATIONS) \
	$(CABS_STUDY_SETTINGS_SCRIPT) \
	$(BASE_SCRIPT)
	$(RSCRIPT) $< \
		--samples-directory $(CABS_STUDY_ABRUPT_SAMPLES_DIRECTORY) \
		--configurations $(CABS_STUDY_ABRUPT_CONFIGURATIONS) \
		--configuration-number $* \
		--output $@

$(CABS_STUDY_ABRUPT_SAMPLES_BASE)-1-%.rds: \
	scripts/cabs-study-sample.R \
	$(CABS_STUDY_ABRUPT_CONFIGURATIONS) \
	$(CABS_STUDY_SETTINGS_SCRIPT) \
	$(BASE_SCRIPT)
	$(RSCRIPT) $< \
		--configurations $(CABS_STUDY_ABRUPT_CONFIGURATIONS) \
		--configuration-number 1 \
		--replicate-number $* \
		--output $@

$(CABS_STUDY_ABRUPT_SAMPLES_BASE)-2-%.rds: \
	scripts/cabs-study-sample.R \
	$(CABS_STUDY_ABRUPT_CONFIGURATIONS) \
	$(CABS_STUDY_SETTINGS_SCRIPT) \
	$(BASE_SCRIPT)
	$(RSCRIPT) $< \
		--configurations $(CABS_STUDY_ABRUPT_CONFIGURATIONS) \
		--configuration-number 2 \
		--replicate-number $* \
		--output $@

$(CABS_STUDY_ABRUPT_SAMPLES_BASE)-3-%.rds: \
	scripts/cabs-study-sample.R \
	$(CABS_STUDY_ABRUPT_CONFIGURATIONS) \
	$(CABS_STUDY_SETTINGS_SCRIPT) \
	$(BASE_SCRIPT)
	$(RSCRIPT) $< \
		--configurations $(CABS_STUDY_ABRUPT_CONFIGURATIONS) \
		--configuration-number 3 \
		--replicate-number $* \
		--output $@

$(CABS_STUDY_ABRUPT_SAMPLES_BASE)-4-%.rds: \
	scripts/cabs-study-sample.R \
	$(CABS_STUDY_ABRUPT_CONFIGURATIONS) \
	$(CABS_STUDY_SETTINGS_SCRIPT) \
	$(BASE_SCRIPT)
	$(RSCRIPT) $< \
		--configurations $(CABS_STUDY_ABRUPT_CONFIGURATIONS) \
		--configuration-number 4 \
		--replicate-number $* \
		--output $@

$(CABS_STUDY_ABRUPT_SAMPLES_BASE)-5-%.rds: \
	scripts/cabs-study-sample.R \
	$(CABS_STUDY_ABRUPT_CONFIGURATIONS) \
	$(CABS_STUDY_SETTINGS_SCRIPT) \
	$(BASE_SCRIPT)
	$(RSCRIPT) $< \
		--configurations $(CABS_STUDY_ABRUPT_CONFIGURATIONS) \
		--configuration-number 5 \
		--replicate-number $* \
		--output $@

$(CABS_STUDY_ABRUPT_SAMPLES_BASE)-6-%.rds: \
	scripts/cabs-study-sample.R \
	$(CABS_STUDY_ABRUPT_CONFIGURATIONS) \
	$(CABS_STUDY_SETTINGS_SCRIPT) \
	$(BASE_SCRIPT)
	$(RSCRIPT) $< \
		--configurations $(CABS_STUDY_ABRUPT_CONFIGURATIONS) \
		--configuration-number 6 \
		--replicate-number $* \
		--output $@

$(CABS_STUDY_ABRUPT_SAMPLES_BASE)-7-%.rds: \
	scripts/cabs-study-sample.R \
	$(CABS_STUDY_ABRUPT_CONFIGURATIONS) \
	$(CABS_STUDY_SETTINGS_SCRIPT) \
	$(BASE_SCRIPT)
	$(RSCRIPT) $< \
		--configurations $(CABS_STUDY_ABRUPT_CONFIGURATIONS) \
		--configuration-number 7 \
		--replicate-number $* \
		--output $@

$(CABS_STUDY_ABRUPT_SAMPLES_BASE)-8-%.rds: \
	scripts/cabs-study-sample.R \
	$(CABS_STUDY_ABRUPT_CONFIGURATIONS) \
	$(CABS_STUDY_SETTINGS_SCRIPT) \
	$(BASE_SCRIPT)
	$(RSCRIPT) $< \
		--configurations $(CABS_STUDY_ABRUPT_CONFIGURATIONS) \
		--configuration-number 8 \
		--replicate-number $* \
		--output $@

$(CABS_STUDY_ABRUPT_SAMPLES_BASE)-9-%.rds: \
	scripts/cabs-study-sample.R \
	$(CABS_STUDY_ABRUPT_CONFIGURATIONS) \
	$(CABS_STUDY_SETTINGS_SCRIPT) \
	$(BASE_SCRIPT)
	$(RSCRIPT) $< \
		--configurations $(CABS_STUDY_ABRUPT_CONFIGURATIONS) \
		--configuration-number 9 \
		--replicate-number $* \
		--output $@

$(CABS_STUDY_ABRUPT_CONFIGURATIONS): \
	scripts/cabs-study-abrupt-configurations.R \
	$(CABS_STUDY_SETTINGS_SCRIPT) \
	$(BASE_SCRIPT)
	$(RSCRIPT) $< \
		--output $@

## Slow

$(CABS_STUDY_SLOW_TVS_MSE): \
	scripts/cabs-study-tvs-mse.R \
	$(CABS_STUDY_SLOW_TVSM) \
	$(CABS_STUDY_SLOW_CONFIGURATIONS) \
	$(CABS_STUDY_SETTINGS_SCRIPT) \
	$(BASE_SCRIPT)
	$(RSCRIPT) $< \
		--tvsm-base $(CABS_STUDY_SLOW_TVSM_BASE) \
		--configurations $(CABS_STUDY_SLOW_CONFIGURATIONS) \
		--output $@

$(CABS_STUDY_SLOW_TVSM_BASE)-%.rds: \
	scripts/cabs-study-slow-tvsm.R \
	$(CABS_STUDY_SLOW_SAMPLES) \
	$(CABS_STUDY_SLOW_CONFIGURATIONS) \
	$(CABS_STUDY_SETTINGS_SCRIPT) \
	$(BASE_SCRIPT)
	$(RSCRIPT) $< \
		--samples-directory $(CABS_STUDY_SLOW_SAMPLES_DIRECTORY) \
		--configurations $(CABS_STUDY_SLOW_CONFIGURATIONS) \
		--configuration-number $* \
		--output $@

$(CABS_STUDY_SLOW_SAMPLES_BASE)-1-%.rds: \
	scripts/cabs-study-sample.R \
	$(CABS_STUDY_SLOW_CONFIGURATIONS) \
	$(CABS_STUDY_SETTINGS_SCRIPT) \
	$(BASE_SCRIPT)
	$(RSCRIPT) $< \
		--configurations $(CABS_STUDY_SLOW_CONFIGURATIONS) \
		--configuration-number 1 \
		--replicate-number $* \
		--output $@

$(CABS_STUDY_SLOW_SAMPLES_BASE)-2-%.rds: \
	scripts/cabs-study-sample.R \
	$(CABS_STUDY_SLOW_CONFIGURATIONS) \
	$(CABS_STUDY_SETTINGS_SCRIPT) \
	$(BASE_SCRIPT)
	$(RSCRIPT) $< \
		--configurations $(CABS_STUDY_SLOW_CONFIGURATIONS) \
		--configuration-number 2 \
		--replicate-number $* \
		--output $@

$(CABS_STUDY_SLOW_SAMPLES_BASE)-3-%.rds: \
	scripts/cabs-study-sample.R \
	$(CABS_STUDY_SLOW_CONFIGURATIONS) \
	$(CABS_STUDY_SETTINGS_SCRIPT) \
	$(BASE_SCRIPT)
	$(RSCRIPT) $< \
		--configurations $(CABS_STUDY_SLOW_CONFIGURATIONS) \
		--configuration-number 3 \
		--replicate-number $* \
		--output $@

$(CABS_STUDY_SLOW_SAMPLES_BASE)-4-%.rds: \
	scripts/cabs-study-sample.R \
	$(CABS_STUDY_SLOW_CONFIGURATIONS) \
	$(CABS_STUDY_SETTINGS_SCRIPT) \
	$(BASE_SCRIPT)
	$(RSCRIPT) $< \
		--configurations $(CABS_STUDY_SLOW_CONFIGURATIONS) \
		--configuration-number 4 \
		--replicate-number $* \
		--output $@

$(CABS_STUDY_SLOW_SAMPLES_BASE)-5-%.rds: \
	scripts/cabs-study-sample.R \
	$(CABS_STUDY_SLOW_CONFIGURATIONS) \
	$(CABS_STUDY_SETTINGS_SCRIPT) \
	$(BASE_SCRIPT)
	$(RSCRIPT) $< \
		--configurations $(CABS_STUDY_SLOW_CONFIGURATIONS) \
		--configuration-number 5 \
		--replicate-number $* \
		--output $@

$(CABS_STUDY_SLOW_SAMPLES_BASE)-6-%.rds: \
	scripts/cabs-study-sample.R \
	$(CABS_STUDY_SLOW_CONFIGURATIONS) \
	$(CABS_STUDY_SETTINGS_SCRIPT) \
	$(BASE_SCRIPT)
	$(RSCRIPT) $< \
		--configurations $(CABS_STUDY_SLOW_CONFIGURATIONS) \
		--configuration-number 6 \
		--replicate-number $* \
		--output $@

$(CABS_STUDY_SLOW_SAMPLES_BASE)-7-%.rds: \
	scripts/cabs-study-sample.R \
	$(CABS_STUDY_SLOW_CONFIGURATIONS) \
	$(CABS_STUDY_SETTINGS_SCRIPT) \
	$(BASE_SCRIPT)
	$(RSCRIPT) $< \
		--configurations $(CABS_STUDY_SLOW_CONFIGURATIONS) \
		--configuration-number 7 \
		--replicate-number $* \
		--output $@

$(CABS_STUDY_SLOW_SAMPLES_BASE)-8-%.rds: \
	scripts/cabs-study-sample.R \
	$(CABS_STUDY_SLOW_CONFIGURATIONS) \
	$(CABS_STUDY_SETTINGS_SCRIPT) \
	$(BASE_SCRIPT)
	$(RSCRIPT) $< \
		--configurations $(CABS_STUDY_SLOW_CONFIGURATIONS) \
		--configuration-number 8 \
		--replicate-number $* \
		--output $@

$(CABS_STUDY_SLOW_SAMPLES_BASE)-9-%.rds: \
	scripts/cabs-study-sample.R \
	$(CABS_STUDY_SLOW_CONFIGURATIONS) \
	$(CABS_STUDY_SETTINGS_SCRIPT) \
	$(BASE_SCRIPT)
	$(RSCRIPT) $< \
		--configurations $(CABS_STUDY_SLOW_CONFIGURATIONS) \
		--configuration-number 9 \
		--replicate-number $* \
		--output $@

$(CABS_STUDY_SLOW_CONFIGURATIONS): \
	scripts/cabs-study-slow-configurations.R \
	$(CABS_STUDY_SETTINGS_SCRIPT) \
	$(BASE_SCRIPT)
	$(RSCRIPT) $< \
		--output $@
