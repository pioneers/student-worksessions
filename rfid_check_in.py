import json
import gspread
from oauth2client.client import SignedJwtAssertionCredentials
import PCprox
import sys
import time
import datetime

import httplib2
import pprint

from apiclient.discovery import build
from decrypt import id_decrypt

#TODO: convert from number to name (and put the name in the worksheet instead)
def enter_info(wks, id_num, time):
	"""Takes an id number and a time stamp and writes them into the first available row in the worksheet wks."""
	row = max(len(wks.col_values(1)), len(wks.col_values(2))) + 1
	wks.update_cell(row, 1, str(id_num))
	wks.update_cell(row, 2, time)

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

if __name__ == "__main__":

	# Authenticate credentials
	json_key = json.load(open('service_acct.json'))
	scope = ['https://spreadsheets.google.com/feeds']
	credentials = SignedJwtAssertionCredentials(json_key['client_email'], json_key['private_key'].encode(), scope)

	print('Fetching user information...')
	sys.stdout.flush()
	http = httplib2.Http()
	http = credentials.authorize(http)

	directory_service = build('admin', 'directory_v1', http=http)

	all_users = []
	page_token = None
	params = {'customer': 'my_customer'}
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
		#print user
		name = user['name']
		if 'organizations' in user:
			try:
				org = user['organizations'][0]
				txt = org['costCenter']
				txt = str(txt)
				#out = name['givenName'] + ','+ name['familyName'] + ',' + leaky_decrypt(txt) + '\n'
				name = name['givenName'] + ' ' + name['familyName']
				ids.update({leaky_decrypt(txt): name})
			except:
				print("error loading " + str(name['givenName']))
				sys.stdout.flush()

	while True:
		print 'Search for an id number:'
		sys.stdout.flush()
		search_num = raw_input()
		if search_num in ids.keys():
			print ids[search_num]
		else:
			print "Didn't find that id..."
		sys.stdout.flush()
		raw_input() # Wait until they hit enter to continue


	exit() # Just want to test the user information part right now
	# Open the worksheet
	gc = gspread.authorize(credentials)
	#TODO: put proper worksheet here
	sign_in_wks = gc.open_by_url("https://docs.google.com/spreadsheets/d/1Jp8IymmVmOIj2L7cNuEoG6Qs_YW7UnofbcvhoqibPqY/edit#gid=0").get_worksheet(0)

	# Initialize the reader
	rdr = PCprox.RFIDReader(PCprox.RFIDReaderUSB())

	print("Ready to scan.")
	sys.stdout.flush()

	while True:
		# Find the raw information on the next card scanned
		hex_id = PCprox.wait_until_card(rdr)

		# Convert the raw information to the 6 numbers on the back of the cal1 card
		dec_id = hex_to_dec(hex_id[9:14])

		# Write the card info to the spreadsheet
		enter_info(sign_in_wks, dec_id, time_stamp())

		# Wait until the card is off the reader before scanning again
		PCprox.wait_until_none(rdr)