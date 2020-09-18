# Purpose: Scraping data for Premiepension
# Author: David Gray Lassiter, PhD
# Date: 2020-Aug-01
# Version: 1.0

# Revisions: Reverting since no packages to install
# Author: David Gray Lassiter, PhD
# Date: 2020-Aug-17
# Revised Version: 1.2

# 01 Preparing to scrape ####

fonds <- c(
    "Skandia Time Global",
    "Seligson & Co Global Top 25 Pharmaceuticals A",
    "Lannebo Likviditetsfond",
    "CB Save Earth Fund RC",
    "Swedbank Robur Fastighet A"
)

premiepension <-
    data.frame(
        fonds,
        price = c(rep(NA, length(fonds)))
    )

url_prefix <- "https://www.pensionsmyndigheten.se/service/fondtorg/fond/"

premiepension_ids <-
    c(
        "439471",
        "416982",
        "478313",
        "976506",
        "968420"
    )

premiepension_sites_to_scrape <-
    paste0(url_prefix, premiepension_ids)

# 02 Scraping ####

premiepension %<>%
    scrape_multiple(premiepension_sites_to_scrape,
    scrape_pnsnsmyndigheten_dot_se)

# 03 Saving and append for QC ####

save_and_append_to_test_df(premiepension)