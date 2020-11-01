# Purpose: Define functions and parameters for this project
# Author: David Gray Lassiter, PhD
# Date: 2020-Jul-31
# Version: 1.0

# Revisions: Install package "here" if not already installed
# Author: David Gray Lassiter, PhD
# Date: 2020-Aug-16
# Revised Version: 1.1


# 01 Ensure all pkgs in this script are installed ####

# Note, this fxn is also in `../01_myFxnsMltplProjects.r`, but is created
# and called already here in order to ensure that sourcing the `here` function
# works when referring to `../01_myFxnsMltplProjects.r`

installMyPkgs <- function(pkgs) {

    for (pkg in seq_along(pkgs)) {
        if(pkgs[pkg] %in% installed.packages()) {
            break
        } else {
            install.packages(pkg)
        }
    }
}

pkgs <-
    c(
        "here",
        "openxlsx",
        "xml2",
        "rvest",
        "testit",
        "gtools",
        "dplyr")

installMyPkgs(pkgs)

# 02 Initialize wd and source functions not unique to this project ####
setwd(here::here())
source("../01_myFxnsMltplProjects.r")

# 03 Define paths ####
scriptsFolder <- paste0(getwd(), "/05_scripts/")
inputFolder <- paste0(getwd(), "/06_inputs/")
outputFolder <- paste0(getwd(), "/07_outputs/")

# 04 Source inputs ####
myBudgetXlsm <-
    paste0(inputFolder, "i01_budgetTracker2020.xlsm")

ccTickerLookupTable <-
    paste0(inputFolder, "i02_dailyCcTickerLookupTable.xlsx")

# 05 Prep output file and object ####
outputFileName <-
    paste0("03_scrapedDaily.xlsx")

myXlsx <- paste0(outputFolder, outputFileName)

myWb <- openxlsx::createWorkbook(myXlsx)

# 06 Source scripts function ####
sourceScriptFromFolder <- function(script) {
    cat("Sourcing: ", script, "\n\n")
    source(paste0(scriptsFolder, "/", script))
}

# 07 Scraper functions ####
scrapeMorningstarDotSe <- function(url) {
    url %>%
        xml2::read_html(.) %>%
        rvest::html_nodes("#overviewQuickstatsDiv tr:nth-child(2) .text") %>%
        rvest::html_text(.) %>%
        gsub("SEK|EUR|USD|\\s", "", .) %>%
        gsub(",", ".", .) %>%
        as.numeric()
}

scrapeMorningstarDotCom <- function(url) {
    if (!exists("rd", envir = .GlobalEnv)) {
        startRd(headless = T)
    }
    cat("Navigating to:", url, "\n")
    rd$client$navigate(url)
    # rd$client$refresh()
    # cat("Sleeping for 5 seconds before scraping.\n")
    # Sys.sleep(5)
    h <- rd$client$getPageSource()
    price <-
        h[[1]] %>%
        xml2::read_html(.) %>%
        rvest::html_nodes("#message-box-price") %>%
        rvest::html_text(.) %>%
        .[1] %>%
        gsub(" ", "", .) %>%
        gsub(",", ".", .) %>%
        gsub("SEK", "", .) %>%
        gsub("\n", "", .) %>%
        gsub("\\$", "", .) %>%
        as.numeric()

    price
}

scrapePnsnsmyndighetenDotSe <- function(url) {
    ifelse({
            url %>%
                xml2::read_html(.) %>%
                rvest::html_nodes(
                    ".ft_fund-content:nth-child(9) td+ td .s_font-small"
                ) %>%
                rvest::html_text(.) %>%
                identical(., character(0))
        }, {
            url %>%
                xml2::read_html(.) %>%
                rvest::html_nodes(
                    ".ft_fund-content:nth-child(8) td+ td .s_font-small"
                ) %>%
                rvest::html_text(.) %>%
                gsub("SEK|EUR|USD|\\s", "", .) %>%
                gsub(",", ".", .) %>%
                as.numeric()
        }, {
            url %>%
                xml2::read_html(.) %>%
                rvest::html_nodes(
                    ".ft_fund-content:nth-child(9) td+ td .s_font-small"
                ) %>%
                rvest::html_text(.) %>%
                gsub("SEK|EUR|USD|\\s", "", .) %>%
                gsub(",", ".", .) %>%
                as.numeric()
        }
    )
}

scrapeLansforsakringarDotSe <- function(url) {
    if (!exists("rd", envir = .GlobalEnv)) {
        startRd(headless = T)
    }

    rd$client$navigate(url)

    cat("Initiating up to 10 tries to load dynamic page for scraping.\n\n")

    tryWaitRetry({
        rd$client$getPageSource()[[1]] %>% # converts page to html from js
            xml2::read_html(.) %>% # reads the html
            rvest::html_nodes(".break-word-xs-down+ .unset-wrap-xs-down") %>%
            rvest::html_text(.) %>%
            .[[1]] %>%
            gsub(",", ".", .) %>%
            as.numeric() ->
        price
    })

    price
}

scrapeMultiple <- function(df, sitesToScrape, scraperFunction) {
    for (i in seq_along(sitesToScrape)) {
        tries <- 1
        while (tries <= 10) {
            cat(paste0(
                i,
                " of ",
                length(sitesToScrape),
                " pairs: try ",
                tries,
                ".\n\n"
            ))
            if (testit::has_error(
                scraperFunction(sitesToScrape[i])
            )) {
                Sys.sleep(20)
                tries <- tries + 1
            }
            else {
                df[["price"]][i] <-
                    scraperFunction(sitesToScrape[i])
                tries <- 11
            }
        }
        rm(tries)
    }

    if (!exists("rd", envir = .GlobalEnv)) {
        stopRd()
    }

    return(df)
}

# 08 Other functions ####

tryWaitRetry <-
    function(expr, maxTries = 10) {
        for (try in 1:maxTries) {
            results <- try(expr = expr, silent = TRUE)
            if (inherits(results, "try-error")) {
                wait <- runif(n = 1, min = 0, max = 2 ^ (try - 1))
                wait %<>% round(., 1)
                message("Try ", try, " failed. Waiting for ", wait, " seconds.")
                Sys.sleep(wait)
            } else {
                break
            }
        }
        if (try == maxTries & inherits(results, "try-error")) {
            results <- NULL
        }
        results
    }

intraExcArbPaths2Interm <-
    function(listOfCurrenciesInExchange,
             currenciesOnSellingSide,
             currenciesOnBuyingSide) {
        listOfCurrencies <-
            listOfCurrenciesInExchange %>%
            as.character() %>%
            sort()

        listOfPaths <-
            paste0(
                currenciesOnSellingSide,
                currenciesOnBuyingSide
            )

        # start by making all possible permutations
        paths <-
            gtools::permutations(
                length(listOfCurrencies),
                3,
                listOfCurrencies
            ) %>%
            as.data.frame()

        # add all possible pairs in one direction
        paths[, 4] <- paste0(paths[, 1], paths[, 2])
        paths[, 5] <- paste0(paths[, 2], paths[, 3])
        paths[, 6] <- paste0(paths[, 3], paths[, 1])

        # add all possible pairs in other direction
        paths[, 7] <- paste0(paths[, 2], paths[, 1])
        paths[, 8] <- paste0(paths[, 3], paths[, 2])
        paths[, 9] <- paste0(paths[, 1], paths[, 3])

        # Mark paths with NA where a path is not possible
        # since the currencies are not paired.
        paths[, 10] <-
            ifelse(paths[, 4] %in% listOfPaths,
                paths[, 4],
                ifelse(paths[, 7] %in% listOfPaths,
                    paths[, 7],
                    NA
                )
            )

        paths[, 11] <-
            ifelse(paths[, 5] %in% listOfPaths,
                paths[, 5],
                ifelse(paths[, 8] %in% listOfPaths,
                    paths[, 8],
                    NA
                )
            )
        paths[, 12] <-
            ifelse(paths[, 6] %in% listOfPaths,
                paths[, 6],
                ifelse(paths[, 9] %in% listOfPaths,
                    paths[, 9],
                    NA
                )
            )

        # only keep the currency lists for potential paths
        paths %<>%
            .[complete.cases(.), ] %>%
            .[, 1:3] %>%
            dplyr::rename(
                originalCurrency = V1,
                intermediateCurrencyA = V2,
                intermediateCurrencyB = V3
            )

        paths
    }

saveAndAppendToTestDf <- function(df) {

    # Preparing to save
    dataAsString <- deparse(substitute(df))

    # Saving to workbook
    openxlsx::addWorksheet(myWb, dataAsString)
    openxlsx::writeData(myWb, dataAsString, df)

    # Appending to df for final QC

    df[["Source"]] <- dataAsString

    if (exists("allAssetsDf")) {
        allAssetsDf <<-
            rbind(
                allAssetsDf,
                df
            )
    } else {
        allAssetsDf <<- df
    }
}