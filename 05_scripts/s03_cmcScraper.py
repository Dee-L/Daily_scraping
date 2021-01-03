# Purpose: Scrape Coin Market Cap data
# Author: David Gray Lassiter, PhD

# API documentation: https://coinmarketcap.com/api/documentation/v1/#section/Quick-Start-Guide

# Getting the path for the project and doing string manipulation.
import os
import re
workingDir = re.sub("\\\\", "/", os.getcwd())

# Specifying the scripts and output paths
scriptsDir = workingDir + "/05_scripts"
outputsDir = workingDir + "/07_outputs"

# Importing credentials
import site
site.addsitedir(scriptsDir)
from s04_cmcCredentials import *

# Preparing to scrape via the CMC API
url = 'https://pro-api.coinmarketcap.com/v1/cryptocurrency/listings/latest'
parameters = {
    'start': '1',
    'limit': '5000',
    'convert': 'USD'
}

headers = {
    'Accepts': 'application/json',
    myKey: myValue,
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
cmcData = json.loads(response.text)
cmcData = cmcData['data']

import pandas as pd
cmcData = pd.json_normalize(cmcData)
cmcData.to_csv(outputsDir + "/02_cmcData.csv")

# Clean up unneeded objects
del(url, parameters, headers, session, response)
