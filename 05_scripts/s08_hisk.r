# Purpose: Scraping data for Handelsbanken ISK
# Author: David Gray Lassiter, PhD
# Date: 2020-Aug-01
# Version: 1.0

# Revisions:
# Author:
# Date: YYYY-MMM-DD
# Revised Version:


# 01 Preparing to scrape ####

hisk_df <- data.frame(
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

# 02 Scraping ####

hisk_df %<>%
    scrape_multiple(hisk_sites_to_scrape, scrape_morningstar_dot_se)

# 03 Saving ####

openxlsx::addWorksheet(my_wb, "Handelsbanken_ISK")

openxlsx::writeData(my_wb, "Handelsbanken_ISK", hisk_df)

# 04 Appending to df for final QC ####

hisk_df[["Source"]] <- "hisk_df"

if (exists("all_assets_df")) {
    all_assets_df %<>%
        rbind(
            .,
            hisk_df
        )
} else {
    all_assets_df <- hisk_df
}