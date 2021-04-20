RSCRIPT = Rscript

FIGURES =

# Partials
BASE_SCRIPT = scripts/partials/base.R
DISPLAY_SETTINGS_SCRIPT = scripts/partials/display-settings.R

AUSTRALIA_MAP = data/australia-map.rds
BOM_HQ = data/bom_hq.db

$(shell mkdir -p data intermediate figures)

all: figures

bootstrap:
	$(RSCRIPT) -e "renv::restore()"

include module_multiple_simulation_study.mk
include module_cabs_study.mk
include module_monthly_rainfall.mk
include module_measles.mk

figures: $(FIGURES)
.SECONDARY: $(SECONDARY_TARGETS)
