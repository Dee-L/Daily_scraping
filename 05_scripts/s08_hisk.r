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

urlPrefix <- "https://www.morningstar.se/se/funds/snapshot/snapshot.aspx?id="

hiskIds <-
    c(
        "F0GBR04F38",
        "F00000UI2B",
        "F00000UF2C"
    )

hiskSitesToScrape <-
    paste0(urlPrefix, hiskIds)

# 02 Scraping ####

hisk %<>%
    scrapeMultiple(hiskSitesToScrape, scrapeMorningstarDotSe)

# 03 Saving and append for QC ####

saveAndAppendToTestDf(hisk)