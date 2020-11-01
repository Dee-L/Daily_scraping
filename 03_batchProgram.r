# Purpose: Run all of the underlying scripts as necessary
# Author: David Gray Lassiter, PhD
# Date: 2020-Jul-31
# Version: 1.0

# Revisions: Revert to piping syntax
# Author: David Gray Lassiter, PhD
# Date: 2020-Aug-16
# Revised Version: 1.4

# Suggested revisions:

# 01 Source all my functions ####
source("04_myFxnsThisProject.r")

# 02 Ensure all pkgs in this scripts are installed ####
pkgs <-
    c(
        "openxlsx")

installMyPkgs(pkgs)

# 03 Backup former scraped data ####
sourceScriptFromFolder("s01_backup.r")

# 04 Prioritize which cryptocurrencies to evaluate and trade ####
sourceScriptFromFolder("s02_ccPrioritizer.r")

# 05 Getting exchange rate data for fiat pairs ####
sourceScriptFromFolder("s05_fiatRates.r")

# 06 Scraping data from Kraken ####
sourceScriptFromFolder("s06_kraken.r")

# 07 Scraping data for Robinhood ####
# Stopped scraping these since stopped investing in Robinhood
# sourceScriptFromFolder("s07_robinhood.r")

# 08 Scraping data for Handelsbanken ISK ####
sourceScriptFromFolder("s08_hisk.r")

# 09 Scraping data for Handelsbanken Pension ####
sourceScriptFromFolder("s09_hpension.r")

# 10 Scraping data for SPP Pension ####
sourceScriptFromFolder("s10_spppension.r")

# 11 Scraping data for Premiepension ####
# Stopped scraping these since they stopped listing prices on their
# site and I have not found a better alternative site yet.
sourceScriptFromFolder("s11_premiepension.r")

# 12 Scraping data for Länsförsäkringar ####
sourceScriptFromFolder("s12_lansforsakringar.r")

# 13 Final save ####
openxlsx::saveWorkbook(myWb, myXlsx, overwrite = T)

# 14 Final QC test to see if all data scraped ####
allAssetsDf %<>% .[, c("Source", "fonds", "price")]

if (allAssetsDf[["price"]] %>% is.na %>% any) {
    print("OBS! Not all data scraped! Observe:")
    allAssetsDf
} else {
    print("All data apparently scraped. Nice job!")
}

# 15 Put machine to sleep ####
shell(cmd = "rundll32.exe powrprof.dll,SetSuspendState 0,1,0")