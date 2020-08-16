# Purpose: Run all of the underlying scripts as necessary
# Author: David Gray Lassiter, PhD
# Date: 2020-Jul-31
# Version: 1.0

# Revisions: Backup files being made correctly now
# Author: David Gray Lassiter, PhD
# Date: 2020-Aug-16
# Revised Version: 1.2

# Suggested revisions:
# Packages that keep needing to be re-installed: reticulate, binman, testit,
# netstat, dplyr, gtools, RSelenium, rvest. Check .libPaths() path to see if
# they exist there. If not, try opening up an issue on Stack Overflow. Perhaps
# it is just that VS Code doesn't install them right, but R Studio does???
# Could add function that installs package if not installed although it doesn't
# source it. Then it may be robust enough regardless of where the path is (in
# case it is diff between RStudio and VS Code)

# 01 Source all my functions ####
source("04_my_fxns_this_project.r")

# 02 Backup former scraped data ####
source_script_from_folder("s01_backup.r")

# 03 Prioritize which cryptocurrencies to evaluate and trade ####
source_script_from_folder("s02_cc_prioritizer.r")

# 04 Getting exchange rate data for fiat pairs ####
source_script_from_folder("s05_fiat_rates.r")

# 05 Scraping data from Kraken ####
source_script_from_folder("s06_kraken.r")

# 06 Scraping data for Robinhood ####
source_script_from_folder("s07_robinhood.r")

# 07 Scraping data for Handelsbanken ISK ####
source_script_from_folder("s08_hisk.r")

# 08 Scraping data for Handelsbanken Pension ####
source_script_from_folder("s09_hpension.r")

# 09 Scraping data for SPP Pension ####
source_script_from_folder("s10_spppension.r")

# 10 Scraping data for Premiepension ####
source_script_from_folder("s11_premiepension.r")

# 11 Scraping data for Länsförsäkringar ####
source_script_from_folder("s12_lansforsakringar.r")

# 12 Final save ####
openxlsx::saveWorkbook(my_wb, my_xlsx, overwrite = T)

# 13 Final QC test to see if all data scraped ####
all_assets_df %<>% .[, c("Source", "fonds", "price")]

if (all_assets_df[["price"]] %>% is.na %>% any) {
    print("OBS! Not all data scraped! Observe:")
    all_assets_df
} else {
    print("All data apparently scraped. Nice job!")
}

# 14 Put machine to sleep ####
shell(cmd = "rundll32.exe powrprof.dll,SetSuspendState 0,1,0")