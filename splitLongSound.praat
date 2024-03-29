# Author: 葛淳宇 Chunyu Ge
# Updated: 2023-09-19
# Usage: Split sound by silence in between
# Cautions:

# I-O with the user using the `form`
form What you want to do with this script
comment Where are the files?
sentence path /Users/chunyu/Desktop/xiamen/long-sound-textgrid
comment What is the filename of the recording?
word baseName 20230828-JSY-7
comment Where to store the processed files?
sentence savePath /Users/chunyu/Desktop/xiamen/JSY-CM07/
comment Where is the table files?
sentence tablePath /Users/chunyu/Desktop/xiamen/
comment What is the name of the table file?
sentence tableName xiamen-metadata.txt
comment Initial of the speaker's name
word prefix JSY-CM07
comment What is the pattern of the vowel part?
word vowelPattern [aiueoc]|(ng)
endform

# path normalization
if right$(path$) <> "/"
		path$ = path$ + "/"
endif

if right$(savePath$) <> "/"
		savePath$ = savePath$ + "/"
endif

if right$(tablePath$) <> "/"
		tablePath$ = tablePath$ + "/"
endif

# usual variables
extension$ = ".wav"
tbl$ = ".txt"

fileName$ = baseName$ + ".wav"
Read from file: path$ + fileName$
selectObject: "Sound " + baseName$
nChannel = Get number of channels

if fileReadable (path$ + baseName$ + ".TextGrid")
	Read from file: path$ + baseName$ + ".TextGrid"
	selectObject: "TextGrid " + baseName$
	Remove tier: 2
	Remove tier: 3
	selectObject: "Sound " + baseName$
	plusObject: "TextGrid " + baseName$
	View & Edit
else
	@detectSilence: baseName$
	selectObject: "Sound " + baseName$
	plusObject: "TextGrid " + baseName$
	View & Edit
endif
beginPause: "Please code the word ID for each sound interval"
clicked = endPause("Next time", "Skip", "Done", 3)
if clicked = 3
	@codeInterval: baseName$, tablePath$, tableName$, prefix$, savePath$, vowelPattern$, nChannel
	selectObject: "Sound " + baseName$
	plusObject: "TextGrid " + baseName$
	Remove
elsif clicked = 1
	selectObject: "TextGrid " + baseName$
	Duplicate tier: 1, 2, "syllable"
	Insert interval tier: 3, "segment"
	Save as text file: path$ + baseName$ + ".TextGrid"
	selectObject: "Sound " + baseName$
	plusObject: "TextGrid " + baseName$
	Remove
else
	selectObject: "Sound " + baseName$
	plusObject: "TextGrid " + baseName$
	Remove
endif


procedure detectSilence: .baseName$
	selectObject: "Sound " + .baseName$
	To TextGrid (silences): 100, 0, -25, 0.5, 0.1, "sil", "sound"
endproc

procedure codeInterval: .baseName$, .tablePath$, .tableName$, .prefix$, .savePath$, .vowelPattern$, .nChannel
	Read Table from tab-separated file: .tablePath$ + .tableName$
	selectObject: "TextGrid " + .baseName$
	Duplicate tier: 1, 2, "syllable"

	Insert interval tier: 3, "segment"
	nInterval = Get number of intervals: 1
	for interval from 1 to nInterval
		selectObject: "TextGrid " + .baseName$
		label$ = Get label of interval: 1, interval
		if number (right$ (label$, 1)) != undefined
			code = number (mid$ (label$, 6, 3))
			selectObject: "Table " + .tableName$ - tbl$
			trans$ = Get value: code, "label"
			selectObject: "TextGrid " + .baseName$
			Set interval text: 2, interval, trans$

			leftNum = interval - 1
			leftStart = Get start time of interval: 1, leftNum
			leftEnd = Get end time of interval: 1, leftNum
			left = leftStart + (leftEnd - leftStart) / 2
			rightNum = interval + 1
			rightStart = Get start time of interval: 1, rightNum
			rightEnd = Get end time of interval: 1, rightNum
			right = rightStart + (rightEnd - rightStart) / 2

			selectObject: "Table " + .tableName$ - tbl$
			id$ = Get value: code, "ID"
			if .nChannel != 1
				selectObject: "Sound " + .baseName$
				Extract part: left, right, "rectangular", 1, "no"
				selectObject: "Sound " + .baseName$ + "_part"
				Extract all channels
				selectObject: "Sound " + .baseName$ + "_part_ch1"
				Save as WAV file: .savePath$ + .prefix$ + "-" + id$ + ".wav"
				selectObject: "Sound " + .baseName$ + "_part_ch2"
				Save as WAV file: .savePath$ + .prefix$ + "-" + id$ + "-egg.wav"
				selectObject: "Sound " + .baseName$ + "_part_ch1"
				plusObject: "Sound " + .baseName$ + "_part_ch2"
				Remove
			else
				selectObject: "Sound " + .baseName$
				Extract part: left, right, "rectangular", 1, "no"
				selectObject: "Sound " + .baseName$ + "_part"
				Save as WAV file: .savePath$ + .prefix$ + "-" + id$ + ".wav"
			endif

			selectObject: "TextGrid " + .baseName$
			Extract part: left, right, "no"
			selectObject: "TextGrid " + .baseName$ + "_part"
			Remove tier: 1
			Replace interval texts: 1, 1, 0, "sil", "", "Literals"

			ns = index (trans$, "-")
			transLength = length (trans$)

			if ns != 0
				s1$ = left$ (trans$, ns - 1)
				s2$ = mid$ (trans$, ns + 1, transLength - ns)

				s1L = length (s1$)
				s2L = length (s2$)

				v1 = index_regex (s1$, .vowelPattern$)
				v2 = index_regex (s2$, .vowelPattern$)

				initial1$ = left$ (s1$, v1-1)
				final1$ = mid$ (s1$, v1, s1L)

				initial2$ = left$ (s2$, v2-1)
				final2$ = mid$ (s2$, v2, s2L)

				selectObject: "TextGrid " + .baseName$ + "_part"
				leftSyllable = Get start time of interval: 1, 2
				rightSyllable = Get end time of interval: 1, 2
				mid = leftSyllable + (rightSyllable - leftSyllable) / 2
				Insert boundary: 1, mid
				Set interval text: 1, 2, s1$
				Set interval text: 1, 3, s2$
				
				Insert boundary: 2, leftSyllable
				Insert boundary: 2, leftSyllable + 0.05
				Insert boundary: 2, rightSyllable
				Insert boundary: 2, mid
				Insert boundary: 2, mid + 0.05
				Set interval text: 2, 2, initial1$
				Set interval text: 2, 3, final1$
				Set interval text: 2, 4, initial2$
				Set interval text: 2, 5, final2$

			else
				v = index_regex (trans$, .vowelPattern$)

				initial$ = left$ (trans$, v-1)
				final$ = mid$ (trans$, v, transLength)

				selectObject: "TextGrid " + .baseName$ + "_part"
				leftSyllable = Get start time of interval: 1, 2
				rightSyllable = Get end time of interval: 1, 2
				Insert boundary: 2, leftSyllable
				Insert boundary: 2, leftSyllable + 0.05
				Insert boundary: 2, rightSyllable
				Set interval text: 2, 2, initial$
				Set interval text: 2, 3, final$

			endif

			selectObject: "TextGrid " + .baseName$ + "_part"
			Save as text file: .savePath$ + .prefix$ + "-" + id$ + ".TextGrid"

		    selectObject: "TextGrid " + .baseName$ + "_part"
		    plusObject: "Sound " + .baseName$ + "_part"
		    Remove
		endif
	endfor
	selectObject: "TextGrid " + .baseName$
	Save as text file: path$ + .baseName$ + ".TextGrid"
	selectObject: "Table " + .tableName$ - tbl$
	Remove
endproc












