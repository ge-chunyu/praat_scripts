# Author: Chunyu Ge 葛淳宇
# Last updated: 2019-12-12
# Usage: - Draw the pitch curves of all the sound files in a given direcory
#        - Different colors are used for different tones
# Cautions: - the number of the tone category must be specified in the file name as an integer
#           - The number represents the tone category is its index counted leftward
# Tested in Praat 6.0.37

form Draw pitch 
comment Where are the files? 
sentence path D:/honggu/2_annotation/M2/mono_sen/
comment Is this speaker male or female?
word gender male
comment Which number in the file name represents the tone category?
integer t 7
comment What is the ID of the speaker?
word speaker M2
comment The pattern of sound files
word pattern FF
comment The file name of the picture
word picName mono
comment Where to save the picture file?
sentence picPath C:/Users/Hu/Desktop/
endform

if right$(path$) <> "/"
		path$ = path$ + "/"
endif
if right$(picPath$) <> "/"
		picPath$ = picPath$ + "/"
endif

if gender$ == "male"
	floor = 75
	ceiling = 300
else
	floor = 100
	ceiling = 350
endif

extension$ = ".wav"
tg$ = ".TextGrid"
rainbow$ [1] = "Black"
rainbow$ [2] = "Blue"
rainbow$ [3] = "Red"
rainbow$ [4] = "Green"
rainbow$ [5] = "Yellow"
rainbow$ [6] = "Cyan"
rainbow$ [7] = "Maroon"
rainbow$ [8] = "Navy"

# access the files/directories using `Strings`
Create Strings as file list: "fileList", path$ + speaker$ + "_" + pattern$ + "*" + extension$
selectObject: "Strings fileList"
stringNum = Get number of strings
Erase all

for i from 1 to stringNum
	selectObject: "Strings fileList"
	fileName$ = Get string: i
	baseName$ = fileName$ - extension$
	color$ = rainbow$ [number(mid$(baseName$, t, 1))]
	Read from file: path$ + fileName$
	Read from file: path$ + baseName$ + tg$
	selectObject: "TextGrid " + baseName$
	n = Get number of intervals: 2
	start = Get start time of interval: 2, 3
	end = Get end time of interval: 2, n-1
	picStart = start - 0.05
	picEnd = end + 0.05
	@smooth_pitch: baseName$, floor, ceiling
	@draw_pitch: baseName$, floor, ceiling, picStart, picEnd, color$
endfor

Draw inner box
Text right: "yes", "Pitch (Hz)"
Text top: "no", speaker$
Text bottom: "no", "Normalized time"
Marks right: ceiling / 100 + 1, "yes", "yes", "no"

Select outer viewport: 0, 5, 0, 3
Save as 600-dpi PNG file: picPath$ + speaker$ + "-" + picName$ + pattern$ + ".png"

select all
Remove

procedure smooth_pitch: .baseName$, .floor, .ceiling
	selectObject: "Sound " + .baseName$
	To Pitch: 0, .floor, .ceiling
	selectObject: "Pitch " + baseName$
	Smooth: 10
	Rename: "smooth"
endproc

procedure draw_pitch: .baseName$, .floor, .ceiling, .start, .end, .color$
	selectObject: "Pitch smooth"
	Select outer viewport: 0, 5, 0, 3
	Axes: 0, .end - .start, 0, .ceiling
	Line width: 1
	Font size: 14
	Colour: .color$
	Draw: .start, .end, 0, .ceiling, "no"
	Line width: 1
	Colour: "Black"
endproc