# Author: Chunyu Ge 葛淳宇
# Updated: 2019-12-06
# Usage: Annotate sound files with specified tiers  
#        and save the TextGrid files in the same directory
# Cautions: - Use forward slash "/" instead of backward slash "\" in the path;
#           - If a TextGrid file is already present, the file is opened.

form Information
	comment Where are the sound files to annotate? (Use "/" instead of "\")
	sentence filePath C:/Users/Hu/Desktop/test
	#sentence filePath D:/changzhou/2_annotation/F5/bisyllabic/
	comment The tier names of the TextGrid file (Separate by space)
	sentence tiers Syllable Segment Target
	comment Which tier is the point tier? (Leave empty if none)
	sentence pointTier Target
endform

if right$(filePath$) <> "/"
	filePath$ = filePath$ + "/"
endif

extension$ = ".wav"
tg$ = ".TextGrid"

Create Strings as file list: "list", filePath$ + "*.wav"
fileNum = Get number of strings

for i from 1 to fileNum
	selectObject: "Strings list"
	fileName$ = Get string: i
	baseName$ = fileName$ - ".wav"
	file$ = filePath$ + baseName$ + ".wav"
	Read from file: file$
	if fileReadable(file$ - extension$ + tg$)
		Read from file: file$ - extension$ + tg$
	else
		selectObject: "Sound " + baseName$
		To TextGrid: tiers$, pointTier$
	endif
	selectObject: "Sound " + baseName$
	plusObject: "TextGrid " + baseName$
	View & Edit
	beginPause: "Save & continue"
		comment: "Do you want to save and continue?"
	clicked = endPause: "yes", "no", 1
	if clicked = 1
		selectObject: "TextGrid " + baseName$
		Save as text file: filePath$ + baseName$ + tg$
	endif
	selectObject: "Sound " + baseName$
	plusObject: "TextGrid " + baseName$
	Remove
endfor

selectObject: "Strings list"
Remove
