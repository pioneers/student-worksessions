import json
import gspread
from oauth2client.client import SignedJwtAssertionCredentials

# Authenticate credentials
json_key = json.load(open('check_in.json'))
scope = ['https://spreadsheets.google.com/feeds']
credentials = SignedJwtAssertionCredentials(json_key['client_email'], json_key['private_key'].encode(), scope)

# Open the worksheet
gc = gspread.authorize(credentials)
#TODO: put proper worksheet here
test_wks = gc.open("gspread test").sheet1

# Next available row --> where you input the data (row 1 is headers)
row = 2
def next_available_row():
	"""Updates the global row variable to the next open row."""
	nonlocal row
	while test_wks.cell(row, 1).value or test_wks.cell(row, 2).value:
		row += 1

#TODO: convert from number to name (and put the name in the worksheet instead)
def enter_info(id_num, time):
	"""Takes an id number and a time stamp and writes them into the first available row."""
	next_available_row()
	test_wks.update_cell(row, 1, str(id_num))
	test_wks.update_cell(row, 2, time)