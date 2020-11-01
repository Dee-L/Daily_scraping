# Purpose: Scraping data for robinhood
# Author: David Gray Lassiter, PhD
# Date: 2020-Aug-01
# Version: 1.0

# Revisions: Dropped scraping for cryptos
# Author: David Gray Lassiter, PhD
# Date: 2020-Sep-18
# Revised Version: 1.4

# 00 Developments to make ####

# Scrape prices from Robinhood directly.
# Python library allows me to. However, I don't have a way to get crypto data.
# The R library allows me to get crypto data, but is not setup for MFA, and
# thus doesn't work.
# Both involve sharing credentials, which makes me a bit uncomfortable.
# I believe the solution will be to extract the necessary R functions, and
# modify them so as to use the same MFA authentication as is used in the python
# library.

# The R documentation:
# https://cran.r-project.org/web/packages/RobinHood/RobinHood.pdf
# https://github.com/JestonBlu/RobinHood

# The Python documentation:
# (look for qr_code) https://github.com/LichAmnesia/Robinhood/blob/master/Robinhood/Robinhood.py
# https://github.com/LichAmnesia/Robinhood
# https://towardsdatascience.com/step-by-step-building-an-automated-trading-system-in-robinhood-807d6d929cf3

# 01 Ensure all pkgs in this scripts are installed ####
pkgs <-
    c(
        "sqldf"
    )

installMyPkgs(pkgs)

# 02 Preparing to scrape ####

fonds <- c(
    "VNQI Stock"
    , "IXJ Stock"
    , "VNQ Stock"
    , "SMOG Stock"
    , "IYW Stock"
    , "XBI Stock"
    , "BNDX Bond"
    , "FMB Bond"
    , "SPTL Bond"
)

robinhood <- data.frame(
    fonds,
    price = c(rep(NA, length(fonds)))
)

robinhoodSitesToScrape <- c(
    "https://www.morningstar.com/etfs/xnas/vnqi/quote"
    , "https://www.morningstar.com/etfs/arcx/ixj/quote"
    , "https://www.morningstar.com/etfs/arcx/vnq/quote"
    , "https://www.morningstar.com/etfs/arcx/smog/quote"
    , "https://www.morningstar.com/etfs/arcx/iyw/quote"
    , "https://www.morningstar.com/etfs/arcx/xbi/quote"
    , "https://www.morningstar.com/etfs/xnas/bndx/quote"
    , "https://www.morningstar.com/etfs/xnas/fmb/quote"
    , "https://www.morningstar.com/etfs/arcx/sptl/quote"
)

# 03 Scraping ####

robinhood %<>%
    scrapeMultiple(robinhoodSitesToScrape, scrapeMorningstarDotCom)

# 04 Saving and append for QC ####

saveAndAppendToTestDf(robinhood)