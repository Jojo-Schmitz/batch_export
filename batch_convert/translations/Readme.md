# About Translation

## Files list

- [Windows](#windows)

    ````text
    lupdate.cmd
    lrelease.cmd
    ````

- [macOS / Linux](#macos-linux)

    ```` text
    translation_utility.sh
    ````

## How to use the translation utilities

### Requirement

- These utilities needs [QT](https://qt.io) library.

### On Windows {#windows}

#### 1. Adding translation `(.ts)` files

1. Open `lupdate.cmd` in editor. (e.g, VSCode or Notepad, etc.)
2. Append your new file name to the end of the first line, in the format **locale_**_language-code_**.ts** (e.g, locale_de, local_zh-cn, etc.).
3. Double click on `lupdate.cmd` or run it in `cmd.exe`.
4. You will find the new file in the same directory as the `lupdate.cmd`.

#### 2 Start Translating

1. Right click on a `.ts` fils to open with `Qt Linguist.exe`
2. Start translating phrases.

#### 3. Updating `.qm` files

1. Just double click on `lrelease.cmd` or run it in `cmd.exe`.
2. You will find the new file in the same directory as the `lrelease.cmd`.

#### 4. Preview Your Translation

Copy and move the whole `batch_export` folder to  MuseScore `plugin` (You may check the path in MuseScore.exe, from the `main menu`: `File` &rarr; `Preferences...` &gt; `General` tab &gt; `Folders` section) to test the translation. 
You may need to adjust some phrases during this process. Then do step 2 and step 3 again.

### On Linux / macOS {#macos-linux}

Use `translation_utility.sh`.

This is a 2-in-1 utility, which enables you to process `.ts` and `.qm` files in an efficient way.

#### 1. Preparation

Before running the script, you have to assign privilege for `translation_utility.sh` using

````bash
sudo chmod u+x [/path/filename]
````

#### 2. Generating new `.ts` / Translating / Updating `.qm`

Then you can double click on it or run it in the Terminal. The instructions are shown in the UI.

After generating .ts files, the `Linguist.app` will automatically launch.

#### 3 Preview Your Translation

Copy and move the whole `batch_export` folder to  MuseScore `plugin` (You may check the path in MuseScore.app, from the `top menu`: `MuseScore` &rarr; `Preferences...` &gt; `General` tab &gt; `Folders` section) to test the translation.

You may need to adjust some phrases during this process. Then modify the translation.

#### Cannot use this utility? {#debug}

##### Command not found {#command-not-found}

1. Launch Terminal, type

    ````bash
    sudo vi ~/.bash_profile
    ````

2. Go the the last line of `.bash_profile`, then press _`i`_ to enter the **I**nsert mode of _Vim editor_. Then put following scripts into `.bash_profile`:
_(You might have to modify these scripts to adapt your systems.)_

    ````bash
    # This is an example of standard macOS settings.
    export QTDIR=$PATH:~/Qt5.15.2/5.15.2/clang_64
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$QTDIR/lib
    export PATH=$PATH:$QTDIR/bin
    ````

3. Press `esc` on your keyboard, then type `:wq` to quit from vim editor.
4. Type following command to enable the configurations.

    ````bash
    source ~/.bash_profile
    ````

5. Try to verify with following command .

    ````bash
    qmake
    lupdate
    lrelease
    ````

###### For `zsh` shell on mac

If you are using `zsh` on macOS, after you have done the steps [above](#command-not-found) you will find that you still have to do `source ~/.bash_profile` everytime after a restart of Terminal. Here is the solution:

1. Edit / Create `.zshrc` with 

    ````bash
    sudo vi ~/.zshrc
    ````

2. Add following script

   ````bash
   source ~/.bash_profile
   ````

3. Press `esc` on your keyboard, then type `:wq` to quit from vim editor.

4. Try to verify with following command .

    ````bash
    qmake
    lupdate
    lrelease
    ````

#### Adaptation

- The macOS / Linux utility (`translation_utility.sh`) has been tested on macOS 12.
- Windows users have to provide the path to lupdate/lrelease manually, so far.
