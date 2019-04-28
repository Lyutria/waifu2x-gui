# Waifu2x CPP GUI
This is a AutoHotKey script to run a front-end for [waifu2x-cpp-converter](https://github.com/DeadSix27/waifu2x-converter-cpp).

## NVIDIA CARD WARNING
The prebuilt version of waifu2x-converter-cpp is made for *AMD* graphics cards, in order to use it for your system you'll have to select a different processor
From the command line:
```
waifu-converter-cpp.exe --list-processor
```
Pick the number from the list that has `(OpenCL)`, and then in the GUI, select *Settings, Command Line Options* and enter:
```
--processor #
```
Where # is the number of the processor that had OpenCL support.

# Usage
On first run select `waifu2x-converter-cpp.exe` that you downloaded.

Use the *Open* button to select one or multiple files (in the same folder) or drag and drop onto the window.

* If you selected a single file, you can specify a new file to save to (only converts to **.png**), or a base
output name (which will save in the same folder with the new name)
* If you selected multiple files, you can specify an output directory (it must exist) and you can specify an extens-ion to add to the filename of each converted image (`"img.jpg" + ext "_scaled" = "img_scaled.png"`)

Both methods support placeholders `<scale>` and `<noise>` which will be replaced by the current scaling and noise levels.


# Building
Prerequisites:
* [waifu2x-cpp-converter](https://github.com/DeadSix27/waifu2x-converter-cpp)
* [AutoHotKey_L (1.1)](https://www.autohotkey.com/download/)

Run the AutoHotKey2exe compiler:

```
"C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe" /in waifu2x.ahk /out waifu2x.exe /icon compile.ico
```

# Command Line
You can pass a single or list of files to a compiled version of the GUI to open it. If you'd like processing or control over it I would recommend using the command line options on [waifu2x-cpp-converter](https://github.com/DeadSix27/waifu2x-converter-cpp).

If you have command line options you need to apply to it, you can use the option in the *Settings* menu to write extra options for each run.