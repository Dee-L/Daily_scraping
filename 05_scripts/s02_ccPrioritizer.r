# Purpose: Prioritize which cryptocurrencies to evaluate and trade
# Author: David Gray Lassiter, PhD

# Sys.setenv(RETICULATE_PYTHON = "C:/Users/D/anaconda3/envs/r-reticulate/")

# 01 Ensure all pkgs in this scriptare installed ####
pkgs <-
    c(
        "openxlsx",
        # "coinmarketcapr",
        "reticulate"
        )

activatePkgs(pkgs)

# 02 Create df for looking up cc values ####
cmcCCs <-
    openxlsx::read.xlsx(ccTickerLookupTable, sheet = "CoinMarketCap")

# 03 Scrape today's values via R ####
# This works for top 100 only - I posed a question to the repo owner ####
# coinmarketcapr::setup(myApiKey)
# cmcData <- get_crypto_listings()

# 04 Scrape today's values via Python. ####

# 05 Specify which installation of python to use - otherwise script pauses ####
reticulate::use_python("C:/Users/D/anaconda3/python.exe")

# 06 Will get error on first use of reticulate function, so wrap in `try` ####
try(reticulate::source_python("05_scripts/s03_cmcScraper.py"))
reticulate::source_python("05_scripts/s03_cmcScraper.py")

# 04 Retrieve the output from the python job ####
cmcData <- read.csv("07_outputs/02_cmcData.csv")

# 05 Cleanup memory ####
rm(r, ConnectionError, Request, Session, Timeout, TooManyRedirects)

# 06 Remove cache ####
unlink(paste0(scriptsFolder, "__pycache__"), recursive = TRUE)

# 07 If scraping fails, use the former ranks for the ccs. ####
tryCatch({
        ccsRanked <<-
            # 08 match the scraped data ####
            cmcData[["name"]] %>%
            match(
                x = .,
                cmcCCs$coinmarketcapNameForPythonMatching) %>%
            # 09 Extracts my tickers ####
            cmcCCs$coinmarketcapTicker[.] %>%
            # 10 Converts to Tickers ####
            {
                iterator <- length(.)
                data.frame(
                    mcRank = seq_len(iterator),
                    coinmarketcapTicker = .,
                    row.names = NULL)
            } %>%
            # 11 drop ccs I don't collect ####
            .[!(is.na(.$coinmarketcapTicker)), ] %>%
            # 12 bring in fourLetterTicker ####
            merge(., y = cmcCCs) %>%
            # 13 sorts df ####
            .[order(.$mcRank), ] %>%
            # 14 add ccPriorityColumn ####
            {
                iterator <- nrow(.)
                data.frame(.,
                    ccPriority = seq_len(iterator),
                    row.names = NULL)
            } %>%
            # 15 keep only necessary columns ####
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

# 16 Subsetting CCs based on market cap and if already hold ####
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

# 17 extract data about which currencies I have and values ####
valuesOfCcsHeld <- 
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

# 18 Subset currencies to only include those I hold ####
currenciesHeld <- 
    valuesOfCcsHeld$fourLetterTicker[
        valuesOfCcsHeld$totalValueInEUR > 0]

# 19 pull market cap cutoff from file ####
marketCapRankCutoff <-
    openxlsx::read.xlsx(
        xlsxFile = myBudgetXlsm,
        sheet = "ccSummarySheet",
        rows = 14 : 15,
        cols = 4
    )[1, 1]

# 20 make list of ccs which have high enough market cap ####
ccsUnderCutoff <- 
    ccsRanked$fourLetterTicker[
        ccsRanked$mcRank <
            marketCapRankCutoff
    ] %>% as.character()

currenciesToGetRatesFor <-
    c(currenciesHeld, ccsUnderCutoff) %>% unique()
