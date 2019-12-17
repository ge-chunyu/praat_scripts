# extract f0

form Folder
comment Extract pitch equi-distantly according to the TextGrid file
comment The input file path (use "/" instead of "\")
sentence path D:/honggu/2_annotation/
comment The output file path
sentence savePath C:/Users/Hu/Desktop/
comment The name of the pitch file
word pitchName mono_sen
comment The index of tone letter
integer t 7
comment The recording folder
word folder mono_sen
comment The reference tier
integer tier 2
comment the number of points within an interval
integer point 10
endform

if right$(path$) <> "/"
		path$ = path$ + "/"
endif
if right$(savePath$) <> "/"
		savePath$ = savePath$ + "/"
endif

extension$ = ".wav"
tg$ = ".TextGrid"
pitch$ = ".PitchTier"

speakers$ [1] = "F1"
speakers$ [2] = "F2"
speakers$ [3] = "F3"
speakers$ [4] = "M1"
speakers$ [5] = "M2"
speakers$ [6] = "M3"

pitchFile$ = savePath$ + pitchName$ + ".txt"
writeFileLine: pitchFile$, "file", tab$, "speaker", tab$, "gender", tab$, "label", tab$, "tone", tab$, "time", tab$, "f0"

for f from 1 to 6
	speaker$ = speakers$ [f]
	filePath$ = path$ + speaker$ + "/" + folder$ + "/"
	Create Strings as file list: "fileList", filePath$ + "*" + extension$
	selectObject: "Strings fileList"
	stringNum = Get number of strings

	for i from 1 to stringNum
		selectObject: "Strings fileList"
		fileName$ = Get string: i
		baseName$ = fileName$ - extension$
		if left$(speaker$, 1) == "F"
			gender$ = "female"
		else
			gender$ = "male"
		endif
		if gender$ == "male"
			floor = 75
			ceiling = 300
		else
			floor = 100
			ceiling = 350
		endif
		tone$ = mid$(baseName$, t, 1)

		Read from file: filePath$ + baseName$ + tg$
		Read from file: filePath$ + baseName$ + extension$
		if fileReadable(filePath$ + baseName$ + pitch$)
			Read from file: filePath$ + baseName$ + pitch$
		else
			@smooth_pitch: baseName$, floor, ceiling
		endif

		selectObject: "TextGrid " + baseName$
		intervalNum = Get number of intervals: tier

		for p from 1 to intervalNum
			selectObject: "TextGrid " + baseName$
			label$ = Get label of interval: tier, p
			if label$ <> ""
				start = Get starting point: tier, p
				end = Get end point: tier, p
				dist = (end - start) / point
				for j from 1 to point
					selectObject: "PitchTier " + baseName$
					time = start + dist * j
					f0 = Get value at time: time
					appendFileLine: pitchFile$, baseName$, tab$, speaker$, tab$, gender$, tab$, label$, tab$, tone$, tab$, time, tab$, f0
				endfor
			endif
		endfor
		select all
		minusObject: "Strings fileList"
		Remove
	endfor
	selectObject: "Strings fileList"
	Remove
endfor


procedure smooth_pitch: .baseName$, .floor, .ceiling
	selectObject: "Sound " + .baseName$
	To Pitch: 0, .floor, .ceiling
	selectObject: "Pitch " + baseName$
	Smooth: 10
	Rename: "smooth"
	Interpolate
	Rename: "interpolate"
	selectObject: "Pitch interpolate"
	Down to PitchTier
	Rename: .baseName$
endproc