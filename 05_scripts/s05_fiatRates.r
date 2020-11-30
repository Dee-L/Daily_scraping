# Purpose: Getting exchange rate data for fiat pairs
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
        "quantmod",
        "xml2",
        "rvest",
        "openxlsx"
    )

activatePkgs(pkgs)

# 02 Exchange-rate data for fiats ####

# Initializes df
fiatPairs <- data.frame(
    "USDSEK" = NA,
    "EURSEK" = NA,
    "EURUSD" = NA,
    "CHFSEK" = NA,
    "EURCHF" = NA,
    "USDCHF" = NA
)

fiatPairsToSearch <- names(fiatPairs)

# Initiates loop to cycle for each pair
for (i in seq_along(fiatPairsToSearch)) {
    # Gets rate
    quantmod::getQuote(paste0(fiatPairsToSearch[i], "=X"))$Last %>%
        # Stores it in a dataframe
        rbind.data.frame() ->
        # Saves it
        fiatPairs[, paste(fiatPairsToSearch[i])]
}

# 03 Exchange-rate data for Bitcoin to USD ####

fiatPairs[["BTCUSD"]] <-
    # Specify website
    "https://www.coingecko.com/en/price_charts/bitcoin/usd" %>%
    # Read it
    xml2::read_html(.) %>%
    # Extract required info
    rvest::html_nodes(".text-3xl .no-wrap") %>%
    # String manipulations
    rvest::html_text(.) %>%
    gsub(",", "", .) %>%
    gsub("[][$]", "", .) %>%
    # Convert to number
    as.numeric()

openxlsx::addWorksheet(myWb, "fiatPairs")

openxlsx::writeData(myWb, "fiatPairs", fiatPairs)