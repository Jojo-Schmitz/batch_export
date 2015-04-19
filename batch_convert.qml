import QtQuick 2.2
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.2 // FileDialog
import Qt.labs.folderlistmodel 2.1
import QtQml 2.2
import MuseScore 1.0
import FileIO 1.0

MuseScore {
  menuPath: "Plugins." + qsTr("Batch Convert")
  version: "2.0"
  description: qsTr("This plugin converts mutiple files from various formats"
    + " into various formats")

  onRun: { 
    setPrefs()
    }

  Dialog {
    id: window
    visible: true
    title: qsTr("Choose Formats")
    contentItem: Rectangle {
      implicitWidth: 230
      implicitHeight: 440
      color: "lightgrey"

      // Mutally exclusive in/out formats, doesn't work properly
      ExclusiveGroup { id: mscz }
      ExclusiveGroup { id: mscx }
      ExclusiveGroup { id: xml }
      ExclusiveGroup { id: mxl }
      ExclusiveGroup { id: mid }
      ExclusiveGroup { id: pdf }

      RowLayout {
        GroupBox {
          id: inFormats
          title: qsTr("Input Formats") // doesn't show?!
          //flat: true // no effect?!
          //checkable: true // no effect?!
          property var extensions: new Array()
          Column {
          spacing: 1
            CheckBox {
              id: inMscz
              text: "*.mscz"
              checked: true
              //exclusiveGroup: mscz  // doesn't work?!
              onClicked: {
                if (checked && outMscz.checked)
                  outMscz.checked = false
                }
              }
            CheckBox {
              id: inMscx
              text: "*.mscx"
              //exclusiveGroup: mscx
              onClicked: {
                if (checked && outMscx.checked)
                  outMscx.checked = false
                }
              }
            CheckBox {
              id: inMsc
              text: "*.msc"
              enabled: false
              visible: false // < 2.0
              }
            CheckBox {
              id: inXml
              text: "*.xml"
              //exclusiveGroup: xml
              onClicked: {
                if (checked && outMscz.checked)
                  outXml.checked = !checked
                }
              }
            CheckBox {
              id: inMxl
              text: "*.mxl"
              //exclusiveGroup: mxl
              onClicked: {
                if (checked && outMxl.checked)
                  outMxl.checked = false
                }
              }
            CheckBox {
              id: inMid
              text: "*.mid"
              //exclusiveGroup: mid
              onClicked: {
                if (checked && outMid.checked)
                outMid.checked = false
                }
              }
            CheckBox {
              id: inPdf
              text: "*.pdf"
              enabled: false // needs OMR, MuseScore > 2.0?
              visible: false // hide it
              //exclusiveGroup: pdf
              onClicked: {
                if (checked && outPdf.checked)
                  outPdf.checked = false
                }
              }
            CheckBox {
              id: inMidi
              text: "*.midi"
              }
            CheckBox {
              id: inKar
              text: "*.kar"
              }
            CheckBox {
              id: inCap
              text: "*.cap"
              }
            CheckBox {
              id: inCapx
              text: "*.capx"
              }
            CheckBox {
              id: inBww
              text: "*.bww"
              }
            CheckBox {
              id: inMgu
              text: "*.mgu"
              }
            CheckBox {
              id: inSgu
              text: "*.sgu"
              }
            CheckBox {
              id: inOve
              text: "*.ove"
              }
            CheckBox {
              id: inScw
              text: "*.scw"
            }
            CheckBox {
              id: inGTP
              text: "*.GTP"
              }
            CheckBox {
              id: inGP3
              text: "*.GP3"
              }
            CheckBox {
              id: inGP4
              text: "*.GP4"
              }
            CheckBox {
              id: inGP5
              text: "*.GP5"
              }
            } // Column
          } // inFormats
        ColumnLayout {
          RowLayout {
            Label {
              text: "===>"
              }
            GroupBox {
              id: outFormats
              title: qsTr("Output Formats") // doesn't show
              property var extensions: new Array()
              Column {
                spacing: 1
                CheckBox {
                  id: outMscz
                  text: "*.mscz"
                  //exclusiveGroup: mscz
                  onClicked: {
                    if (checked && inMscz.checked)
                      inMscz.checked = false
                    }
                  }
                CheckBox {
                  id: outMscx
                  text: "*.mscx"
                  //exclusiveGroup: mscx
                  onClicked: {
                    if (checked && inMscx.checked)
                      inMscx.checked = false
                    }
                  }
                CheckBox {
                  id: outXml
                  text: "*.xml"
                  //exclusiveGroup: xml
                  onClicked: {
                    if (checked && inXml.checked)
                      inXml.checked = false
                    }
                  }
                CheckBox {
                  id: outMxl
                  text: "*.mxl"
                  //exclusiveGroup: mxl
                  onClicked: {
                    if (checked && inMxl.checked)
                      inMxl.checked = false
                    }
                  }
                CheckBox {
                  id: outMid
                  text: "*.mid"
                  //exclusiveGroup: mid
                  onClicked: {
                    if (checked && inMid.checked)
                      inMid.checked = false
                    }
                  }
                CheckBox {
                  id: outPdf
                  text: "*.pdf"
                  checked: true
                  //exclusiveGroup: pdf
                  onClicked: {
                    if (checked && inPdf.checked)
                      inPdf.checked = false
                    }
                  }
                CheckBox {
                  id: outPs
                  text: "*.ps"
                  }
                CheckBox {
                  id: outPng
                  text: "*.png"
                  }
                CheckBox {
                  id: outSvg
                  text: "*.svg"
                  }
                CheckBox {
                  id: outLy
                  text: "*.ly"
                  enabled: false // < 2.0, or via xml2ly?
                  visible: false //  hide it
                  }
                CheckBox {
                  id: outWav
                  text: "*.wav"
                  }
                CheckBox {
                  id: outFlac
                  text: "*.flac"
                  }
                CheckBox {
                  id: outOgg
                  text: "*.ogg"
                  }
                CheckBox { // needs lame_enc.dll
                  id: outMp3
                  text: "*.mp3"
                  }
                } //Column
              } //outFormats
            } // RowLayout
          Label {} // Spacer
          CheckBox {
            id: traverseSubdirs
            text: qsTr("Process\nSubdirectories")
            enabled: false // grayed out
            opacity: 0.5   // not yet implemented
            } // traverseSubdirs
          Button {
            id: reset
            text: qsTr("Reset to Defaults")
            onClicked: {
              resetDefaults()
              } // onClicked
            } // reset
          GroupBox {
            id: cancelOk
            Row {
              Button {
                id: ok
                text: qsTr("Ok")
                //isDefault: true // needs more work
                onClicked: {
                  window.visible = false
                  if (collectInOutFormats())
                    fileDialog.open()
                  } // onClicked
                } // ok
              Button {
                id: cancel
                text: qsTr("Cancel")
                onClicked: {
                  window.visible = false
                  Qt.quit()
                  }
                } // Cancel
              } // Row
            } // cancelOk
          } // ColumnLayout
        } // RowLayout
    } // ContentItem
  } // Dialog

  FileDialog {
    id: fileDialog
    title: traverseSubdirs.checked?
      qsTr("Select Startfolder"):
      qsTr("Select Folder")
    selectFolder: true
    onAccepted: {
      work(folder, traverseSubdirs.checked)
      }
    onRejected: {
      console.log(qsTr("No folder selected"))
      Qt.quit()
      }
    } // fileDialog

  function setPrefs() {
    resetDefaults() // TODO
    } // setPrefs

  function resetDefaults() {
    inMscx.checked = inXml.checked = inMxl.checked = inMid.checked =
      inPdf.checked = inMidi.checked = inKar.checked = inCap.checked =
      inCapx.checked = inBww.checked = inMgu.checked = inSgu.checked =
      inOve.checked = inScw.checked = inGTP.checked = inGP3.checked =
      inGP4.checked = inGP5.checked = false
    outMscz.checked = outMscx.checked = outXml.checked = outMxl.checked =
      outMid.checked = outPdf.checked = outPs.checked = outPng.checked =
      outSvg.checked = outLy.checked = outWav.checked = outFlac.checked =
      outOgg.checked = outMp3.checked = false
    traverseSubdirs.checked = false
    // 'uncheck' everything, then 'check' the next few
    inMscz.checked = outPdf.checked = true
    } // resetDefaults

  function collectInOutFormats() {
    if (inMscz.checked) inFormats.extensions.push("mscz")
    if (inMscx.checked) inFormats.extensions.push("mscx")
    if (inXml.checked)  inFormats.extensions.push("xml")
    if (inMxl.checked)  inFormats.extensions.push("mxl")
    if (inMid.checked)  inFormats.extensions.push("mid")
    if (inPdf.checked)  inFormats.extensions.push("pdf")
    if (inMidi.checked) inFormats.extensions.push("midi")
    if (inKar.checked)  inFormats.extensions.push("kar")
    if (inCap.checked)  inFormats.extensions.push("cap")
    if (inCapx.checked) inFormats.extensions.push("capx")
    if (inBww.checked)  inFormats.extensions.push("bww")
    if (inMgu.checked)  inFormats.extensions.push("mgu", "MGU")
    if (inSgu.checked)  inFormats.extensions.push("sgu", "SGU")
    if (inOve.checked)  inFormats.extensions.push("ove")
    if (inScw.checked)  inFormats.extensions.push("scw")
    if (inGTP.checked)  inFormats.extensions.push("GTP")
    if (inGP3.checked)  inFormats.extensions.push("GP3")
    if (inGP4.checked)  inFormats.extensions.push("GP4")
    if (inGP5.checked)  inFormats.extensions.push("GP5")
    if (!inFormats.extensions.length)
      console.log("No input format selected")

    if (outMscz.checked) outFormats.extensions.push("mscz")
    if (outMscx.checked) outFormats.extensions.push("mscx")
    if (outXml.checked)  outFormats.extensions.push("xml")
    if (outMxl.checked)  outFormats.extensions.push("mxl")
    if (outMid.checked)  outFormats.extensions.push("mid")
    if (outPdf.checked)  outFormats.extensions.push("pdf")
    if (outPs.checked)   outFormats.extensions.push("ps")
    if (outPng.checked)  outFormats.extensions.push("png")
    if (outSvg.checked)  outFormats.extensions.push("svg")
    if (outLy.checked)   outFormats.extensions.push("ly")
    if (outWav.checked)  outFormats.extensions.push("wav")
    if (outFlac.checked) outFormats.extensions.push("flac")
    if (outOgg.checked)  outFormats.extensions.push("ogg")
    if (outMp3.checked)  outFormats.extensions.push("mp3")
    if (!outFormats.extensions.length)
      console.log("No output format selected")

    return (inFormats.extensions.length && outFormats.extensions.length)
    } // collectInOutFormats

  // flag for abort request
  property bool abortRequested: false

  // dialog to show progress
  Dialog {
    id: workDialog
    visible: false

    contentItem: Rectangle {
      id: workContent
      implicitWidth: 500
      implicitHeight: 300
      color: "lightgrey"

      Label {
        id: currentStatus
        width: parent.width
        text: "Running..."   // TODO: use translation
        }

      TextArea {
        id: resultText
        width: parent.width
        height: 250
        anchors {
          top: currentStatus.bottom
          topMargin: 5
          }
        }
      Button {
        id: abortButton
        text: "Abort"        // TODO: use translation
        anchors {
          top: resultText.bottom
          topMargin: 5
          right: workContent.right
          rightMargin: 10
          }
        onClicked: {
          workDialog.visible = false
	  abortRequested = true
          Qt.quit()
          }
        }
      }
    }

  // global list of files to process
  property var fileList

  // FolderListModel can be used to search the file system
  FolderListModel {
    id: files
    }

  FileIO {
    id: file
    }

  Timer {
    id: processTimer
    interval: 1
    running: false

    // this function processes one file and then
    // gives control back to QT to update the dialog
    onTriggered: {
      var curFileInfo = fileList.pop()
      var shortName = curFileInfo[0]
      var fileName = curFileInfo[1]
      var fileBase = curFileInfo[2]

      // read file
      var thisScore = readScore(fileName)

      // make sure we have a valid score
      if (thisScore) {
        // get modification time of source file
        file.source = fileName
        var srcModifiedTime = file.modifiedTime()
        // write for all target formats
        for (var j = 0; j < outFormats.extensions.length; j++) {
          var targetFile = fileBase + "." + outFormats.extensions[j]

          // get modification time of destination file (if it exists)
          // modifiedTime() will return 0 for non-existing files
          file.source = targetFile

          // if src is newer than existing write this file
          if (srcModifiedTime > file.modifiedTime()) {
             var res = writeScore(thisScore, targetFile, outFormats.extensions[j])
// TODO: use translation
             resultText.append(shortName+" -> "+outFormats.extensions[j])
          } else {
// TODO: use translation
             resultText.append(shortName+"."+outFormats.extensions[j]+" is up to date")
             }
          }
        closeScore(thisScore)
      } else {
// TODO: use translation
	resultText.append("ERROR reading file "+shortName)
        }
      
      // check if more files
      if (!abortRequested && fileList.length > 0) {
        processTimer.running = true
        } else {
        abortButton.text = "OK"          // TODO: use translation
        currentStatus.text = "Done."     // TODO: use translation
        }
      }
    }

  // This timer contains the function that will be called
  // once the FolderListModel is set.
  Timer {
    id: startWork
    interval: 25
    running: false

    // Process all files found by FolderListModel
    onTriggered: {
      // to be able to show what we're doing
      // we must create a list of files to process
      // and then use a timer to do the work
      // otherwise, the dialog window will not update

      fileList = []

      for (var i = 0; i < files.count; i++) {
        // set file names for in and out files
	var shortName = files.get(i, "fileName")
        var fileName = files.get(i, "filePath")
        var fileBase = files.folder + "/" + files.get(i, "fileBaseName")
        // remove 'file://' from beginning of fileBase
        fileBase = fileBase.substring(7, 999)

	fileList.push([shortName,fileName,fileBase]);
        }

      // start timer do process files
      processTimer.running = true
      }
    }

  function work() {
    console.log((traverseSubdirs.checked? "Startfolder: ":"Folder: ")
      + fileDialog.folder)

    if (traverseSubdirs.checked) {
      // not yet implemented
      console.log("traverseSubdirs set")
      }

    // collect inFormats.extensions for FolderListModel
    var inFilters = []

    for (var i = 0; i < inFormats.extensions.length; i++) {
      inFilters.push("*." + inFormats.extensions[i])
      }

    // set folder and filter in FolderListModel
    files.folder = fileDialog.folder
    files.nameFilters = inFilters

    // wait for FolderListModel to update
    // therefore we start a timer that will
    // wait for 25 millis and then start working
    startWork.running = true
    workDialog.visible = true

    } // work
  } // MuseScore
