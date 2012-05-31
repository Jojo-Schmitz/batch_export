//=============================================================================
//  MuseScore
//  Linux Music Score Editor
//  $Id:$
//
//  Batch Export plugin
//
//  Copyright (C)2008-2011 Werner Schweer and others
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License version 2.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program; if not, write to the Free Software
//  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
//=============================================================================

//
//    This is ECMAScript code (ECMA-262 aka "Java Script")
//

// Setup some global variables
var pluginName = qsTr("Batch Export");
// Here you can specify which formats get exported
// by specifying their extensions in a comma separated list
//var outFormats = new Array("pdf", "xml");
var outFormats = new Array("pdf");
// Here you can specify, which format gets imported
var inFormat = "mscz";

//---------------------------------------------------------
//    init
//    this function will be called on startup of
//    mscore
//---------------------------------------------------------

function init () {
}

// generates a <format> file from the specified file, if no up-to-date one already exists
// returns filename of generated file, or empty string if no file generated
function process_one (source, outFormat) {
  var reg = inFormat;
  var target = source.replace(reg, outFormat);
  var inFile = new QFileInfo(source);
  var targetFile = new QFileInfo(target);
  var doit = false;

  if (!targetFile.exists())
    doit = true;
  else if (targetFile.lastModified() < inFile.lastModified()) {
    var targetHandle = new QFile(target);
    if (targetHandle.remove())
      doit = true;
    else
      QMessageBox.warning(0, pluginName, qsTr("Unable to delete") + " " + target);
  }
  if (doit) {
    var theScore = new Score();
    theScore.load(source);
    theScore.save(target, outFormat);
    if (typeof theScore.close === 'function') // does not exist on some versions
      theScore.close();
    return targetFile.fileName() + "\n";
  }
  return "";
}

// query user for directory
// loop through all files in folder
// process all ".<inFormat>$" files using process_one()
// export them to <outFormats>
function run () {
  var scoreList = "";

  var dirString = QFileDialog.getExistingDirectory(0, "MuseScore: " + pluginName + ": " + qsTr("Select Folder"), "", 0);
  if (!dirString) {
    QMessageBox.warning(0, pluginName, qsTr("No folder selected"));
    return;
  }

  var dir = new QDir(dirString);
  var dirIt = new QDirIterator(dir);

  while (dirIt.hasNext()) {
    var file = dirIt.next();
    if (file.match("\." + inFormat + "$"))
      for(i=0; i<outFormats.length; i++)
        scoreList += process_one(file, outFormats[i]);
  }

  if (scoreList == "")
    scoreList = qsTr("All files up to date") + "\n";
  else
    scoreList = qsTr("File(s) exported") + ":\n\n" + scoreList;

  QMessageBox.information(0, pluginName, dirString + "\n\n" + scoreList);

}


//---------------------------------------------------------
//    menu:  defines where the function will be placed
//           in the menu structure
//---------------------------------------------------------

var mscorePlugin = {
      menu: 'Plugins.' + pluginName,
      init: init,
      run:  run
}

mscorePlugin;
