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

//---------------------------------------------------------
//    init
//    this function will be called on startup of
//    mscore
//---------------------------------------------------------

var pluginName = "Batch Export";
// Here you can specify which formats get exported
// by specifyiong their extensions in a commy separated list
//var formats = new Array("pdf", "xml");
var formats = new Array("pdf");

function init () {
}

function process_one (mscz, format) {
// generates a <format> file from the specified file, if no up-to-date one already exists
// returns filename of generated file, or empty string if no file generated

  var reg = "mscz";
  var target = mscz.replace(reg, format);
  var msczFile = new QFileInfo(mscz);
  var targetFile = new QFileInfo(target);
  var doit = false;

  if (!targetFile.exists())
    doit = true;
  else if (targetFile.lastModified() < msczFile.lastModified()) {
    var targetHandle = new QFile(target);
    if (targetHandle.remove())
      doit = true;
    else
      QMessageBox.warning(0, pluginName, "Unable to delete " + target);
  }
  if (doit) {
    var theScore = new Score();
    theScore.load(mscz);
    theScore.save(target, format);
    if (typeof theScore.close === 'function') // does not exist on some systems
      theScore.close();
    return targetFile.fileName() + "\n";
  }
  return "";
}

// query user for directory
// loop through all files in folder
// process all ".mscz" files using process_one()
function batch () {
  var scoreList = "";

  var dirString = QFileDialog.getExistingDirectory(0, "MuseScore: Select Folder", "", 0);
  if (!dirString) {
    QMessageBox.warning(0, pluginName, "No folder selected");
    return;
  }

  var dir = new QDir(dirString);
  var dirIt = new QDirIterator(dir);

  while (dirIt.hasNext()) {
    var file = dirIt.next();
    if (file.match("\.mscz$"))
      for(i=0; i<formats.length; i++)
        scoreList += process_one(file, formats[i]);
  }

  if (scoreList == "")
    scoreList = "All files up to date\n";
  else
    scoreList = "File exported:\n\n" + scoreList;

  QMessageBox.information(0, pluginName, dirString + "\n\n"+ scoreList);

}

function run () {
  batch();
}

//---------------------------------------------------------
//    menu:  defines where the function will be placed
//           in the menu structure
//---------------------------------------------------------

var mscorePlugin = {
      menu: 'Plugins.Batch Export',
      init: init,
      run:  run
}

mscorePlugin;
