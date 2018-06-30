#NoEnv
#NoTrayIcon
#SingleInstance off
SetWorkingDir %A_ScriptDir%

#Include E:\Scripts\ahk\AutoXYWH.ahk
#Include E:\Scripts\ahk\library.ahk

SETTINGSSOURCE := A_ScriptDir . "\" . A_ScriptName . ".ini"
IniRead, COMPILERSOURCE, %SETTINGSSOURCE%, settings, compiler, C:\Programs\waifu2x\waifu2x-converter-cpp.exe
IniRead, NoiseValue, %SETTINGSSOURCE%, settings, noise, 0
IniRead, ScaleValue, %SETTINGSSOURCE%, settings, scale, 2
IniRead, DEFAULTEXT, %SETTINGSSOURCE%, settings, extension, _x<scale>_n<noise>
VERSION    := "1.2"
SOURCEFILES =
OUTPUT      =
FILEMODE   := 1
WWIDTH     := 450

Gui +Resize
	Gui Font, s8, Segoe UI
	Menu SettingsMenu, Add, Select &Compiler, SelectCompiler
	Menu SettingsMenu, Add, Default &Extension, SelectExtension
	Menu SettingsMenu, Add
	Menu SettingsMenu, Add, E&xit`tEsc, MenuHandler
	Menu MenuBar, Add, Sett&ings, :SettingsMenu
	Menu MenuBar, Add, v%VERSION%, DoNothing, Right
	Gui Menu, MenuBar

	Gui Add, Text, x8 y3 w45 h23 +0x200 BackgroundTrans, Source:
	Gui Add, Button, hWndhButton1 gOpen x116 y2 w84 h23, &Open
	Gui Add, Edit, hWndhEdit1 vEditFileOpen x202 y3 w248 h21

	Gui Add, Text, vLabelFileSave x8 y29 w90 h23 +0x200 BackgroundTrans, Output File:
	Gui Add, Button, vButtonFileSave gSaveAs x116 y29 w84 h23, &Save As...
	Gui Add, Edit, hWndhEdit2 vEditFileSave x202 y30 w248 h21

	Gui Add, Text, vLabelFileExt x8 y55 w91 h23 +0x200 +Disabled BackgroundTrans, Output Name Ext.:
	Gui Add, Edit, hWndhEdit3 vEditFileExt gEditFileExtChange x116 y57 w174 h21 +Disabled
	Gui Add, Text, hWndhStatic13 vLabelPreview x298 y56 w46 h23 +0x200 +Disabled, Preview:
	Gui Add, Edit, hWndhEdit4 vEditPreview x345 y57 w105 h21 +Disabled +ReadOnly

	Gui Add, Text, hWndhStatic10 x-3 y89 w471 h2 0x10

	Gui Add, Text, x8 y97 w90 h23 +0x200 BackgroundTrans, Noise Reduction:
	Gui Add, Slider, hWndhmsctls_trackbar321 vSliderNoise gSliderNoiseChange x112 y96 w305 h23 +Tooltip TickInterval1 Range0-3, 0
	Gui Add, Edit, hWndhEdit5 vEditNoise x419 y97 w31 h21 +Disabled +ReadOnly Center, 0

	Gui Add, Text, x8 y126 w90 h23 +0x200 BackgroundTrans, Image Scaling:
	Gui Add, Edit, hWndhEdit6 vEditScale gEditScaleChange x116 y127 w333 h21, 2
	Gui Add, UpDown, hWndhmsctls_updown321 vCounterScale x451 y128 w18 h21 +0x80, 2

	Gui Add, Text, hWndhStatic16 x1 y158 w464 h2 0x10

	Gui Add, Button, x6 y168 w105 h24 gProcess, STA&RT
	Gui Add, Progress, hWndhmsctls_progress321 vProgressBar x114 y169 w227 h22 -Smooth Range0-1, 0
	Gui Add, Button, hWndhButton4 vButtonResult gOpenResult Disabled x344 y168 w105 h24, Open Result

	Gui Show, w455 h200, Waifu2x
	Gui, +MinSize400x200 +MaxSize9999x200
	IniRead, WWIDTH, %SETTINGSSOURCE%, settings, width, 455
	Gui Show, w%WWIDTH%

	GuiControl,, EditScale, %ScaleValue%
	GuiControl,, SliderNoise, %NoiseValue%
	GuiControl,, EditNoise, %NoiseValue%

	If (A_Args.Length()) {
		If (A_Args.Length() == 1) {
			InputFile := A_Args[1]
			FILEMODE := InputSingle(SOURCEFILES, InputFile, DEFAULTEXT)
		}
		Else {
			for n, FileArg in A_Args  ; For each parameter:
			{
				SplitPath, FileArg, DropFileName, DropFileDir
				InputFiles .= "`n" . DropFileName
			}
			InputFiles := DropFileDir . InputFiles

			FILEMODE := InputFileList(SOURCEFILES, InputFiles, DEFAULTEXT)
		}
	}
return


InputFileList(ByRef OutputVar, InputFiles, Extension) {
	FileList := StrSplit(InputFiles, "`n")
	FileSize := FileList.Length() - 1

	if ( FileSize == 0 ) {
		return 0
	}

	if ( FileSize == 1 ) {
		InputFilePath := FileList[1] . "\" . FileList[2]
		OutputVar := InputFilePath
		SplitPath, InputFilePath,, OutFileDir, OutFileExt, OutFileName
		OutputFilePath := OutFileName . Extension . ".png"

		GuiControl, Text, EditFileOpen, %InputFilePath%
		GuiControl, Text, EditFileSave, %OutputFilePath%
		GuiControl, Text, EditFileExt,
		GuiControl, Text, EditPreview,

		GuiControl, -ReadOnly, EditFileOpen
		GuiControl, Enable, LabelFileSave
		GuiControl, Enable, ButtonFileSave
		GuiControl, Enable, EditFileSave

		GuiControl, Disable, LabelFileExt
		GuiControl, Disable, EditFileExt
		GuiControl, Disable, LabelPreview
		GuiControl, Disable, EditPreview
		return 1
	}

	else {
		OutputVar := InputFiles
		InputFilePath := StrReplace(InputFiles, "`n", ", ")
		GuiControl, Text, EditFileOpen, %InputFilePath%
		GuiControl, Text, EditFileSave, %OutputFilePath%
		GuiControl, Text, EditFileExt, %Extension%

		GuiControl, +ReadOnly, EditFileOpen
		GuiControl, Disable, LabelFileSave
		GuiControl, Disable, ButtonFileSave
		GuiControl, Disable, EditFileSave

		GuiControl, Enable, LabelFileExt
		GuiControl, Enable, EditFileExt
		GuiControl, Enable, LabelPreview
		GuiControl, Enable, EditPreview
		return 2
	}
}


InputSingle(ByRef OutputVar, InputFile, Extension) {
	SplitPath, InputFile, OutFileName, OutDir
	FileList := OutDir . "`n" . OutFileName
	return InputFileList(OutputVar, FileList, Extension)
}


WaifuSingle(InputFile, OutFile, InputNoise := 0, InputScale := 2, Compiler := "") {
	GuiControl, Disable, ButtonResult
	GuiControl, Text, ButtonResult, Working...
	if (FileExist(InputFile)) {
		SplitPath, InputFile, OutFileName, OutFileDir, OutFileExt, OutFileName

		GuiControl, +Range0-2, ProgressBar
		GuiControl,, ProgressBar, 1

		Success := Waifu(InputFile, OutFile, InputNoise, InputScale, Compiler)

		if (Success) {
			GuiControl, Enable, ButtonResult
			GuiControl, Text, ButtonResult, Open Result
			GuiControl,, ProgressBar, 2
		}
		else {
			GuiControl,, ProgressBar, 0
			GuiControl, Disable, ButtonResult
			GuiControl, Text, ButtonResult, Error
			MsgBox Something went wrong processing your files.
		}
		Gui, Flash
	}
	else {
		MsgBox,, No Source File, Source file doesn't exist!`nInput: %InputFile%
		return 0
	}
}


WaifuList(InputList, Extension := "_scaled", InputNoise := 0, InputScale := 2, Compiler := "") {
	SourceFileList := StrSplit(InputList, "`n")
	FileTotal := SourceFileList.Length()
	GuiControl, Disable, ButtonResult
	GuiControl, Text, ButtonResult, Working...

	GuiControl, +Range0-%FileTotal%, ProgressBar
	GuiControl,, ProgressBar, 1

	for index, Fi in SourceFileList {
		if (index > 1) {
			IndexOutput := index - 1
			InputFile   := SourceFileList[1] . "\" . Fi
			SplitPath, InputFile, OutFileName, OutDir, OutExt, OutNameNoExt
			OutFile     := SourceFileList[1]  . "\" . OutNameNoExt . Extension . ".png"

			GuiControl,, ProgressBar, %IndexOutput%
			Success := Waifu(InputFile, OutFile, InputNoise, InputScale, Compiler)

			if (Success == 0) {
				GuiControl, Disable, ButtonResult
				GuiControl, Text, ButtonResult, Error
				GuiControl,, ProgressBar, 0
				Gui, Flash
				Exit
			}
		}
	}

	Gui, Flash
	GuiControl,, ProgressBar, %FileTotal%
	GuiControl, Text, ButtonResult, Open Result
	GuiControl, Enable, ButtonResult
}


Waifu(InputFile, OutFile, InputNoise := 0, InputScale := 2, Compiler := "") {
	SplitPath, Compiler, EXE, DIR
	SetWorkingDir, %DIR%

	InputFile := StrReplace(InputFile, "<scale>", InputScale)
	InputFile := StrReplace(InputFile, "<noise>", InputNoise)
	OutFile := StrReplace(OutFile, "<scale>", InputScale)
	OutFile := StrReplace(OutFile, "<noise>", InputNoise)
	SplitPath, OutFile, OutFileName, OutDir, OutExt, OutNameNoExt

	if (FileExist(InputFile) == 0) {
		return 0
	}

	if (InputNoise == 0) {
		RunWait, "%EXE%" --input "%InputFile%" --output "%OutFile%" --scale_ratio %InputScale%,,Hide
	}
	else {
		RunWait, "%EXE%" --input "%InputFile%" --output "%OutFile%" --scale_ratio %InputScale% --noise_level %InputNoise%,,Hide
	}

	SetWorkingDir, %A_ScriptDir%

	; Repair program output filename
	Fi1 := OutDir "\" OutNameNoExt "." OutExt ".png"
	if FileExist(Fi1) == 0 {
		MsgBox,, Error, Compiler couldn't convert image.
		return 0
	}

	Fi2 := OutDir "\" OutNameNoExt ".png"
	FileMove, %Fi1%, %Fi2%, 1

	; Check if file was moved
	if FileExist(OutFile) == 0 {
		return 0
	}
	return 1
}


Process:
	Gui, Submit, NoHide
	ScaleValue := EditScale
	NoiseValue := EditNoise

	if (FileExist(COMPILERSOURCE) == 0) {
		MsgBox,,Error, No compiler selected. Please select one under settings.
	}

	if (FILEMODE == 1) {
		SplitPath, EditFileOpen,, OutDir
		OutFilePath :=

		; Test if output file is full path
		if (InStr(EditFileSave, "\")) {
			OutFilePath := EditFileSave
		}
		else {
			OutFilePath := OutDir . "\" . EditFileSave
		}

		OUTPUT := OutFilePath
		WaifuSingle(EditFileOpen, OutFilePath, NoiseValue, ScaleValue, COMPILERSOURCE)
	}

	if (FILEMODE == 2) {
		OutDir := StrSplit(SOURCEFILES, "`n")
		OUTPUT := OutDir[1]
		WaifuList(SOURCEFILES, EditFileExt, NoiseValue, ScaleValue, COMPILERSOURCE)
	}

	OUTPUT := StrReplace(OUTPUT, "<scale>", ScaleValue)
	OUTPUT := StrReplace(OUTPUT, "<noise>", NoiseValue)

	IniWrite, %NoiseValue%, %SETTINGSSOURCE%, settings, noise
	IniWrite, %ScaleValue%, %SETTINGSSOURCE%, settings, scale
return


Open:
	FileSelectFile, InputFiles, M3,, Select Source Images
	if ( ErrorLevel ) {
		return
	}
	FILEMODE := InputFileList(SOURCEFILES, InputFiles, DEFAULTEXT)
return


GuiDropFiles:
	InputFiles :=
	Loop, parse, A_GuiEvent, `n
	{
		SplitPath, A_LoopField, DropFileName, DropFileDir
		InputFiles .= "`n" . DropFileName
	}
	InputFiles := DropFileDir . InputFiles

	FILEMODE := InputFileList(SOURCEFILES, InputFiles, DEFAULTEXT)
return


SaveAs:
	FileSelectFile, ExportFile, S3,, Save Result As..., PNG Files (*.png)
	if (FileExist(ExportFile)) {
		MsgBox, 4, File Exists, The File `n %ExportFile% `n already exists, do you want to overwrite it?
		IfMsgBox, No
			return
	}
	if (InStr(ExportFile, ".png") == 0) {
		ExportFile .= ".png"
	}
	Guicontrol, Text, EditFileSave, %ExportFile%
return


OpenResult:
	Run, "%Output%"
return


SelectCompiler:
	FileSelectFile, InputEXE, 1, %COMPILERSOURCE%, Select WAIFU2X Compiler, Executables (*.exe)
	COMPILERSOURCE := InputEXE
	IniWrite, %COMPILERSOURCE%, %SETTINGSSOURCE%, settings, compiler
return


SelectExtension:
	InputBox, Ext, Enter Extension, Enter the default extension to be applied to converted files`n`nPlaceholders:`n<scale> - Insert scale value`n<noise> - Insert noise value,,,200,,,,,%DEFAULTEXT%
	if ( ErrorLevel ) {
		return
	}
	DEFAULTEXT := Ext
	IniWrite, %DEFAULTEXT%, %SETTINGSSOURCE%, settings, extension
return


SliderNoiseChange:
	GuiControl, Text, EditNoise, %SliderNoise%
	NoiseValue := SliderNoise
	Gosub, EditFileExtChange
return


EditScaleChange:
	ScaleValue := EditScale
	Gosub, EditFileExtChange
return


EditFileExtChange:
	Gui, Submit, NoHide
	FileList := StrSplit(SOURCEFILES, "`n")
	InputFile := StrSplit(FileList[2], ".")
	Ext := EditFileExt
	Ext := StrReplace(Ext, "<scale>", EditScale)
	Ext := StrReplace(Ext, "<noise>", EditNoise)
	OutputFilePath := InputFile[1] . Ext . ".png"
	GuiControl, Text, EditPreview, %OutputFilePath%
return

GuiSize:
	WWIDTH := A_GuiWidth
	if (A_EventInfo == 1) {
		return
	}

	AutoXYWH("w", hEdit1)
	AutoXYWH("w", hEdit2)
	AutoXYWH("w", hStatic10)
	AutoXYWH("w", hEdit3)
	AutoXYWH("x", hEdit4)
	AutoXYWH("x", hStatic13)
	AutoXYWH("w", hmsctls_trackbar321)
	AutoXYWH("x", hEdit5)
	AutoXYWH("w", hmsctls_progress321)
	AutoXYWH("w", hEdit6)
	AutoXYWH("x", hmsctls_updown321)
	AutoXYWH("w", hStatic16)
	AutoXYWH("x", hButton4)
return

DoNothing:
return

MenuHandler:
GuiEscape:
GuiClose:
	IniWrite, %WWIDTH%, %SETTINGSSOURCE%, settings, width
	ExitApp
return