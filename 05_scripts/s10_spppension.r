# Purpose: Scraping data for SPP Pension
# Author: David Gray Lassiter, PhD
# Date: 2020-Aug-01
# Version: 1.0

# Revisions: Reverting since no packages to install
# Author: David Gray Lassiter, PhD
# Date: 2020-Aug-17
# Revised Version: 1.2

# 01 Preparing to scrape ####

fonds <- c(
    "SEB Likviditetsfond SEK",
    "SPP Aktiefond USA",
    "SPP Sverige Plus A",
    "SPP Europa Plus A"
)

spppension <-
    data.frame(
        fonds,
        price = c(rep(NA, length(fonds)))
    )

urlPrefix <- "https://www.morningstar.se/se/funds/snapshot/snapshot.aspx?id="

spppensionIds <-
    c(
        "F0GBR04M5F",
        "F0GBR04FXR",
        "F00000XPDF",
        "F00001064H"
    )

spppensionSitesToScrape <-
    paste0(urlPrefix, spppensionIds)

# 02 Scraping ####

spppension %<>%
    scrapeMultiple(spppensionSitesToScrape, scrapeMorningstarDotSe)

# 03 Saving and append for QC ####

saveAndAppendToTestDf(spppension)