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

install_my_pkgs(pkgs)

# 02 Exchange-rate data for fiats ####

# Initializes df
fiat_pairs <- data.frame(
    "USDSEK" = NA,
    "EURSEK" = NA,
    "EURUSD" = NA,
    "CHFSEK" = NA,
    "EURCHF" = NA,
    "USDCHF" = NA
)

fiat_pairs_to_search <- names(fiat_pairs)

# Initiates loop to cycle for each pair
for (i in seq_along(fiat_pairs_to_search)) {
    # Gets rate
    quantmod::getQuote(paste0(fiat_pairs_to_search[i], "=X"))$Last %>%
        # Stores it in a dataframe
        rbind.data.frame() ->
        # Saves it
        fiat_pairs[, paste(fiat_pairs_to_search[i])]
}

# 03 Exchange-rate data for Bitcoin to USD ####

fiat_pairs[["BTCUSD"]] <-
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

openxlsx::addWorksheet(my_wb, "fiat_pairs")

openxlsx::writeData(my_wb, "fiat_pairs", fiat_pairs)