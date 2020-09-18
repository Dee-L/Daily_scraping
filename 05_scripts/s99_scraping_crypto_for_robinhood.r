# Purpose: Unused scraping crypto data for Robinhood
# Author: David Gray Lassiter, PhD
# Date: 2020-Sep-18
# Version: 1.0

# Revisions: 
# Author: 
# Date: 
# Revised Version:

# This code is not being used since I decided not to trade cryptos on
# Robinhood.

# 01 Adding crypto placeholders until I develop a way to interact with api ####
cryptos <- c(
    "LTC_",
    "ETC_",
    "ETH_",
    "DOGE",
    "BSV_",
    "BTC_"
)

rh_cryptos <- data.frame(
    cryptos,
    price = c(rep(NA, length(cryptos)))
)

# Populating prices based on kraken values - strange that averaging
# only works if the column name has an integer as a suffix?

rh_cryptos <- 
    sqldf::sqldf("
            select
                cryptos
                , (BID + ASK) / 2 as price1
            from kraken
                join rh_cryptos
                    on cryptos = SELLING_1_of and BUYS_x_of = 'USD_'
    ")

# Appending "Crypto" to names

rh_cryptos[["cryptos"]] %<>% paste0(., " Crypto")

# Renaming for rbind

names(rh_cryptos) <- c("fonds", "price")

robinhood %<>%
    rbind(., rh_cryptos)