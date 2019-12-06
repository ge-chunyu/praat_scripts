# Author: Chunyu Ge 葛淳宇
# Updated: 2019-12-06
# Usage: - Draw pictures of a sound file according to the TextGrid
#        - Optional: draw TextGrid together with the waveform or the spectrogram
#        - Optional: draw pitch together with the waveform or the spectrogram
# Cautions: - Use forward slash "/" instead of backward slash "\" in the path
#           - Do not add extension to the file name

form Draw a picture
	comment Where is the sound file? (Use "/" instead of "\")
	sentence filePath D:/changzhou/2_annotation/F1/bisyllabic/
	comment The file name of the sound file (Do not include extension)
	word baseName F1_B0212
	comment Where would you like to save the pictures?
	sentence savePath C:/Users/Hu/Desktop/
	#comment The start time of the picture (in second)
	#real start 1.25
	#comment The end time of the picture (in second)
	#real end 2.44
	comment Do you want to draw the TextGrid together with the sound?
	boolean drawTg yes
	comment Do you want to draw the pitch together with the sound?
	boolean drawPitch yes
endform

if right$(filePath$) <> "/"
	filePath$ = filePath$ + "/"
endif

if right$(savePath$) <> "/"
	savePath$ = savePath$ + "/"
endif

Read from file: filePath$ + baseName$ + ".wav"
Read from file: filePath$ + baseName$ + ".TextGrid"

floor = 75
ceiling = 300

selectObject: "TextGrid " + baseName$
n = Get number of intervals: 1
start = Get start time of interval: 1, 2
picStart = start - 0.05
end = Get end time of interval: 1, n-1
picEnd = end + 0.05

Erase all
@draw_waveform: baseName$, picStart, picEnd
if drawTg
	@draw_TextGrid: baseName$, picStart, picEnd
endif
if drawPitch
	@draw_pitch: baseName$, floor, ceiling, picStart, picEnd
endif
if drawTg
	Select inner viewport: 1, 4, 1, 3
else
	Select inner viewport: 1, 4, 1, 2.15
	Draw inner box
	Axes: 0, picEnd - picStart, 0, 5000
	Marks bottom: 5, "yes", "yes", "no"
	Text bottom: "yes", "Time (s)"
endif
Save as 600-dpi PNG file: savePath$ + baseName$ + "-waveform.png"

Erase all
@draw_spectrogram: baseName$, picStart, picEnd
if drawTg
	@draw_TextGrid: baseName$, picStart, picEnd
endif
if drawPitch
	@draw_pitch: baseName$, floor, ceiling, picStart, picEnd
endif
if drawTg
	Select inner viewport: 1, 4, 1, 3
else
	Select inner viewport: 1, 4, 1, 2.15
	Draw inner box
	Axes: 0, picEnd - picStart, 0, 5000
	Marks bottom: 5, "yes", "yes", "no"
	Text bottom: "yes", "Time (s)"
endif
Save as 600-dpi PNG file: savePath$ + baseName$ + "-spectrogram.png"
Erase all

select all
Remove

procedure draw_TextGrid: .baseName$, .start, .end
	selectObject: "TextGrid " + .baseName$
	Select inner viewport: 1, 4, 1, 3
	Draw: .start, .end, "yes", "yes", "no"
	Draw inner box
	Axes: 0, .end - .start, 0, 5000
	Marks bottom: 5, "yes", "yes", "no"
	Text bottom: "yes", "Time (s)"
endproc

procedure draw_waveform: .baseName$, .start, .end
	selectObject: "Sound " + baseName$
	Select inner viewport: 1, 4, 1, 2.15
	Draw: .start, .end, 0, 0, "no", "Curve"
endproc

procedure draw_spectrogram: .baseName$, .start, .end
	selectObject: "Sound " + .baseName$
	To Spectrogram: 0.005, 5000, 0.002, 20, "Gaussian"
	selectObject: "Spectrogram " + .baseName$
	Select inner viewport: 1, 4, 1, 2.15
	Paint: .start, .end, 0, 5000, 100, "yes", 50, 6, 0, "no"
	Axes: .start, .end, 0, 5000
	Marks left: 6, "yes", "yes", "no"
	Text left: "yes", "Frequency (Hz)"
endproc

procedure smooth_pitch: .baseName$, .floor, .ceiling
	selectObject: "Sound " + .baseName$
	To Pitch: 0, .floor, .ceiling
	selectObject: "Pitch " + baseName$
	Smooth: 10
	Rename: "smooth"
endproc

procedure draw_pitch: .baseName$, .floor, .ceiling, .start, .end
	@smooth_pitch: .baseName$, .floor, .ceiling
	selectObject: "Pitch smooth"
	Select inner viewport: 1, 4, 1, 2.15
	Axes: 0, .end - .start, 0, .ceiling
	Line width: 3
	#Font size: 14
	Colour: "Blue"
	Draw: .start, .end, 0, .ceiling, "no"
	Line width: 1
	Colour: "Black"
	Marks right: 4, "yes", "yes", "no"
	Text right: "yes", "Pitch (Hz)"
endproc