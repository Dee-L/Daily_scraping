# Purpose: Scraping data from kraken
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
        "openxlsx",
        "dplyr",
        "jsonlite"
    )

activatePkgs(pkgs)

# 02 Preparing to scrape ####

krakenCcs <- openxlsx::read.xlsx(ccTickerLookupTable, sheet = "kraken")

krakenNPairs <-
    openxlsx::read.xlsx(
        xlsxFile = myBudgetXlsm,
        sheet = "kraken",
        rows = 5:6,
        cols = 2
    )[1, 1]

startRowForKraken <-
    openxlsx::read.xlsx(
        xlsxFile = myBudgetXlsm,
        sheet = "kraken",
        rows = 5:6,
        cols = 3
    )[1, 1]

endRowForKraken <-
    startRowForKraken + krakenNPairs

kraken <- # create df for my kraken
    data.frame(
        selling1Of =
            openxlsx::read.xlsx(
                xlsxFile = myBudgetXlsm,
                sheet = "kraken",
                rows = startRowForKraken : endRowForKraken,
                cols = 2
            ),
        buysXOf =
            openxlsx::read.xlsx(
                xlsxFile = myBudgetXlsm,
                sheet = "kraken",
                rows = startRowForKraken : endRowForKraken,
                cols = 3
            ),
        BID = NA,
        ASK = NA
    )

kraken$id <- seq_len(nrow(kraken)) # creates sorting variable

kraken %<>%
    # adds tags for cc2
    merge(krakenCcs, by.x = "selling1Of", by.y = "fourLetterTicker") %>%
    # renames it
    dplyr::rename(krakenUrlTagForSelling = krakenUrlTag) %>%
    # adds tags for cc1
    merge(krakenCcs, by.x = "buysXOf", by.y = "fourLetterTicker") %>%
    # renames it
    dplyr::rename(krakenUrlTagForBuying = krakenUrlTag) %>%
    # reorders columns
    .[, c(
        "id",
        "selling1Of",
        "buysXOf",
        "BID",
        "ASK",
        "krakenUrlTagForSelling",
        "krakenUrlTagForBuying")] %>%
    # orders by id column
    .[order(.$id), ] %>%
    # drops id column
    .[, colnames(.) %notIn% "id"]

# The currency you want to sell goes into the address first
kraken[["URL"]] <-
    paste0(
        "https://api.kraken.com/0/public/Ticker?pair=",
        kraken$krakenUrlTagForSelling,
        kraken$krakenUrlTagForBuying)

krakenDiscontinuedTickers <-
    krakenCcs$fourLetterTicker[krakenCcs$krakenDiscontinued == TRUE]

for (i in seq_len(nrow(kraken))) {

    if ((kraken$selling1Of[i] %in%
        currenciesToGetRatesFor &
        kraken$selling1Of[i] %notIn%
            krakenDiscontinuedTickers &
        kraken$buysXOf[i] %in%
            currenciesToGetRatesFor &
        kraken$buysXOf[i] %notIn%
            krakenDiscontinuedTickers
    ) == FALSE) {
        # doesn't look up data if currencies are of little consequence for me
        kraken$BID[i] <- NA
        kraken$ASK[i] <- NA
    }
    else {
        cat(paste0("kraken ", i, " of ", nrow(kraken), " pairs.\n\n"))
        tryWaitRetry({
            ithjson <- # read JSON file
                kraken$URL[i] %>% # creates url to search
                jsonlite::fromJSON(.) # parses the JSON

            kraken$BID[i] <- # extracts the BID price
                ithjson$result %>%
                .[[1]] %>%
                .$b %>%
                .[1] %>%
                as.numeric()

            kraken$ASK[i] <- # extracts the ASK price
                ithjson$result %>%
                .[[1]] %>%
                .$a %>%
                .[1] %>%
                as.numeric()
        })
    }
} # closes loop

openxlsx::addWorksheet(myWb, "kraken")

openxlsx::writeData(myWb, "kraken", kraken)

# 02 Setting up intra-exchange arbitrage paths ####

krakenArbPaths <-
    intraExcArbPaths2Interm(
        listOfCurrenciesInExchange = krakenCcs$fourLetterTicker,
        currenciesOnSellingSide = kraken$selling1Of,
        currenciesOnBuyingSide = kraken$buysXOf
    )

openxlsx::addWorksheet(myWb, "krakenArbPaths")

openxlsx::writeData(myWb, "krakenArbPaths", krakenArbPaths)