# Author: 
# Updated:
# Usage:
# Cautions:

# I-O with the user using the `form`
form What you want to do with this script
comment Where are the files?
sentence path C:/files/
comment What other string variables you need?
sentence stringVariable X
comment What number variables you need?
integer numVariable 1
endform

# path normalization
if right$(path$) <> "/"
		path$ = path$ + "/"
endif

# usual variables
extension$ = ".wav"

# access the files/directories using `Strings`
Create Strings as file list: "fileList", path$ + "*" + extension$
selectObject: "Strings fileList"
stringNum = Get number of strings

# the for loop
for i from 1 to stringNum
	selectObject: "Strings fileList"
	fileName$ = Get string: i
	baseName$ = fileName$ - extension$
	@procedure: baseName$
endfor

procedure procedureName: .baseName$, .otherVariables$
	# something to do
endproc