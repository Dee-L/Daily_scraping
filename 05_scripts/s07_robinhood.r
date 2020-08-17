# Purpose: Scraping data for robinhood
# Author: David Gray Lassiter, PhD
# Date: 2020-Aug-01
# Version: 1.0

# Revisions: Reverting since no packages to install
# Author: David Gray Lassiter, PhD
# Date: 2020-Aug-17
# Revised Version: 1.2

# 01 Preparing to scrape ####

robinhood <- data.frame(
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

robinhood %<>%
    scrape_multiple(robinhood_sites_to_scrape, scrape_morningstar_dot_com)

# 03 Saving and append for QC ####

save_and_append_to_test_df(robinhood)