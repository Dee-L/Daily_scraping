# Purpose: Prioritize which cryptocurrencies to evaluate and trade
# Author: David Gray Lassiter, PhD
# Date: 2020-Aug-01
# Version: 1.0

# Revisions:
# Author:
# Date: YYYY-MMM-DD
# Revised Version:

# 01 Create df for looking up cc values ####
cmc_ccs <-
    openxlsx::read.xlsx(cc_ticker_lookup_table, sheet = "CoinMarketCap")

# 02 Scrape today's values via Python and cleanup the environment after. ####

# This is currently throwing an error since there is something,
# but it saves a csv in the 'outputs' file which can be used.
# If "ModuleNotFound" errors thrown, can use py_install('<name of module>').
# I believe this installs the modules in the miniconda/R installation.
# This may mean that you have python installed in two different places on your
# machine.

# Source python to do the job
reticulate::source_python("05_scripts/s03_cmc_scraper.py")

# Retrieve the output from the python job
cmc_data <- read.csv("07_outputs/02_cmc_data.csv")

# Cleanup memory
rm(r, ConnectionError, R, Request, Session, Timeout, TooManyRedirects)

# Remove cache
unlink(paste0(scripts_folder, "__pycache__"), recursive = TRUE)

# 02 If scraping fails ####

# If the python script doesn't work, use the former ranks for the ccs.

tryCatch({
        ccs_ranked <<-
            # match the scraped data
            cmc_data[["name"]] %>%
            match(
                x = .,
                cmc_ccs$CoinMarketCap_Name_For_Python_Matching) %>%
            # Extracts my tickers
            cmc_ccs$CoinMarketCap_Ticker[.] %>%
            # Converts to Tickers
            {
                iterator <- length(.)
                data.frame(
                    MC_rank = seq_len(iterator),
                    CoinMarketCap_Ticker = .,
                    row.names = NULL)
            } %>%
            # drop ccs I don't collect
            .[!(is.na(.$CoinMarketCap_Ticker)), ] %>%
            # bring in four_letter_ticker
            merge(., y = cmc_ccs) %>%
            # sorts df
            .[order(.$MC_rank), ] %>%
            # add CC_priority_column
            {
                iterator <- nrow(.)
                data.frame(.,
                    CC_priority = seq_len(iterator),
                    row.names = NULL)
            } %>%
            # keep only necessary columns
            .[, c(
                "CC_priority",
                "MC_rank",
                "four_letter_ticker")]
    },
    error = function(e) {
        cat("Error: ", e$message, "\n")
        ccs_ranked <<-
            openxlsx::readWorkbook(
                "07_outputs/03_scraped_daily.xlsx",
                "CCs_ranked")
    }
)

openxlsx::addWorksheet(my_wb, "CCs_ranked")

openxlsx::writeData(my_wb, "CCs_ranked", ccs_ranked)

# 03 Subsetting CCs based on market cap and if already hold ####

number_of_tickers <-
    openxlsx::read.xlsx(
        xlsxFile = my_budget_xlsm,
        sheet = "CC_summary_sheet",
        rows = 22:23,
        cols = 2
    )[1, 1]

start_row_for_cc_summary <-
    openxlsx::read.xlsx(
        xlsxFile = my_budget_xlsm,
        sheet = "CC_summary_sheet",
        rows = 22:23,
        cols = 3
    )[1, 1]

end_row_for_cc_summary <-
    start_row_for_cc_summary + number_of_tickers

values_of_ccs_held <- # extract data about which currencies I have and values
    cbind(
        openxlsx::read.xlsx(
            xlsxFile = my_budget_xlsm,
            sheet = "CC_summary_sheet",
            rows = start_row_for_cc_summary:end_row_for_cc_summary,
            cols = 1
        ),
        openxlsx::read.xlsx(
            xlsxFile = my_budget_xlsm,
            sheet = "CC_summary_sheet",
            rows = start_row_for_cc_summary:end_row_for_cc_summary,
            cols = 6
        )
    )

currencies_held <- # subset currencies to only include those I hold
    values_of_ccs_held$four_letter_ticker[
        values_of_ccs_held$Total_value_in_EUR > 0]

market_cap_rank_cutoff <- # pull market cap cutoff from file
    openxlsx::read.xlsx(
        xlsxFile = my_budget_xlsm,
        sheet = "CC_summary_sheet",
        rows = 14:15,
        cols = 4
    )[1, 1]

ccs_under_cutoff <- # make list of ccs which have high enough market cap
    ccs_ranked$four_letter_ticker[
        ccs_ranked$MC_rank <
            market_cap_rank_cutoff
    ] %>% as.character()

currencies_to_get_rates_for <-
    c(currencies_held, ccs_under_cutoff) %>% unique()