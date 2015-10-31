import json
import gspread
from oauth2client.client import SignedJwtAssertionCredentials
import PCprox
import sys
import time
import datetime

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
	json_key = json.load(open('check_in.json'))
	scope = ['https://spreadsheets.google.com/feeds']
	credentials = SignedJwtAssertionCredentials(json_key['client_email'], json_key['private_key'].encode(), scope)

	# Open the worksheet
	gc = gspread.authorize(credentials)
	#TODO: put proper worksheet here
	test_wks = gc.open("gspread test").sheet1

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
		enter_info(test_wks, dec_id, time_stamp())

		# Wait until the card is off the reader before scanning again
		PCprox.wait_until_none(rdr)