source('scripts/partials/base.R')
source('scripts/partials/monthly-rainfall.R')
suppressWarnings({
  library(DBI, quietly = TRUE)
  library(RSQLite, quietly = TRUE)
  library(dplyr, warn.conflicts = FALSE)
  library(dbplyr, warn.conflicts = FALSE)
  library(futile.logger)
  library(withr)
})

with_db_connection(
  list(con = dbConnect(RSQLite::SQLite(), 'data/bom_hq.db')),
  {
    flog.info('Getting metadata')
    metadata <- con %>%
      tbl('bom_site') %>%
      collect() %>%
      arrange(number)

    flog.info(
      'Getting daily data for %d sites included by location',
      nrow(metadata)
    )
    daily <- con %>%
      tbl('bom_rainfall') %>%
      filter(
        site_number %in% !!metadata$number,
        date >= !!monthly_rainfall_settings$start_date,
        date <= !!monthly_rainfall_settings$end_date
      ) %>%
      collect() %>%
      mutate(
        rainfall = ifelse(days_measured == 1, rainfall, NA)
      )
  }
)

flog.info('Converting to monthly data')
observations <- daily %>%
  mutate(month = substring(date, 1, 7)) %>%
  group_by(site_number, month) %>%
  summarise(
    average_rainfall = mean(rainfall, na.rm = TRUE),
    n_days = n(),
    n_not_missing = sum(!is.na(rainfall))
  ) %>%
  arrange(site_number, month) %>%
  mutate(
    average_rainfall = ifelse(
      n_not_missing > 15,
      ifelse(
        is.finite(average_rainfall),
        average_rainfall,
        NA
      ),
      NA
    )
  )

flog.info('Saving site metadata')
saveRDS(metadata, 'intermediate/monthly-rainfall-metadata.rds', compress = FALSE)

flog.info('Saving monthly data')
saveRDS(observations, 'intermediate/monthly-rainfall-observations.rds', compress = FALSE)

flog.info('Done')
