# Waifu2x CPP GUI
This is a AutoHotKey script to run a front-end for [waifu2x-cpp-converter](https://github.com/DeadSix27/waifu2x-converter-cpp).

# Building
Prerequisites:
* [waifu2x-cpp-converter](https://github.com/DeadSix27/waifu2x-converter-cpp)
* [AutoHotKey_L (1.1)](https://www.autohotkey.com/download/)

Run the AutoHotKey2exe compiler:

`"C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe" /in waifu2x.ahk /out waifu2x.exe /icon compile.ico`

# Usage
On first run select `waifu2x-converter-cpp.exe` that you downloaded.

Use the *Open* button to select one or multiple files (in the same folder) or drag and drop onto the window.

* If you selected a single file, you can specify a new file to save to (only converts to **.png**), or a base
output name (which will save in the same folder with the new name)
* If you selected multiple files, you can specify an extenstion to add to the filename of each converted image (`"img.jpg" + ext "_scaled" = "img_scaled.png"`)

The GUI does not currently support selecting an output folder for multiple files (will always output to the source folder), on TODO.

Both methods support placeholders `<scale>` and `<noise>` which will be replaced by the current scaling and noise levels.

# Command Line
You can pass a single or list of files to a compiled version of the GUI to open it. If you'd like processing or control over it I would recommend using the command line options on [waifu2x-cpp-converter](https://github.com/DeadSix27/waifu2x-converter-cpp).