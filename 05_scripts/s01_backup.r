# Purpose: Backup former scraped data
# Author: David Gray Lassiter, PhD
# Date: 2020-Jul-31
# Version: 1.0

# Revisions:
# Author:
# Date: YYYY-MMM-DD
# Revised Version:

file.copy(
    from = my_xlsx,
    to = paste0(output_folder, "01_backup_", output_file_name), overwrite = T
)