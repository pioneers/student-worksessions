import json
import gspread
from oauth2client.client import SignedJwtAssertionCredentials
import PCprox
import sys
import time
import datetime

import httplib2
from httplib import BadStatusLine
from socket import error as socket_error
import pprint

from apiclient.discovery import build
from decrypt import id_decrypt
 
from apiclient import discovery
import oauth2client
from oauth2client import client
from oauth2client import tools

#TODO: put proper worksheet here
WKS_URL = "https://docs.google.com/spreadsheets/d/1cRMzpYBRWyERmE_bfsM7Vu_2u3uBLzXUHlWkVhBNgZ0/edit#gid=0"

def enter_info(wks, name, time):
	"""Takes a name and a time stamp and writes them into the first available row in worksheet wks.
	If no row is available, will add an extra row."""
	try:
		row = max(len(wks.col_values(1)), len(wks.col_values(2))) + 1
		if wks.row_count < row:
			wks.add_rows(1)
		wks.update_cell(row, 1, name)
		wks.update_cell(row, 2, time)
	except (socket_error, BadStatusLine):
		print("Lost connection to file.  Reconnecting...")
		sys.stdout.flush()
		signal_failure(rdr)
		gc = gspread.authorize(credentials)
		# TODO: Find a better way to do this?
		global sign_in_wks
		sign_in_wks = gc.open_by_url(WKS_URL).get_worksheet(0)
		print("Please try scanning again.")
		sys.stdout.flush()

def time_stamp():
    """Returns the current time in the form year-month-day hour:minute:second"""
    return datetime.datetime.fromtimestamp(time.time()).strftime('%Y-%m-%d %H:%M:%S')

def hex_to_dec(hex_num):
    """Takes a hexadecimal number (in the form of a string) and returns the decimal integer corresponding to it."""
    hd_dict = {'0':0, '1':1, '2':2, '3':3, '4':4, '5':5, '6':6, '7':7, '8':8, '9':9, 'a':10, 'b':11, 'c':12, 'd':13, 'e':14, 'f':15}
    hex_num = hex_num[::-1]
    dec_num = 0
    for i in range(len(hex_num)):
        dec_num += hd_dict[hex_num[i]] * pow(16, i)
    return dec_num

def signal_failure(rdr):
	"""Signals that the scan failed by flashing the light amber and beeping."""
	rdr.set_led_state(True, True) # flash the light yellow
	rdr.beep(3)
	rdr.set_led_auto()

if __name__ == "__main__":

	# Authenticate credentials
	"""json_key = json.load(open('service_acct.json'))
	scope = ['https://spreadsheets.google.com/feeds', 'https://www.googleapis.com/auth/admin.directory.user.readonly']
	credentials = SignedJwtAssertionCredentials(json_key['client_email'], json_key['private_key'].encode(), scope)"""
	CLIENT_SECRETS_FILE = 'client_secrets.json'
	SCOPES = [
	  'https://spreadsheets.google.com/feeds', 'https://www.googleapis.com/auth/admin.directory.user.readonly'
	]
 
	flags = tools.argparser.parse_args()
	storage = oauth2client.file.Storage('storage.json')

	flow = client.flow_from_clientsecrets(
    CLIENT_SECRETS_FILE,
    scope=SCOPES,
    redirect_uri='urn:ietf:wg:oauth:2.0:oob')

	credentials = tools.run_flow(flow, storage, flags)

	http = credentials.authorize(httplib2.Http())

	print('Fetching user information...')
	sys.stdout.flush()
	#http = httplib2.Http()
	#http = credentials.authorize(http)

	directory_service = build('admin', 'directory_v1', http=http)

	all_users = []
	page_token = None
	params = {'customer': 'C03oalt22'}
	ids = {}

	while True:
		try:
			if page_token:
				params['pageToken'] = page_token
			current_page = directory_service.users().list(**params).execute()

			all_users.extend(current_page['users'])
			page_token = current_page.get('nextPageToken')
			if not page_token:
				break
	  	#except errors.HttpError as error:
		except Exception as error:
			print 'An error occurred: %s' % error
			sys.stdout.flush()
			break
	for user in all_users:
		name = user['name']
		if 'organizations' in user:
			try:
				org = user['organizations'][0]
				txt = org['costCenter']
				txt = str(txt)
				full_name = name['givenName'] + ' ' + name['familyName']
				ids.update({id_decrypt(txt): full_name})
			except:
				print("error loading " + name['givenName'] + ' ' + name['familyName'])
				sys.stdout.flush()


	# Open the worksheet
	gc = gspread.authorize(credentials)
	sign_in_wks = gc.open_by_url(WKS_URL).get_worksheet(0)

	# Initialize the reader
	rdr = PCprox.RFIDReader(PCprox.RFIDReaderUSB())

	while True:
		print("\n\nReady to scan.")
		sys.stdout.flush()

		# Find the raw information on the next card scanned
		hex_id = PCprox.wait_until_card(rdr)

		# Convert the raw information to the 6 numbers on the back of the cal1 card
		dec_id = hex_to_dec(hex_id[9:14])

		try:
			name = ids[str(dec_id)]
			print "Welcome, " + name
			sys.stdout.flush()
			enter_info(sign_in_wks, name, time_stamp())
		except KeyError:
			print "Card number not found..."
			sys.stdout.flush()
			signal_failure(rdr)
			time.sleep(.5)

		# Wait until the card is off the reader before scanning again
		PCprox.wait_until_none(rdr)