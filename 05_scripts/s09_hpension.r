# Purpose: Scraping data for Handelsbanken Pension
# Author: David Gray Lassiter, PhD
# Date: 2020-Aug-01
# Version: 1.0

# Revisions:
# Author:
# Date: YYYY-MMM-DD
# Revised Version:

# 01 Preparing to scrape ####

hpension <- data.frame(
    fonds = c(
        "Handelsbanken Global Tema",
        "Handelsbanken Kortränta SEK (A1 SEK)",
        "Handelsbanken Långränta (A1 SEK)",
        "Handelsbanken Svenska Småbolag A1",
        "Handelsbanken Företagsobligation (A1 SEK)",
        "Handelsbanken Pension 90 A13 SEK"
    ),
    price = c(rep(NA, 6))
)

url_prefix <- "https://www.morningstar.se/se/funds/snapshot/snapshot.aspx?id="

hpension_ids <-
    c(
        "F0GBR04F6J",
        "F0GBR04F6C",
        "F0GBR04F66",
        "F0GBR04F6F",
        "F00000UDDD",
        "F000011DNL"
    )

hpension_sites_to_scrape <-
    paste0(url_prefix, hpension_ids)

# 02 Scraping ####

hpension %<>%
    scrape_multiple(hpension_sites_to_scrape, scrape_morningstar_dot_se)

# 03 Saving and append for QC ####

save_and_append_to_test_df(hpension)