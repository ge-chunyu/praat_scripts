# Author: Chunyu Ge 葛淳宇
# Updated: 2019-12-12
# Usage: - Check the pitch of sound files, and smooth the manually checked pitch
#        - The smoothed and interpolated Pitch and PitchTier files are saved in the same directory
# Cautions: - The floor and ceiling of Pitch caculation is set to 75 and 300 for male, and 100 and 350 for female
#           - If the pitch is already checked, the existed pitch and PitchTier files will be opened
# Tested on Praat 6.0.37

form What you want to do with this script
comment Where are the files?
sentence filePath C:/Users/Hu/Desktop/test/
comment Is this speaker male or female?
word gender male
endform

# path normalization
if right$(filePath$) <> "/"
		filePath$ = filePath$ + "/"
endif

# usual variables
extension$ = ".wav"
tg$ = ".TextGrid"
pitch$ = ".PitchTier"

if gender$ == "male"
	floor = 75
	ceiling = 300
else
	floor = 100
	ceiling = 350
endif

# access the files/directories using `Strings`
Create Strings as file list: "fileList", filePath$ + "*" + extension$
selectObject: "Strings fileList"
stringNum = Get number of strings

for i from 1 to stringNum
	selectObject: "Strings fileList"
	fileName$ = Get string: i
	baseName$ = fileName$ - extension$
	Read from file: filePath$ + fileName$
	Read from file: filePath$ + baseName$ + tg$
	selectObject: "Sound " + baseName$
	plusObject: "TextGrid " + baseName$
	View & Edit
	if fileReadable(filePath$ + baseName$ + pitch$)
		Read from file: filePath$ + baseName$ + pitch$
		Read from file: filePath$ + baseName$ + ".pitch"
		selectObject: "PitchTier " + baseName$
		View & Edit
		selectObject: "Pitch " + baseName$
		View & Edit
		beginPause: "Save & continue"
		comment: "Do you want to save and continue?"
		clicked = endPause: "yes", "no", 1
		if clicked = 1
			selectObject: "Pitch " + baseName$
			Save as text file: filePath$ + baseName$ + ".pitch"
			selectObject: "PitchTier " + baseName$
			Save as text file: filePath$ + baseName$ + ".PitchTier"
		endif
	else
		selectObject: "Sound " + baseName$
		To Pitch: 0, floor, ceiling
		selectObject: "Pitch " + baseName$
		View & Edit
		pause Confirm
		selectObject: "Pitch " + baseName$
		@smooth_pitch: baseName$
		selectObject: "Pitch interpolate"
		beginPause: "Save & continue"
		comment: "Do you want to save and continue?"
		clicked = endPause: "yes", "no", 1
		if clicked = 1
			selectObject: "Pitch interpolate"
			Save as text file: filePath$ + baseName$ + ".pitch"
			selectObject: "PitchTier interpolate"
			Save as text file: filePath$ + baseName$ + ".PitchTier"
		endif
	endif
	select all
	minusObject: "Strings fileList"
	Remove
endfor

selectObject: "Strings fileList"
Remove

procedure smooth_pitch: .baseName$
	selectObject: "Pitch " + .baseName$
	Smooth: 10
	Rename: "smooth"
	Interpolate
	Rename: "interpolate"
	selectObject: "Pitch interpolate"
	Down to PitchTier
endproc