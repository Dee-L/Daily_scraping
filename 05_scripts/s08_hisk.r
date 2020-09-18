# Purpose: Scraping data for Handelsbanken ISK
# Author: David Gray Lassiter, PhD
# Date: 2020-Aug-01
# Version: 1.0

# Revisions: Reverting since no packages to install
# Author: David Gray Lassiter, PhD
# Date: 2020-Aug-17
# Revised Version: 1.2

# 01 Preparing to scrape ####

fonds <- c(
    "Handelsbanken Hälsovård Tema SEK",
    "Handelsbanken Hållbar Energi",
    "Handelsbanken Euro Obligation"
)

hisk <- data.frame(
    fonds,
    price = c(rep(NA, length(fonds)))
)

url_prefix <- "https://www.morningstar.se/se/funds/snapshot/snapshot.aspx?id="

hisk_ids <-
    c(
        "F0GBR04F38",
        "F00000UI2B",
        "F00000UF2C"
    )

hisk_sites_to_scrape <-
    paste0(url_prefix, hisk_ids)

# 02 Scraping ####

hisk %<>%
    scrape_multiple(hisk_sites_to_scrape, scrape_morningstar_dot_se)

# 03 Saving and append for QC ####

save_and_append_to_test_df(hisk)