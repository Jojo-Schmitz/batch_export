
<p align="center"><img src="/batch_convert/batch_convert_thumbnail.png" Alt="logo" width="300" /></p>
This Plugin for MuseScore will go through a specified folder and in its default settings exports PDF versions of all ".mscz" files for which no up-to-date version already exists. To use the plugin, you must first install it according to the instructions in [the 1.x Handbook](http://musescore.org/node/10129), the [2.x Handbook](http://musescore.org/node/36051) or the [3.x Handbook](http://musescore.org/node/278601), then:


<p align="center"><img src="/demo/batch-convert.png" alt="Screenshot" width="500"/></p>


## What's new in 4.1 ?
  
It provides the following new features:
* Filter the files to convert, whether by a Regular Expression or traditional wildcard filtering. E.g. Use "Quartet*" to only convert the files starting by "quartet";
* New workflow for selecting the import and export folders : select them only if you need to change them and no longer at every conversion;
* Export the files in a folder structure based of the file properties. E.g. export all John Coltrane scores in a "John Coltrane" subfolder automatically. More on this further on.
* A Preview button to simulate how the conversion will be executed before effective execution. Handy when building the filtering options and the folder structure.
* Possibility to export the current score or the opened scores

## Usage
1. Select "Batch Convert" (formerly "Batch Export") from the Plugins menu
3. Select the in- and output format(s), or just use the default (\*.mscz to \*.pdf)
4. Decide whether or nor you want to also work on subdirectories of the one you'll select in the next step and check/uncheck the corresponding box
5. Browse to the folder containing the files you wish to export
6. Select "Convert!"
7. Confirm the dialog box that shows which files have been converted
	
### More on the _Export structure_ feature
You have define how to build the folder structure.
Accepted characters and keywords are:
* "/" as folder separator
* Any character except \%*?"<>:|
* Any of the following keywords:
	* "%TITLE%" : as defined in the score properties
	* "%LYRICIST%" : as defined in the score properties 
	* "%COMPOSER%" : as defined in the score properties
	* "%ARRANGER%" :  as defined in the score properties 
	* "%WORKNUMBER%" :  as defined in the score properties 
	* "%MOVEMENTNUMBER%" :  as defined in the score properties 
	* "%MOVEMENTTITLE%" :  as defined in the score properties 
	* "%YEAR%" :  year part of the creation date
	* "%PART%" :  "scores" or "parts" depending that a score is exported or one of its subparts
	* "%FORMAT%" : the format of exported file. E.g. "pdf"

What if a file does not provide a value for a properties used in the export structure ?
* You can either **skip** the file by **unselecting** "With missing properties"
* You can **include** the file and replace the missing property by a default string, by **selecting** "With missing properties" and providing a replacement string such as "unspecified"

Example :
In order to export all the scores in a folder named from its composer property (e.g. export all John Coltrane scores in a "John Coltrane" subfolder), use "%COMPOSER%" as folder structure.



### A couple of notes to be aware of

- You may need to have a score already open in order for the Plugins menu to be active. Fixed in MuseScore 2.0+ (and resurfaced in 4.0)
- In MuseScore 2.0.1+ make sure you don't have a score open, that you want the plugin to process, because it won't be able to load it then.
- The scores for which files were exported may be left open in tabs. If so, you'd need to close them manually. Fixed with MuseScore 1.2+
- These open tabs will be labeled "untitled". Fixed in MuseScore 2.0+ and not an issue anymore with MuseScore 1.2+, see above
- The 2.x version of this plugin needs at least 2.0.1
- The 3.x version of this plugin needs at least 3.0.2 (it shows the UI in 4.x, but doesn't convert anything yet)
- If you're on macOS and the file dialog for step 4 above does not show up, try using the Mac version of the plugin which is in the branch 'mac' (for 3.0, actually that version seems to run fine in Windows too) or mac-2.x (for 2.x).
- All files processed by the plugin for MuseScore 2.0+ will be listed in the 'Recent File' menu.

These issues are fixed with the above mentioned versions, and without re-installing the plugin.

This plugin now comes with translations of the dialogs into German, French (thanks to lasconic and JLWALTENER), Spanish (thanks to jorgk), Italian (thanks to Shoichi) and Simplified Chinese (thanks to David Copperfield), for all other language settings in MuseScore, it remains English. More translations are welcome, just contact us for including them.

The idea for this plugin stems from a [question in the forum](https://musescore.org/node/12452). See also [this discussion about the 2.0 version](https://musescore.org/node/55616)
		  

## Important
NO WARRANTY THE PROGRAM IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND...
