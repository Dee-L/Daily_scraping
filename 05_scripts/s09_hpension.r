# Purpose: Scraping data for Handelsbanken Pension
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
        "magrittr"
    )

install_my_pkgs(pkgs)

# 02 Preparing to scrape ####

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

# 03 Scraping ####

hpension magrittr::`%<>%`
    scrape_multiple(hpension_sites_to_scrape, scrape_morningstar_dot_se)

# 04 Saving and append for QC ####

save_and_append_to_test_df(hpension)