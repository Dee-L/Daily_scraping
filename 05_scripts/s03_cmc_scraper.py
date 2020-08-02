# Purpose: Scrape Coin Market Cap data
# Author: David Gray Lassiter, PhD
# Date: 2020-Jul-31
# Version: 1.0

# Requested revision: Drop _ prefixes from this file and _04_CMC_credentials.
# This will change how they are sourced since Python does not accept
# object names (including packages) to start with digits.

# Revisions:
# Author:
# Date: YYYY-MMM-DD
# Revised Version:

# Getting the path for the project and doing string manipulation.
import os
import re
working_dir = re.sub("\\\\", "/", os.getcwd())

# Specifying the scripts and output paths
scripts_dir = working_dir + "/05_scripts"
outputs_dir = working_dir + "/07_outputs"

# Importing credentials
import site
site.addsitedir(scripts_dir)
from s04_cmc_credentials import *

# Preparing to scrape via the CMC API
url = 'https://pro-api.coinmarketcap.com/v1/cryptocurrency/listings/latest'
parameters = {
    'start': '1',
    'limit': '5000',
    'convert': 'USD'
}

headers = {
    'Accepts': 'application/json',
    my_key: my_value,
}

# Scraping via the CMC API
from requests import Request, Session
from requests.exceptions import ConnectionError, Timeout, TooManyRedirects
session = Session()
session.headers.update(headers)

response = session.get(url, params=parameters)

session.close()

# Formatting the data and saving it
import json
CMC_data = json.loads(response.text)
CMC_data = CMC_data['data']

import pandas as pd
CMC_data = pd.json_normalize(CMC_data)
CMC_data.to_csv(outputs_dir + "/02_CMC_data.csv")

# Clean up unneeded objects
del(url, parameters, headers, session, response)
