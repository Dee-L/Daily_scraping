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

backups_to_keep <- 3

make_backup_file_name <- function(day) {
    paste0(output_folder, "01_backup_", day, output_file_name)
}

todays_file <- make_backup_file_name(today)

file_to_remove <- make_backup_file_name(today - backups_to_keep)

# 02 Make backup and delete aged-out backup ####
file.copy(
    from = my_xlsx,
    to = todays_file,
    overwrite = T
)

file.remove(file_to_remove)