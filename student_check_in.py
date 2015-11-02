import json
import gspread
from oauth2client.client import SignedJwtAssertionCredentials
import PCprox
import sys

class Student():
	"""Stores the row number of a student, allows for lookups of information."""
	def __init__(self, wks, row):
		self.wks = wks
		self.row = row

	def school(self):
		return self.wks.cell(self.row, 1).value
	def last(self):
		return self.wks.cell(self.row, 2).value
	def first(self):
		return self.wks.cell(self.row, 3).value
	def QR(self):
		return self.wks.cell(self.row, 4).value
	def RFID(self):
		return self.wks.cell(self.row, 5).value
	def ecf(self):
		return self.wks.cell(self.row, 6).value
	def lf(self):
		return self.wks.cell(self.row, 7).value
	def value(self, col):
		"""Returns the value for student in column col, ignoring what it means."""
		return self.wks.cell(self.row, col).value

def user_input(prompt = None):
	"""Prints out the string prompt, then returns what the user enters.
	If the prompt is None, won't print anything."""
	if prompt != None:
		print(prompt)
		sys.stdout.flush()
	return raw_input()

def num_rows():
	"""Returns the number of filled in rows."""
	return max([len(student_wks.col_values(n)) for n in range(1, 8)])

def pause():
	"""Waits for the user to hit return, then continues."""
	cont = user_input("Hit return to continue.")

def fill_string(s, n):
	"""If s has fewer than n characters, returns s followed by enough whitespace to make s have n characters.
	If s has n characters, returns s.
	If s has more than n characters, returns s trimmed to n characters."""
	if len(s) < n:
		return s + (' ' * (n - (len(s))))
	if len(s) == n:
		return s[:] # Makes sure that the function will always return a new object
	return s[:n]

def add_student():
	"""Manually adds a student with information from user input."""
	print("Enter the requested information, or ? if unknown.")
	pause()
	school = user_input("School?")
	last = user_input("Last name?")
	first = user_input("First name?")
	ecf = (user_input("Has Emergency Contact Form? (Y/N)") == 'Y')
	lf = (user_input("Has Liability Form? (Y/N)") == 'Y')
	id_scan = (user_input("Do you want to register their id? (Y/N)") == 'Y')
	if id_scan:
		PCprox.wait_until_none(rdr) # Make sure there isn't currently a card on the reader
		print("Scan id now.")
		sys.stdout.flush()
		id_num = PCprox.wait_until_card(rdr)
	else:
		id_num = '?' # Unknown
	print("Adding student...")
	sys.stdout.flush()
	row = num_rows() + 1
	student_wks.update_cell(row, 1, school)
	student_wks.update_cell(row, 2, last)
	student_wks.update_cell(row, 3, first)
	student_wks.update_cell(row, 4, '?') # Don't know the QR code on their card  TODO: Fix this?
	student_wks.update_cell(row, 5, id_num)
	if ecf:
		student_wks.update_cell(row, 6, '?') # This means that they say they have it turned in, but it hasn't been confirmed by PiE staff
	else:
		student_wks.update_cell(row, 6, 'N')
	if lf:
		student_wks.update_cell(row, 7, '?') # This means that they say they have it turned in, but it hasn't been confirmed by PiE staff
	else:
		student_wks.update_cell(row, 7, 'N')
	print("Successfully added student!")
	pause()

def print_students(students):
	"""Takes a list of row numbers corresponding to students and prints out their information."""
	print fill_string("School", 45), fill_string("Last", 25), fill_string("First", 20), fill_string("RFID", 18), "ECF", "LF"
	sys.stdout.flush()
	for student in students:
		s = Student(student_wks, student)
		print fill_string(s.school(), 45), fill_string(s.last(), 25), fill_string(s.first(), 20), fill_string(s.RFID(), 18), fill_string(s.ecf(), 3), fill_string(s.lf(), 2)
		sys.stdout.flush()

def narrow(students):
	"""Takes a list of row numbers corresponding to students, then narrows by criteria defined by user input.
	Prints the narrowed list of students at the end, and gives the option to narrow further."""
	print("Narrow by:")
	print("	(1) School")
	print("	(2) Last Name")
	print("	(3) First Name")
	print("	(4) RFID number")
	print("	(5) Emergency Contact Form status")
	print("	(6) Liability Form status")
	sys.stdout.flush()
	crit = int(user_input())
	if crit >= 4:
		crit += 1 # This makes it match up with the column numbers on the spreadsheet
	#TODO: Deal with the special case of RFID number (use the scanner)
	search = user_input("Search for?")
	print("Searching...")
	sys.stdout.flush()
	new_students = []
	for student in students:
		curr_student = Student(student_wks, student)
		if curr_student.value(crit) == search:
			new_students.append(student)
	if not new_students:
		print("No students found!")
		again = user_input("Try a different search? (Y/N)")
		if again == 'Y':
			narrow(students)
		return
	print("Found " + str(len(new_students)) + " students.")
	p = user_input("Print out the list? (Y/N)")
	if p == 'Y':
		print_students(new_students)
		pause()
	n = user_input("Try another search with the same students? (Y/N)")
	if n == 'Y':
		narrow(students)
		return
	n = user_input("Try another search with the new list of students? (Y/N)")
	if n == 'Y':
		narrow(new_students)

def update_worksheet():
	"""Updates the spreadsheet this program can edit to match the master spreadsheet."""
	print("Fetching student information...")
	sys.stdout.flush()
	master_wks = gc.open("Registration test").get_worksheet(0)
	master_info = [master_wks.col_values(2), master_wks.col_values(4), master_wks.col_values(3), master_wks.col_values(20), master_wks.col_values(21)]
	# Make sure all the lists have the same length (they should, but just to be safe)
	master_len = max([len(lst) for lst in master_info])
	for i in range(len(master_info)):
		if len(master_info[i]) < master_len:
			master_info[i] = master_info[i] + ([''] * (master_len - len(master_info[i])))
	wks_info = [student_wks.col_values(1), student_wks.col_values(2), student_wks.col_values(3), student_wks.col_values(6), student_wks.col_values(7)]
	wks_len = max([len(lst) for lst in wks_info])
	for i in range(len(wks_info)):
		if len(wks_info[i]) < wks_len:
			wks_info[i] = wks_info[i] + ([''] * (wks_len - len(wks_info[i])))
	print("Checking for differences...")
	sys.stdout.flush()
	new_students, changed_students = [], [] # Stores the row numbers (in the master sheet) of students not in the worksheet or who have updated ecf / lf info
	for student in range(3, master_len + 1):
		if master_info[1][student - 1] == 'Example' or not master_info[1][student - 1]:
			continue # This row is either blank or is a school --> don't add it to the list
		for entry in range(2, wks_len + 1):
			if not False in [master_info[i][student - 1] == wks_info[i][entry - 1] for i in [0, 1, 2]]:
				if (master_info[3][student - 1] == 'X' and wks_info[3][entry - 1] != 'Y') or (master_info[4][student - 1] == 'X' and wks_info[4][entry - 1] != 'Y'):
					changed_students.append(student)
				break
		else:
			new_students.append(student)
	if not new_students and not changed_students:
		print("Worksheet is up to date!")
		return
	print("Found " + str(len(new_students)) + " new students and " + str(len(changed_students)) + " students with updated information!")
	if new_students:
		add = user_input("Add the new students found? (Y/N)")
		if add == 'Y':
			row = num_rows() + 1
			for student in new_students:
				student_wks.update_cell(row, 1, master_info[0][student - 1])
				student_wks.update_cell(row, 2, master_info[1][student - 1])
				student_wks.update_cell(row, 3, master_info[2][student - 1])
				student_wks.update_cell(row, 4, '?') # Don't know the QR code on their card.
				student_wks.update_cell(row, 5, '?') # Same for ID number.
				if master_info[3][student - 1] == 'X':
					student_wks.update_cell(row, 6, 'Y')
				else:
					student_wks.update_cell(row, 6, 'N')
				if master_info[4][student - 1] == 'X':
					student_wks.update_cell(row, 7, 'Y')
				else:
					student_wks.update_cell(row, 7, 'N')
				row += 1
	if changed_students:
		update = user_input("Update the changed information? (Y/N)")
		if update == 'Y':
			for student in changed_students:
				for row in range(2, wks_len + 1):
					if not False in [master_info[i][student - 1] == wks_info[i][row - 1] for i in [0, 1, 2]]:
						if master_info[3][student - 1] == 'X':
							student_wks.update_cell(row, 6, 'Y')
						if master_info[4][student - 1] == 'X':
							student_wks.update_cell(row, 7, 'Y')
						break


if __name__ == "__main__":
	# Authenticate credentials
	json_key = json.load(open('service_acct.json'))
	scope = ['https://spreadsheets.google.com/feeds']
	credentials = SignedJwtAssertionCredentials(json_key['client_email'], json_key['private_key'].encode(), scope)

	# Open the worksheet
	gc = gspread.authorize(credentials)
	#TODO: put proper worksheet here
	student_wks = gc.open("gspread test").get_worksheet(1)

	# Initialize the reader
	#rdr = PCprox.RFIDReader(PCprox.RFIDReaderUSB())

	while True:
		command = user_input("Possible commands: Quit, Add Student, Lookup, Print Students, Update")
		print('----------------\n')
		sys.stdout.flush()
		if command == 'Quit':
			exit()
		elif command == 'Add Student':
			add_student()
		elif command == 'Lookup':
			narrow(range(2, num_rows() + 1))
		elif command == 'Print Students':
			print_students(range(2, num_rows() + 1))
			pause()
		elif command == 'Update':
			update_worksheet()
			pause()
		else:
			print("Unrecognized command.")
			pause()
		print('\n\n\n\n----------------') # Make a clear separation
		sys.stdout.flush()