# Purpose: Scraping data for Robinhood
# Author: David Gray Lassiter, PhD
# Date: 2020-Aug-01
# Version: 1.0

# Revisions:
# Author:
# Date: YYYY-MMM-DD
# Revised Version:


# 01 Preparing to scrape ####

robinhood_df <- data.frame(
    fonds = c(
        "VNQI Stock",
        "IXJ Stock",
        "VNQ Stock",
        "SMOG Stock",
        "IYW Stock",
        "XBI Stock",
        "BNDX Bond",
        "FMB Bond",
        "SPTL Bond"
    ),
    price = c(rep(NA, 9))
)

robinhood_sites_to_scrape <- c(
    "https://www.morningstar.com/etfs/xnas/vnqi/quote",
    "https://www.morningstar.com/etfs/arcx/ixj/quote",
    "https://www.morningstar.com/etfs/arcx/vnq/quote",
    "https://www.morningstar.com/etfs/arcx/smog/quote",
    "https://www.morningstar.com/etfs/arcx/iyw/quote",
    "https://www.morningstar.com/etfs/arcx/xbi/quote",
    "https://www.morningstar.com/etfs/xnas/bndx/quote",
    "https://www.morningstar.com/etfs/xnas/fmb/quote",
    "https://www.morningstar.com/etfs/arcx/sptl/quote"
)

# 02 Scraping ####

robinhood_df %<>%
    scrape_multiple(robinhood_sites_to_scrape, scrape_morningstar_dot_com)

# 03 Saving ####

openxlsx::addWorksheet(my_wb, "Robinhood")

openxlsx::writeData(my_wb, "Robinhood", robinhood_df)

# 04 Appending to df for final QC ####

robinhood_df[["Source"]] <- "robinhood_df"

if (exists("all_assets_df")) {
    all_assets_df %<>%
        rbind(
            .,
            hisk_df
        )
} else {
    all_assets_df <<- robinhood_df
}