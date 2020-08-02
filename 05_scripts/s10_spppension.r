# Purpose: Scraping data for SPP Pension
# Author: David Gray Lassiter, PhD
# Date: 2020-Aug-01
# Version: 1.0

# Revisions:
# Author:
# Date: YYYY-MMM-DD
# Revised Version:

# 01 Preparing to scrape ####

spppension_df <-
    data.frame(
        fonds = c(
            "SEB Likviditetsfond SEK",
            "SPP Aktiefond USA",
            "SPP Sverige Plus A",
            "SPP Europa Plus A"
        ),
        price = c(rep(NA, 4))
    )

url_prefix <- "https://www.morningstar.se/se/funds/snapshot/snapshot.aspx?id="

spppension_ids <-
    c(
        "F0GBR04M5F",
        "F0GBR04FXR",
        "F00000XPDF",
        "F00001064H"
    )

spppension_sites_to_scrape <-
    paste0(url_prefix, spppension_ids)

# 02 Scraping ####

spppension_df %<>%
    scrape_multiple(spppension_sites_to_scrape, scrape_morningstar_dot_se)

# 03 Saving ####

openxlsx::addWorksheet(my_wb, "SPP_pensionfund")

openxlsx::writeData(my_wb, "SPP_pensionfund", spppension_df)

# 04 Appending to df for final QC ####

spppension_df[["Source"]] <- "SPP"

if (exists("all_assets_df")) {
    all_assets_df %<>%
        rbind(
            .,
            spppension_df
        )
} else {
    all_assets_df <- spppension_df
}