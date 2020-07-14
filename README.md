# Waifu2x AHK GUI
This is a AutoHotKey script to run a front-end for [waifu2x-cpp-converter](https://github.com/DeadSix27/waifu2x-converter-cpp).

<p align="center">
  <img src="https://raw.githubusercontent.com/Lyutria/waifu2x-gui/master/screenshot.png" />
</p>

# Usage
On first run select `waifu2x-converter-cpp.exe` that you downloaded.

Use the **Open** button to select one or more files, or drag and drop any files onto the window.

* Select a single file, and it will generate an output in the same folder with a similar name by default, or you can specify the file to save to using **Save As**.
* Select multiple files, specify a directory to output to and an extension to add to the filename of each converted image e.g.
`"img.jpg" + ext "_scaled" = "img_scaled.png"`

Both methods support the placeholders `<scale>` and `<noise>` which will be replaced by the current scaling and noise levels.

> # Nvidia Card Information
> The prebuilt version of waifu2x-converter-cpp is made for *AMD* graphics cards, in order run properly you need to set the correct processor in your command line options. Usually you can just specify `--processor 0`, but if you want to make sure it runs properly, do the following.
>
> From the command line, run:
> ```
> waifu-converter-cpp.exe --list-processor
> ```
> Pick the number from the list that has `(OpenCL)`, and then in the GUI, select *Settings,> Command Line Options* and enter:
> ```
> --processor #
> ```
> Where # is the number of the processor that had OpenCL support.

# Command Line Usage
Pass a path to one or more files and the program will open pre-populated with those files.
If you need more fine-tuned control, use the options already present in [waifu2x-cpp-converter](https://github.com/DeadSix27/waifu2x-converter-cpp).

If you have command line options to apply to a run in the GUI, use `Settings -> Command Line Options` to write any flags to apply on each run.

# Building
Prerequisites:
* [waifu2x-cpp-converter](https://github.com/DeadSix27/waifu2x-converter-cpp)
* [AutoHotKey_L (1.1)](https://www.autohotkey.com/download/)

Run the AutoHotKey2exe compiler:

```
"C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe" /in waifu2x.ahk /out waifu2x.exe /icon compile.ico
```