#NoEnv
#NoTrayIcon
#SingleInstance off
SetWorkingDir %A_ScriptDir%

#Include %A_ScriptDir%\include\AutoXYWH.ahk
; Create a default icon
if ( Not A_IconFile and Not A_IsCompiled ) {
  IconPath = %A_ScriptDir%\compile.ico|%A_ScriptDir%\ahk\compile.ico|E:\Scripts\ahk\compile.ico
  Loop, Parse, IconPath, |
  {
    If ( FileExist(A_LoopField) ) {
      Menu, Tray, Icon, %A_LoopField%
      break
    }
  }
}

SETTINGSSOURCE := A_ScriptDir . "\" . A_ScriptName . ".ini"
IniRead, COMPILERSOURCE, %SETTINGSSOURCE%, settings, compiler,C:\
IniRead, NoiseValue, %SETTINGSSOURCE%, settings, noise, 0
IniRead, ScaleValue, %SETTINGSSOURCE%, settings, scale, 2
IniRead, DEFAULTEXT, %SETTINGSSOURCE%, settings, extension, _x<scale>_n<noise>
VERSION    := "0.2"
SOURCEFILES =
OUTPUT      =
FILEMODE   := 1
WWIDTH     := 450

If (FileExist(COMPILERSOURCE) == 0 or COMPILERSOURCE=="C:\" or COMPILERSOURCE=="") {
  MsgBox,, Waifu2x, No compiler has been selected yet, please select the waifu2x-converter-cpp.exe
  Gosub, SelectCompiler
}

If (FileExist(COMPILERSOURCE) == 0 or COMPILERSOURCE=="C:\" or COMPILERSOURCE=="") {
  MsgBox,, Waifu2x, No compiler was selected, the program will exit.
  ExitApp
}

Gui, +Resize
  Gui, Font, s8, Segoe UI
  Menu, SettingsMenu, Add, Select &Compiler, SelectCompiler
  Menu, SettingsMenu, Add, Command &Line Options, SelectExtension
  Menu, SettingsMenu, Add, Default &Extension, SelectExtension
  Menu, SettingsMenu, Add
  Menu, SettingsMenu, Add, E&xit`tEsc, MenuHandler
  Menu, MenuBar, Add, Sett&ings, :SettingsMenu
  Menu, MenuBar, Add, v%VERSION%, DoNothing, Right
  Gui, Menu, MenuBar

  LabelWidth := 95
  LabelStyle := "section +0x200 BackgroundTrans"
  eSeparator := "xm y+10 w445 h2 0x10"
  eSpacing   := 5

  Gui, Add, Text,   xm           y+10 w%LabelWidth% %LabelStyle%, Source:
  Gui, Add, Button, x+%eSpacing% ys-5 w90 					gOpen, &Open
  Gui, Add, Edit,   x+%eSpacing% ys-4 w250 					hWndhEdit1 vEditFileOpen,

  Gui, Add, Text,   xm           y+10 w%LabelWidth%  %LabelStyle% vLabelFileSave, Output File:
  Gui, Add, Button, x+%eSpacing% ys-5 w90 			    vButtonFileSave gSaveAs, &Save As...
  Gui, Add, Edit,   x+%eSpacing% ys-4 w250 					hWndhEdit2 vEditFileSave,

  Gui, Add, Text, xm           y+10 w%LabelWidth% %LabelStyle% vLabelFileExt +Disabled, Output Name Ext.:
  Gui, Add, Edit, x+%eSpacing% ys-5 w200          hWndhEdit3 vEditFileExt gEditFileExtChange +Disabled
  Gui, Add, Text, x+%eSpacing% ys   w40				 	  hWndhStatic13 vLabelPreview +Disabled, Preview:
  Gui, Add, Edit, x+%eSpacing% ys-5 w92  				  hWndhEdit4 vEditPreview +Disabled +ReadOnly,

  Gui, Add, Text, %eSeparator% hWndhStatic10

  Gui, Add, Text,   xm           y+10 w%LabelWidth%  %LabelStyle%, Noise Reduction:
  Gui, Add, Slider, x+%eSpacing% ys-5 w300           hWndhmsctls_trackbar321 vSliderNoise gSliderNoiseChange +Tooltip TickInterval1 Range0-3, 0
  Gui, Add, Edit,   x+%eSpacing% ys-5 w20            hWndhEdit5 vEditNoise x419 y97 w31 h21 +Disabled +ReadOnly Center, 0

  Gui, Add, Text,   xm           y+15 w%LabelWidth% %LabelStyle%, Image Scaling:
  Gui, Add, Edit,   x+%eSpacing% ys-5 w340          hWndhEdit6 vEditScale gEditScaleChange, 2
  Gui, Add, UpDown, x+%eSpacing% ys-5 w20           hWndhmsctls_updown321 vCounterScale +0x80, 2

  Gui, Add, Text, %eSeparator% hWndhStatic16

  Gui, Add, Button,   xm           y+10 w100 section gProcess, STA&RT
  Gui, Add, Progress, x+%eSpacing% ys+1 w230 h21 hWndhmsctls_progress321 vProgressBar -Smooth Range0-1, 0
  Gui, Add, Button,   x+%eSpacing% ys   w100 hWndhButton4 vButtonResult gOpenResult Disabled, Open Result

  Gui Show,, Waifu2x
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

  If (FileExist(COMPILERSOURCE) == 0 or COMPILERSOURCE=="C:\" or COMPILERSOURCE=="") {
    MsgBox,,Error, No compiler selected. Please select one under settings.
    return
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