import json
import gspread
from oauth2client.client import SignedJwtAssertionCredentials
import PCprox
import sys
import time
import datetime
import httplib2
from apiclient.discovery import build
from apiclient import discovery
import oauth2client
from oauth2client import client
from oauth2client import tools

CLIENT_SECRETS_FILE = 'client_secrets.json'
SCOPES = [
  'https://spreadsheets.google.com/feeds'
]

flags = tools.argparser.parse_args()
storage = oauth2client.file.Storage('storage.json')

flow = client.flow_from_clientsecrets(
CLIENT_SECRETS_FILE,
scope=SCOPES,
redirect_uri='urn:ietf:wg:oauth:2.0:oob')

credentials = tools.run_flow(flow, storage, flags)

http = credentials.authorize(httplib2.Http())