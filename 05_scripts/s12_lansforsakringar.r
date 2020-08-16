# Purpose: Scraping data for Länsförsäkringar
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
        ""
    )

install_my_pkgs(pkgs)

# 02 Preparing to scrape ####

lansforsakringar <-
    data.frame(
        fonds = c(
            "BlackRock Sustainable Energy",
            "Fidelity Global Technology",
            "JPM Global Healthcare",
            "SEB Green Bond Fund"
        ),
        price = c(rep(NA, 4))
    )

url_prefix <-
    paste0(
        "https://www.lansforsakringar.se/stockholm/privat/bank/spara/",
        "fondkurser/jamfor-fonder/?term=jpm%20global&universeId=ALL_5085&ids=")

lansforsakringar_ids <-
    c(
        "F0GBR04KF3",
        "F00000T2AE",
        "F00000454U",
        "F00000VFU9"
    )

lansforsakringar_sites <-
    paste0(url_prefix, lansforsakringar_ids)

# 03 Scraping ####

lansforsakringar %<>%
    scrape_multiple(lansforsakringar_sites, scrape_lansforsakringar_dot_se)

# 04 Saving and append for QC ####

save_and_append_to_test_df(lansforsakringar)