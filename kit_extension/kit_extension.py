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

def time_stamp():
    """Returns the current time in the form year-month-day hour:minute:second"""
    return datetime.datetime.fromtimestamp(time.time()).strftime('%Y-%m-%d %H:%M:%S')

def get_student_info(credentials, student_id):
	"""Takes a student id and returns that student's information.
	Params:
		credentials: authorized credentials with access to PiE spreadsheets.
		student_id: a student's id in hex form (as the reader sees it).
	Returns:
		The tuple (School, First Name, Last Name), all strings, if the student id is in the database.
		The tuple (None, None, None) if the student id is not in the database."""
	gc = gspread.authorize(credentials)
	# The next three *must* be updated whenever the database moves or changes
	spreadsheet = gc.open_by_url("https://docs.google.com/spreadsheets/d/1cRMzpYBRWyERmE_bfsM7Vu_2u3uBLzXUHlWkVhBNgZ0/edit")
	database = spreadsheet.worksheet("Students")
	ids = database.col_values(7) # the column where the rfid numbers are stored (1 indexed)
	try:
		student_row = ids.index(student_id) + 1 # +1 because rows are 1 indexed, while lists are 0 indexed
	except ValueError:
		return (None, None, None) # means that student_id is not in ids
	return (database.cell(student_row, 1).value, database.cell(student_row, 3).value, database.cell(student_row, 2).value)


if __name__ == "__main__":
	# get credentials
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

	print("start time: " + time_stamp())
	sys.stdout.flush()
	school, first, last = get_student_info(credentials, "test")
	print(school + " " + first + " " + last)
	print("end time: " + time_stamp())
	sys.stdout.flush()