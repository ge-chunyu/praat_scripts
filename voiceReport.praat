# Author: 
# Updated:
# Usage:
# Cautions:

# I-O with the user using the `form`
form What you want to do with this script
comment Where are the files?
sentence path /Users/chunyu/Desktop/suzhou/
comment Where to store the output files?
sentence outPath /Users/chunyu/Desktop/suzhou/data/
comment What is the file name of the output file?
sentence file voice
comment Which tier is the annotation of closure?
integer tier 2
endform

# path normalization
if right$(path$) <> "/"
		path$ = path$ + "/"
endif

# usual variables
extension$ = ".wav"

outFile$ = outPath$ + file$ + ".txt"
writeFileLine: outFile$, "file", tab$, "speaker", tab$, "gender", tab$, "label", tab$, "closure", tab$, "interval", tab$, "voicing"

Create Strings as directory list: "dirList", path$ 
selectObject: "Strings dirList"
dirNum = Get number of strings

for d from 1 to dirNum
	selectObject: "Strings dirList"
	dirName$ = Get string: d
	speaker$ = dirName$
	dirName$ = dirName$ + "/"
	gender$ = left$(speaker$, 1)
	if gender$ == "F" | gender$ == "M"
		Create Strings as file list: "fileList", path$ + dirName$ + "*" + extension$
		selectObject: "Strings fileList"
		stringNum = Get number of strings

		if gender$ == "F"
			floor = 100
			ceiling = 500
		else
			floor = 75
			ceiling = 300
		endif

		for i from 1 to stringNum
			selectObject: "Strings fileList"
			fileName$ = Get string: i
			name$ = fileName$ - extension$
			no = number (mid$ (name$, 5, 3))
			if no > 214
				Read from file: path$ + dirName$ + fileName$
				Read from file: path$ + dirName$ + name$ + ".TextGrid"
				selectObject: "Sound " + name$
				@analyzePitch: name$, floor, ceiling

				selectObject: "TextGrid " + name$
				intervalNum = Get number of intervals: tier
				for j from 2 to intervalNum
					selectObject: "TextGrid " + name$
					lab$ = Get label of interval: tier, j
					if lab$ = "sil" 
						start = Get starting point: tier, j
						end = Get end point: tier, j
						closure = end - start
						first = start + (closure / 3)
						second = start + (closure / 3) * 2
						@getVoicing: name$, start, end, floor, ceiling, outFile$, speaker$, gender$, closure, lab$, "total"
						@getVoicing: name$, start, first, floor, ceiling, outFile$, speaker$, gender$, closure, lab$, "first"
						@getVoicing: name$, first, second, floor, ceiling, outFile$, speaker$, gender$, closure, lab$, "second"
						@getVoicing: name$, second, end, floor, ceiling, outFile$, speaker$, gender$, closure, lab$, "third"
					endif
				endfor
				appendInfoLine: name$, " finished!"
				select all
				minusObject: "Strings fileList"
				minusObject: "Strings dirList"
				Remove
			endif
		endfor		
	endif
endfor





appendInfoLine: "All finished!"

procedure analyzePitch: .name$, .floor, .ceiling
	selectObject: "Sound " + .name$
	To Pitch: 0, .floor, .ceiling
	selectObject: "Pitch " + .name$
	To PointProcess
endproc

procedure getVoicing: .name$, .start, .end, .floor, .ceiling, .outFile$, .speaker$, .gender$, .closure, .label$, .position$
	selectObject: "Sound " + .name$
	plusObject: "Pitch " + .name$
	plusObject: "PointProcess " + .name$
	voiceReport$ = Voice report: .start, .end, .floor, .ceiling, 1.3, 1.6, 0.03, 0.45
	voiceRatio = 1 - extractNumber (voiceReport$, "Fraction of locally unvoiced frames: ")
	appendFileLine: .outFile$, .name$, tab$, .speaker$, tab$, .gender$, tab$, .label$, tab$, .closure, tab$, .position$, tab$, voiceRatio
endproc

