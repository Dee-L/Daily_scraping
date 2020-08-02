# Purpose: Scraping data from Kraken
# Author: David Gray Lassiter, PhD
# Date: 2020-Aug-01
# Version: 1.0

# Revisions:
# Author:
# Date: YYYY-MMM-DD
# Revised Version:


# 01 Preparing to scrape ####

kraken_ccs <- openxlsx::read.xlsx(cc_ticker_lookup_table, sheet = "Kraken")

kraken_n_pairs <-
    openxlsx::read.xlsx(
        xlsxFile = my_budget_xlsm,
        sheet = "Kraken",
        rows = 5:6,
        cols = 2
    )[1, 1]

start_row_for_kraken_pairs <-
    openxlsx::read.xlsx(
        xlsxFile = my_budget_xlsm,
        sheet = "Kraken",
        rows = 5:6,
        cols = 3
    )[1, 1]

end_row_for_kraken_pairs <-
    start_row_for_kraken_pairs + kraken_n_pairs

kraken_pairs <- # create df for my kraken_pairs
    data.frame(
        SELLING_1_of =
            openxlsx::read.xlsx(
                xlsxFile = my_budget_xlsm,
                sheet = "Kraken",
                rows = start_row_for_kraken_pairs:end_row_for_kraken_pairs,
                cols = 2
            ),
        BUYS_x_of =
            openxlsx::read.xlsx(
                xlsxFile = my_budget_xlsm,
                sheet = "Kraken",
                rows = start_row_for_kraken_pairs:end_row_for_kraken_pairs,
                cols = 3
            ),
        BID = NA,
        ASK = NA
    )

kraken_pairs$id <- seq_len(nrow(kraken_pairs)) # creates sorting variable

kraken_pairs %<>%
    # adds tags for cc2
    merge(kraken_ccs, by.x = "SELLING_1_of", by.y = "four_letter_ticker") %>%
    # renames it
    dplyr::rename(Kraken_URL_tag_for_selling = Kraken_URL_tag) %>%
    # adds tags for cc1
    merge(kraken_ccs, by.x = "BUYS_x_of", by.y = "four_letter_ticker") %>%
    # renames it
    dplyr::rename(Kraken_URL_tag_for_buying = Kraken_URL_tag) %>%
    # reorders columns
    .[, c(
        "id",
        "SELLING_1_of",
        "BUYS_x_of",
        "BID",
        "ASK",
        "Kraken_URL_tag_for_selling",
        "Kraken_URL_tag_for_buying")] %>%
    # orders by id column
    .[order(.$id), ] %>%
    # drops id column
    .[, colnames(.) %not_in% "id"]

# The currency you want to sell goes into the address first
kraken_pairs[["URL"]] <-
    paste0(
        "https://api.kraken.com/0/public/Ticker?pair=",
        kraken_pairs$Kraken_URL_tag_for_selling,
        kraken_pairs$Kraken_URL_tag_for_buying)

kraken_discontinued_tickers <-
    kraken_ccs$four_letter_ticker[kraken_ccs$Kraken_discontinued == TRUE]

for (i in seq_len(nrow(kraken_pairs))) {

    if ((kraken_pairs$SELLING_1_of[i] %in%
        currencies_to_get_rates_for &
        kraken_pairs$SELLING_1_of[i] %not_in%
            kraken_discontinued_tickers &
        kraken_pairs$BUYS_x_of[i] %in%
            currencies_to_get_rates_for &
        kraken_pairs$BUYS_x_of[i] %not_in%
            kraken_discontinued_tickers
    ) == FALSE) {
        # doesn't look up data if currencies are of little consequence for me
        kraken_pairs$BID[i] <- NA
        kraken_pairs$ASK[i] <- NA
    }
    else {
        cat(paste0("Kraken ", i, " of ", nrow(kraken_pairs), " pairs.\n\n"))
        try_wait_retry({
            ithjson <- # read JSON file
                kraken_pairs$URL[i] %>% # creates url to search
                jsonlite::fromJSON(.) # parses the JSON

            kraken_pairs$BID[i] <- # extracts the BID price
                ithjson$result %>%
                .[[1]] %>%
                .$b %>%
                .[1] %>%
                as.numeric()

            kraken_pairs$ASK[i] <- # extracts the ASK price
                ithjson$result %>%
                .[[1]] %>%
                .$a %>%
                .[1] %>%
                as.numeric()
        })
    }
} # closes loop

openxlsx::addWorksheet(my_wb, "Kraken_pairs")

openxlsx::writeData(my_wb, "Kraken_pairs", kraken_pairs)

# 02 Setting up intra-exchange arbitrage paths ####

kraken_arb_paths <-
    intra_exc_arb_paths_2_interm(
        list_of_currencies_in_exchange = kraken_ccs$four_letter_ticker,
        currencies_on_selling_side = kraken_pairs$SELLING_1_of,
        currencies_on_buying_side = kraken_pairs$BUYS_x_of
    )

openxlsx::addWorksheet(my_wb, "Kraken_arb_paths")

openxlsx::writeData(my_wb, "Kraken_arb_paths", kraken_arb_paths)