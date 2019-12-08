path$ = "C:/Users/Hu/Desktop/test/"
gender$ = "female"
extension$ = ".wav"
tg$ = ".TextGrid"
tier = 3

if right$(path$) <> "/"
		path$ = path$ + "/"
endif

if gender$ == "male"
	floor = 75
	ceiling = 300
else
	floor = 100
	ceiling = 350
endif

Create Strings as file list: "fileList", path$ + "*" + extension$
selectObject: "Strings fileList"
stringNum = Get number of strings

for i from 1 to stringNum
	selectObject: "Strings fileList"
	fileName$ = Get string: i
	baseName$ = fileName$ - extension$
	Read from file: path$ + fileName$
	Read from file: path$ + baseName$ + tg$
	@stylize_pitch: baseName$, floor, ceiling
	@mark_point: baseName$, tier
endfor

procedure mark_point: .baseName$, .tier
	selectObject: "PitchTier stylized"
	pointNum = Get number of points
	for p from 1 to pointNum
		selectObject: "PitchTier stylized"
		time = Get time from index: p
		value = Get value at index: p
		selectObject: "TextGrid " + .baseName$
		Insert point: .tier, time, fixed$(value, 0)
	endfor
endproc

procedure smooth_pitch: .baseName$, .floor, .ceiling
	selectObject: "Sound " + .baseName$
	To Pitch: 0, .floor, .ceiling
	selectObject: "Pitch " + baseName$
	Smooth: 10
	Rename: "smooth"
endproc

procedure stylize_pitch: .baseName$, .floor, .ceiling
	@smooth_pitch: .baseName$, .floor, .ceiling
	selectObject: "Pitch smooth"
	Down to PitchTier
	selectObject: "PitchTier smooth"
	Stylize: 2, "Semitones"
	Rename: "stylized"
endproc

procedure draw_stylized_pitch: .baseName$, .start, .end, .floor, .ceiling
	selectObject: "PitchTier stylized"
	Select inner viewport: 1, 3, 1, 2.15
	Line width: 2
	Colour: "Blue"
	Draw: .start, .end, .floor, .ceiling, "no", "lines"
	Line width: 1
	Colour: "Black"
endproc