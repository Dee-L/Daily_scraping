# Purpose: Run all of the underlying scripts as necessary
# Author: David Gray Lassiter, PhD
# Date: 2020-Jul-31
# Version: 1.0

# Revisions:
# Author:
# Date: YYYY-MMM-DD
# Revised Version:

# Suggested revisions:
# 01 Create function for sourcing scripts
# that only takes a string as an argument
# 02 Create a function for saving the dfs to excel and adding them to
# all_assets_df that only takes the name of the df as an argument.
# Alternative to the above, make the dfs a special class that have that function
# as a method/proc/subroutine that can be called on them directly in order
# to start getting used to creating/using my own classes.
# 03 Change calls to input to use prefix "i01_<file>" and "i02_<file>" similar
# to as I've done for "s01_<file>" when sourcing scripts.

# 01 Source all my functions ####
source("04_my_fxns_this_project.r")

# 02 Backup former scraped data ####
source(paste0(scripts_folder, "/s01_backup.r"))

# 03 Prioritize which cryptocurrencies to evaluate and trade ####
source(paste0(scripts_folder, "/s02_cc_prioritizer.r"))

# 04 Getting exchange rate data for fiat pairs ####
source(paste0(scripts_folder, "/s05_fiat_rates.r"))

# 05 Scraping data from Kraken ####
source(paste0(scripts_folder, "/s06_kraken.r"))

# 06 Scraping data for Robinhood ####
source(paste0(scripts_folder, "/s07_robinhood.r"))

# 07 Scraping data for Handelsbanken ISK ####
source(paste0(scripts_folder, "/s08_hisk.r"))

# 08 Scraping data for Handelsbanken Pension ####
source(paste0(scripts_folder, "/s09_hpension.r"))

# 09 Scraping data for SPP Pension ####
source(paste0(scripts_folder, "/s10_spppension.r"))

# 10 Scraping data for Premiepension ####
source(paste0(scripts_folder, "/s11_premiepension.r"))

# 11 Scraping data for Länsförsäkringar ####
source(paste0(scripts_folder, "/s12_lansforsakringar.r"))

# 12 Final save ####
openxlsx::saveWorkbook(my_wb, my_xlsx, overwrite = T)

# 13 Final test to see if all data scraped ####
all_assets_df %<>% .[, c("Source", "fonds", "price")]

if (all_assets_df[["price"]] %>% is.na %>% any) {
    print("OBS! Not all data scraped! Observe:")
    all_assets_df
} else {
    print("All data apparently scraped. Nice job!")
}

# 14 Put machine to sleep ####
shell(cmd = "rundll32.exe powrprof.dll,SetSuspendState 0,1,0")