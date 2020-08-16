# Purpose: Scraping data for Handelsbanken ISK
# Author: David Gray Lassiter, PhD
# Date: 2020-Aug-01
# Version: 1.0

# Revisions: Getting project to install necessary packages if not done yet.
# Author: David Gray Lassiter, PhD
# Date: 2020-Aug-16
# Revised Version: 1.1

# 01 Ensure all pkgs in this scriptare installed ####
pkgs <-
    c(
        ""
    )

install_my_pkgs(pkgs)

# 02 Preparing to scrape ####

hisk <- data.frame(
    fonds = c(
        "Handelsbanken Hälsovård Tema SEK",
        "Handelsbanken Hållbar Energi",
        "Handelsbanken Euro Obligation"
    ),
    price = c(rep(NA, 3))
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

# 03 Scraping ####

hisk %<>%
    scrape_multiple(hisk_sites_to_scrape, scrape_morningstar_dot_se)

# 04 Saving and append for QC ####

save_and_append_to_test_df(hisk)