# Purpose: Scraping data for Länsförsäkringar
# Author: David Gray Lassiter, PhD
# Date: 2020-Aug-01
# Version: 1.0

# Revisions: Reverting since no packages to install
# Author: David Gray Lassiter, PhD
# Date: 2020-Aug-17
# Revised Version: 1.2

# 01 Preparing to scrape ####

fonds <- c(
    "BlackRock Sustainable Energy",
    "Fidelity Global Technology",
    "JPM Global Healthcare",
    "SEB Green Bond Fund"
)

lansforsakringar <-
    data.frame(
        fonds,
        price = c(rep(NA, length(fonds)))
    )

urlPrefix <-
    paste0(
        "https://www.lansforsakringar.se/stockholm/privat/bank/spara/",
        "fondkurser/jamfor-fonder/?term=jpm%20global&universeId=ALL_5085&ids=")

lansforsakringarIds <-
    c(
        "F0GBR04KF3",
        "F00000T2AE",
        "F00000454U",
        "F00000VFU9"
    )

lansforsakringarSites <-
    paste0(urlPrefix, lansforsakringarIds)

# 02 Scraping ####

lansforsakringar %<>%
    scrapeMultiple(lansforsakringarSites, scrapeLansforsakringarDotSe)

# 03 Saving and append for QC ####

saveAndAppendToTestDf(lansforsakringar)