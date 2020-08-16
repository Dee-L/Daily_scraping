# Purpose: Scraping data for SPP Pension
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
        "magrittr"
    )

install_my_pkgs(pkgs)

# 02 Preparing to scrape ####

spppension <-
    data.frame(
        fonds = c(
            "SEB Likviditetsfond SEK",
            "SPP Aktiefond USA",
            "SPP Sverige Plus A",
            "SPP Europa Plus A"
        ),
        price = c(rep(NA, 4))
    )

url_prefix <- "https://www.morningstar.se/se/funds/snapshot/snapshot.aspx?id="

spppension_ids <-
    c(
        "F0GBR04M5F",
        "F0GBR04FXR",
        "F00000XPDF",
        "F00001064H"
    )

spppension_sites_to_scrape <-
    paste0(url_prefix, spppension_ids)

# 03 Scraping ####

spppension magrittr::`%<>%`
    scrape_multiple(spppension_sites_to_scrape, scrape_morningstar_dot_se)

# 04 Saving and append for QC ####

save_and_append_to_test_df(spppension)