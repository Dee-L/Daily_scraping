# Purpose: Scraping data for Länsförsäkringar
# Author: David Gray Lassiter, PhD
# Date: 2020-Aug-01
# Version: 1.0

# Revisions:
# Author:
# Date: YYYY-MMM-DD
# Revised Version:

# 01 Preparing to scrape ####

lansforsakringar_df <-
    data.frame(
        fonds = c(
            "BlackRock Sustainable Energy",
            "Fidelity Global Technology",
            "JPM Global Healthcare",
            "SEB Green Bond Fund"
        ),
        price = c(rep(NA, 4))
    )

url_prefix <-
    paste0(
        "https://www.lansforsakringar.se/stockholm/privat/bank/spara/",
        "fondkurser/jamfor-fonder/?term=jpm%20global&universeId=ALL_5085&ids=")

lansforsakringar_ids <-
    c(
        "F0GBR04KF3",
        "F00000T2AE",
        "F00000454U",
        "F00000VFU9"
    )

lansforsakringar_sites <-
    paste0(url_prefix, lansforsakringar_ids)

# 02 Scraping ####

lansforsakringar_df %<>%
    scrape_multiple(lansforsakringar_sites, scrape_lansforsakringar_dot_se)

# 03 Saving ####

openxlsx::addWorksheet(my_wb, "Lansforsakringar")

openxlsx::writeData(my_wb, "Lansforsakringar", lansforsakringar_df)

# 04 Appending to df for final QC ####

lansforsakringar_df[["Source"]] <- "Länsförsäkringar"

if (exists("all_assets_df")) {
    all_assets_df %<>%
        rbind(
            .,
            lansforsakringar_df
        )
} else {
    all_assets_df <- lansforsakringar_df
}