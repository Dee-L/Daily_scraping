# Purpose: Scraping data for Handelsbanken Pension
# Author: David Gray Lassiter, PhD
# Date: 2020-Aug-01
# Version: 1.0

# Revisions: Reverting since no packages to install
# Author: David Gray Lassiter, PhD
# Date: 2020-Aug-17
# Revised Version: 1.2

# 01 Preparing to scrape ####

fonds <- c(
    "Handelsbanken Global Tema",
    "Handelsbanken Kortränta SEK (A1 SEK)",
    "Handelsbanken Långränta (A1 SEK)",
    "Handelsbanken Svenska Småbolag A1",
    "Handelsbanken Företagsobligation (A1 SEK)",
    "Handelsbanken Pension 90 A13 SEK"
)

hpension <- data.frame(
    fonds,
    price = c(rep(NA, length(fonds)))
)

urlPrefix <- "https://www.morningstar.se/se/funds/snapshot/snapshot.aspx?id="

hpensionIds <-
    c(
        "F0GBR04F6J",
        "F0GBR04F6C",
        "F0GBR04F66",
        "F0GBR04F6F",
        "F00000UDDD",
        "F000011DNL"
    )

hpensionSitesToScrape <-
    paste0(urlPrefix, hpensionIds)

# 02 Scraping ####

hpension %<>%
    scrapeMultiple(hpensionSitesToScrape, scrapeMorningstarDotSe)

# 03 Saving and append for QC ####

saveAndAppendToTestDf(hpension)