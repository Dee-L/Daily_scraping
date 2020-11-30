# Purpose: Scraping data from Mäklarstatistik
# Author: David Gray Lassiter, PhD
# Date: 2020-Nov-28
# Version: 1.0

# 01 Preparing to scrape ####

stockholmAreas <- c(
    'kungsholmen'
)

# Using `fonds` and `price` as columns so that can rbind to allAssetsdf
# in final step when calling `saveAndAppendToTestDf`
maklarstatistik <-
    data.frame(
        fonds = 'kungsholmen',
        price = c(rep(NA, length(stockholmAreas)))
    )

urlPrefix <- "https://www.maklarstatistik.se/omrade/riket/stockholms-lan/stockholm/"

maklarstatistikSites <-
    paste0(urlPrefix, stockholmAreas, "/")


# 02 Scraping ####

maklarstatistik %<>%
    scrapeMultiple(maklarstatistikSites, scrapeMaklarstatistik)

# 03 Saving and append for QC ####

saveAndAppendToTestDf(maklarstatistik)