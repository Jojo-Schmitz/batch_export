//=============================================================================
//  MuseScore
//  Linux Music Score Editor
//  $Id:$
//
//  Batch PDF Export plugin
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

var pluginName = "Batch PDF Export";

function init () {
}

function process_one (mscz) {
// generates a PDF from the specified file, if no up-to-date PDF already exists
// returns filename of generated PDF file, or empty string if no file generated

  var reg = "mscz";
  var pdf = mscz.replace(reg,"pdf");
  var msczFile = new QFileInfo(mscz);
  var pdfFile = new QFileInfo(pdf);
  var doit = false;

  if (!pdfFile.exists()) {
    doit = true;
  } else if (pdfFile.lastModified() < msczFile.lastModified()) {
    var pdfHandle = new QFile(pdf);
    if (pdfHandle.remove()) {
      doit = true;
    } else {
      QMessageBox.warning(0,pluginName,"Unable to delete "+pdf);
    }
  }
  if (doit) {
    var theScore = new Score();
    theScore.load(mscz);
    theScore.save(pdf,"pdf");
    if (typeof theScore.close === 'function') { // does not exist on some systems
      theScore.close();
    }
    return pdfFile.fileName() + "\n";
  } else {
    return "";
  }

}

function batch_pdf () {
// query user for directory
// loop through all files in folder
// process all ".mscz" files using process_one()

  var scoreList = "";

  var dirString = QFileDialog.getExistingDirectory(0,"MuseScore: Select Folder","",0);
  if (!dirString) {
    QMessageBox.warning(0,pluginName,"No folder selected");
  }

  var dir = new QDir(dirString);
  var dirIt = new QDirIterator(dir);

  while (dirIt.hasNext()) {
    var file = dirIt.next();
    if (file.match("\.mscz$")) {
      scoreList += process_one(file);
    }
  }

  if (scoreList == "") {
    scoreList = "All files up to date\n";
  } else {
    scoreList = "File exported:\n\n" + scoreList;
  }

  QMessageBox.information(0,pluginName,dirString+"\n\n"+scoreList);

}

function run () {
  batch_pdf();
}

//---------------------------------------------------------
//    menu:  defines where the function will be placed
//           in the menu structure
//---------------------------------------------------------

var mscorePlugin = {
      menu: 'Plugins.Batch PDF Export',
      init: init,
      run:  run
}

mscorePlugin;
