# Purpose: Scraping data for robinhood
# Author: David Gray Lassiter, PhD
# Date: 2020-Aug-01
# Version: 1.0

# Revisions: Getting project to install necessary packages if not done yet.
# Author: David Gray Lassiter, PhD
# Date: 2020-Aug-16
# Revised Version: 1.1

# 01 Ensure all pkgs in this scriptare installed ####
pkgs <-
    c(
        "magrittr"
    )

install_my_pkgs(pkgs)

# 02 Preparing to scrape ####

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

# 03 Scraping ####

robinhood magrittr::`%<>%`
    scrape_multiple(robinhood_sites_to_scrape, scrape_morningstar_dot_com)

# 04 Saving and append for QC ####

save_and_append_to_test_df(robinhood)