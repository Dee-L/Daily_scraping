# Purpose: Prioritize which cryptocurrencies to evaluate and trade
# Author: David Gray Lassiter, PhD
# Date: 2020-Aug-01
# Version: 1.0

# Revisions: Getting project to install necessary packages if not done yet.
# Author: David Gray Lassiter, PhD
# Date: 2020-Aug-16
# Revised Version: 1.1

# Ideas for revision:

# 01 Ensure all pkgs in this scriptare installed ####
pkgs <-
    c(
        "openxlsx",
        "reticulate")

installMyPkgs(pkgs)

# 02 Create df for looking up cc values ####
cmcCCs <-
    openxlsx::read.xlsx(ccTickerLookupTable, sheet = "CoinMarketCap")

# 03 Scrape today's values via Python and cleanup the environment after. ####

# This is currently throwing an error since there is something,
# but it saves a csv in the 'outputs' file which can be used.
# If "ModuleNotFound" errors thrown, can use py_install('<name of module>').
# I believe this installs the modules in the miniconda/R installation.
# This may mean that you have python installed in two different places on your
# machine.

# Source python to do the job
reticulate::source_python("05_scripts/s03_cmcScraper.py")

# Retrieve the output from the python job
cmcData <- read.csv("07_outputs/02_cmcData.csv")

# Cleanup memory
rm(r, ConnectionError, R, Request, Session, Timeout, TooManyRedirects)

# Remove cache
unlink(paste0(scriptsFolder, "__pycache__"), recursive = TRUE)

# 04 If scraping fails ####

# If the python script doesn't work, use the former ranks for the ccs.

tryCatch({
        ccsRanked <<-
            # match the scraped data
            cmcData[["name"]] %>%
            match(
                x = .,
                cmcCCs$coinmarketcapNameForPythonMatching) %>%
            # Extracts my tickers
            cmcCCs$coinmarketcapTicker[.] %>%
            # Converts to Tickers
            {
                iterator <- length(.)
                data.frame(
                    mcRank = seq_len(iterator),
                    coinmarketcapTicker = .,
                    row.names = NULL)
            } %>%
            # drop ccs I don't collect
            .[!(is.na(.$coinmarketcapTicker)), ] %>%
            # bring in fourLetterTicker
            merge(., y = cmcCCs) %>%
            # sorts df
            .[order(.$mcRank), ] %>%
            # add ccPriorityColumn
            {
                iterator <- nrow(.)
                data.frame(.,
                    ccPriority = seq_len(iterator),
                    row.names = NULL)
            } %>%
            # keep only necessary columns
            .[, c(
                "ccPriority",
                "mcRank",
                "fourLetterTicker")]
    },
    error = function(e) {
        cat("Error: ", e$message, "\n")
        ccsRanked <<-
            openxlsx::readWorkbook(
                "07_outputs/03_scrapedDaily.xlsx",
                "ccsRanked")
    }
)

openxlsx::addWorksheet(myWb, "ccsRanked")

openxlsx::writeData(myWb, "ccsRanked", ccsRanked)

# 05 Subsetting CCs based on market cap and if already hold ####

numberOfTickers <-
    openxlsx::read.xlsx(
        xlsxFile = myBudgetXlsm,
        sheet = "ccSummarySheet",
        rows = 22 : 23,
        cols = 2
    )[1, 1]

startRowForCcSummary <-
    openxlsx::read.xlsx(
        xlsxFile = myBudgetXlsm,
        sheet = "ccSummarySheet",
        rows = 22:23,
        cols = 3
    )[1, 1]

endRowForCcSummary <-
    startRowForCcSummary + numberOfTickers

valuesOfCcsHeld <- # extract data about which currencies I have and values
    cbind(
        openxlsx::read.xlsx(
            xlsxFile = myBudgetXlsm,
            sheet = "ccSummarySheet",
            rows = startRowForCcSummary : endRowForCcSummary,
            cols = 1
        ),
        openxlsx::read.xlsx(
            xlsxFile = myBudgetXlsm,
            sheet = "ccSummarySheet",
            rows = startRowForCcSummary : endRowForCcSummary,
            cols = 6
        )
    )

currenciesHeld <- # subset currencies to only include those I hold
    valuesOfCcsHeld$fourLetterTicker[
        valuesOfCcsHeld$totalValueInEUR > 0]

marketCapRankCutoff <- # pull market cap cutoff from file
    openxlsx::read.xlsx(
        xlsxFile = myBudgetXlsm,
        sheet = "ccSummarySheet",
        rows = 14 : 15,
        cols = 4
    )[1, 1]

ccsUnderCutoff <- # make list of ccs which have high enough market cap
    ccsRanked$fourLetterTicker[
        ccsRanked$mcRank <
            marketCapRankCutoff
    ] %>% as.character()

currenciesToGetRatesFor <-
    c(currenciesHeld, ccsUnderCutoff) %>% unique()