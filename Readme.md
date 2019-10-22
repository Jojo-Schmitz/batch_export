This Plugin for MuseScore will go through a specified folder and in its default settings exports PDF versions of all ".mscz" files for which no up-to-date version already exists. To use the plugin, you must first install it according to the instructions in [the 1.x Handbook](http://musescore.org/node/10129), the [2.x Handbook](http://musescore.org/node/36051) or the [3.x Handbook](http://musescore.org/node/278601), then:

1. Select "Batch Convert" (formerly "Batch Export") from the Plugins menu
2. Select the in- and output format(s), or just use the default (\*.mscz to \*.pdf)
3. Decide whether or nor you want to also work on subdirectories of the one you'll select in the next step and check/uncheck the corresponding box
4. Browse to the folder containing the files you wish to export
5. Select "Choose"
6. Confirm the dialog box that shows which files have been converted

A couple of notes to be aware of:

- You may need to have a score already open in order for the Plugins menu to be active. Fixed in MuseScore 2.0+
- In MuseScore 2.0.1+ make sure you don't have a score open, that you want the plugin to process, because it won't be able to load it then.
- The scores for which files were exported may be left open in tabs. If so, you'd need to close them manually. Fixed with MuseScore 1.2+
- These open tabs will be labeled "untitled". Fixed in MuseScore 2.0+ and not an issue anymore with MuseScore 1.2+, see above
- The 2.x version of this plugin needs at least 2.0.1
- The 3.x version of this plugin needs at least 3.0.2
- If you're on macOS and the file dialog for step 4 above does not show up, try using the Mac version of the plugin which is in the branch 'mac' (for 3.0, actually that version seems to run fine in Windows too) or mac-2.x (for 2.x).
- All files processed by the plugin for MuseScore 2.0+ will be listed in the 'Recent File' menu.

These issues are fixed with the above mentioned versions, and without re-installing the plugin.

This plugin now comes with translations of the dialogs into German, French (thanks to lasconic), Spanish (thanks to jorgk), and Italian (thanks to Shoichi), for all other language settings in MuseScore, it remains English. More translations are welcome, just contact us for including them.

The idea for this plugin stems from a [question in the forum](https://musescore.org/node/12452). See also [this discussion about the 2.0 version](https://musescore.org/node/55616)
