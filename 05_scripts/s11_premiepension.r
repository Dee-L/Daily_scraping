# Purpose: Scraping data for Premiepension
# Author: David Gray Lassiter, PhD
# Date: 2020-Aug-01
# Version: 1.0

# Revisions: Reverting since no packages to install
# Author: David Gray Lassiter, PhD
# Date: 2020-Aug-17
# Revised Version: 1.2

# 01 Preparing to scrape ####

fonds <- c(
    "Skandia Time Global",
    "Seligson & Co Global Top 25 Pharmaceuticals A",
    "Lannebo Likviditetsfond",
    "CB Save Earth Fund RC",
    "Swedbank Robur Fastighet A"
)

premiepension <-
    data.frame(
        fonds,
        price = c(rep(NA, length(fonds)))
    )

urlPrefix <- "https://www.pensionsmyndigheten.se/service/fondtorg/fond/"

premiepensionIds <-
    c(
        "439471",
        "416982",
        "478313",
        "976506",
        "968420"
    )

premiepensionSitesToScrape <-
    paste0(urlPrefix, premiepensionIds)

# 02 Scraping ####

premiepension %<>%
    scrapeMultiple(premiepensionSitesToScrape,
    scrapePnsnsmyndighetenDotSe)

# 03 Saving and append for QC ####

saveAndAppendToTestDf(premiepension)