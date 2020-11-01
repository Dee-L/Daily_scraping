# Purpose: Backup former scraped data
# Author: David Gray Lassiter, PhD
# Date: 2020-Jul-31
# Version: 1.0

# Revisions: Keep more backups and remove them as they age out
# Author: David Gray Lassiter, PhD
# Date: 2020-Aug-12
# Revised Version: 1.1

# 01 Initialize variables ####
today <- Sys.Date()

backupsToKeep <- 3

makeBackupFileName <- function(day) {
    paste0(outputFolder, "01_backup_", day, outputFileName)
}

todaysFile <- makeBackupFileName(today)

fileToRemove <- makeBackupFileName(today - backupsToKeep)

# 02 Make backup and delete aged-out backup ####
file.copy(
    from = myXlsx,
    to = todaysFile,
    overwrite = T
)

file.remove(fileToRemove)