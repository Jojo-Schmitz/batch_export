import QtQuick 2.9
import QtQuick.Controls 1.5
import QtQuick.Layouts 1.3
import QtQuick.Dialogs 1.2 // FileDialogs
import QtQuick.Window 2.3
import Qt.labs.folderlistmodel 2.2
import Qt.labs.settings 1.0
import QtQml 2.8
import MuseScore 3.0
import FileIO 3.0

MuseScore {
    menuPath: "Plugins." + qsTr("Batch Convert") // this doesn't work, why?
    version: "3.5"
    requiresScore: false
    description: qsTr("This plugin converts multiple files from various formats"
                      + " into various formats")
    pluginType: "dialog"

    MessageDialog {
        id: versionError
        visible: false
        title: qsTr("Unsupported MuseScore Version")
        text: qsTr("This plugin needs MuseScore 3")
        onAccepted: {
            batchConvert.parent.Window.window.close();
        }
    }

    Settings {
        id: mscorePathsSettings
        category: "application/paths"
        property var myScores
    }

    onRun: {
        // check MuseScore version
        if (mscoreMajorVersion < 3) { // we should really never get here, but fail at the imports above already
            batchConvert.visible = false
            versionError.open()
        }
        else
            batchConvert.visible = true // needed for unknown reasons
    }

    //Window {
    id: batchConvert

    // `width` and `height` allegedly are not valid property names, works regardless and seems needed?!
    width: mainRow.childrenRect.width
    height: mainRow.childrenRect.height

    // Mutally exclusive in/out formats, doesn't work properly
    ExclusiveGroup { id: mscz }
    ExclusiveGroup { id: mscx }
    ExclusiveGroup { id: xml }
    ExclusiveGroup { id: mxl }
    ExclusiveGroup { id: mid }
    ExclusiveGroup { id: pdf }

    RowLayout {
        id: mainRow
        GroupBox {
            id: inFormats
            title: " " + qsTr("Input Formats") + " "
            Layout.alignment: Qt.AlignTop | Qt.AlignLeft
            //flat: true // no effect?!
            //checkable: true // no effect?!
            property var extensions: new Array
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
                    tooltip: qsTranslate("Ms::MuseScore", "MuseScore Files")
                }
                CheckBox {
                    id: inMscx
                    text: "*.mscx"
                    //exclusiveGroup: mscx
                    onClicked: {
                        if (checked && outMscx.checked)
                            outMscx.checked = false
                    }
                    tooltip: qsTranslate("Ms::MuseScore", "MuseScore Files")
                }
                CheckBox {
                    id: inMsc
                    text: "*.msc"
                    enabled: (mscoreMajorVersion < 2) ? true : false // MuseScore < 2.0
                    visible: enabled // hide if not enabled
                    tooltip: qsTranslate("Ms::MuseScore", "MuseScore Files")
                }
                CheckBox {
                    id: inXml
                    text: "*.xml"
                    //exclusiveGroup: xml
                    onClicked: {
                        if (checked && outXml.checked)
                            outXml.checked = !checked
                    }
                    tooltip: qsTranslate("Ms::MuseScore", "MusicXML Files")
                }
                CheckBox {
                    id: inMusicXml
                    text: "*.musicxml"
                    //exclusiveGroup: musicxml
                    enabled: (mscoreMajorVersion >= 3 || (mscoreMajorVersion == 2 && mscoreMinorVersion > 1)) ? true : false // MuseScore > 2.1
                    visible: enabled // hide if not enabled
                    onClicked: {
                        if (checked && outMusicXml.checked)
                            outMusicXml.checked = !checked
                    }
                    tooltip: qsTranslate("Ms::MuseScore", "MusicXML Files")
                }
                CheckBox {
                    id: inMxl
                    text: "*.mxl"
                    //exclusiveGroup: mxl
                    onClicked: {
                        if (checked && outMxl.checked)
                            outMxl.checked = false
                    }
                    tooltip: qsTranslate("Ms::MuseScore", "MusicXML Files")
                }
                CheckBox {
                    id: inMid
                    text: "*.mid"
                    //exclusiveGroup: mid
                    onClicked: {
                        if (checked && outMid.checked)
                            outMid.checked = false
                    }
                    tooltip: qsTranslate("Ms::MuseScore", "MIDI Files")
                }
                CheckBox {
                    id: inMidi
                    text: "*.midi"
                    //exclusiveGroup: midi
                    onClicked: {
                        if (checked && outMidi.checked)
                            outMidi.checked = false
                    }
                    tooltip: qsTranslate("Ms::MuseScore", "MIDI Files")
                }
                CheckBox {
                    id: inKar
                    text: "*.kar"
                    tooltip: qsTranslate("Ms::MuseScore", "MIDI Files")
                }
                CheckBox {
                    id: inMd
                    text: "*.md"
                    tooltip: qsTranslate("Ms::MuseScore", "MuseData Files")
                }
                CheckBox {
                    id: inPdf
                    text: "*.pdf"
                    enabled: false // needs OMR, MuseScore > 2.0 or > 3.5?
                    visible: enabled // hide if not enabled
                    //exclusiveGroup: pdf
                    onClicked: {
                        if (checked && outPdf.checked)
                            outPdf.checked = false
                    }
                    tooltip: qsTranslate("Ms::MuseScore", "Optical Music Recognition")
                }
                CheckBox {
                    id: inCap
                    text: "*.cap"
                    tooltip: qsTranslate("Ms::MuseScore", "Capella Files")
                }
                CheckBox {
                    id: inCapx
                    text: "*.capx"
                    tooltip: qsTranslate("Ms::MuseScore", "Capella Files")
                }
                CheckBox {
                    id: inMgu
                    text: "*.mgu"
                    tooltip: qsTranslate("Ms::MuseScore", "BB Files (experimental)")
                }
                CheckBox {
                    id: inSgu
                    text: "*.sgu"
                    tooltip: qsTranslate("Ms::MuseScore", "BB Files (experimental)")
                }
                CheckBox {
                    id: inOve
                    text: "*.ove"
                    tooltip: qsTranslate("Ms::MuseScore", "Overture / Score Writer Files (experimental)")
                }
                CheckBox {
                    id: inScw
                    text: "*.scw"
                    tooltip: qsTranslate("Ms::MuseScore", "Overture / Score Writer Files (experimental)")
                }
                CheckBox {
                    id: inBmw
                    enabled: (mscoreMajorVersion >= 4 || (mscoreMajorVersion == 3 && mscoreMinorVersion >= 5)) ? true : false // MuseScore 3.5
                    visible: enabled // hide if not enabled
                    text: "*.bmw"
                    tooltip: qsTranslate("Ms::MuseScore", "Bagpipe Music Writer Files (experimental)")
                }
                CheckBox {
                    id: inBww
                    text: "*.bww"
                    tooltip: qsTranslate("Ms::MuseScore", "Bagpipe Music Writer Files (experimental)")
                }
                CheckBox {
                    id: inGtp
                    text: "*.gtp"
                    tooltip: qsTranslate("Ms::MuseScore", "Guitar Pro")
                }
                CheckBox {
                    id: inGp3
                    text: "*.gp3"
                    tooltip: qsTranslate("Ms::MuseScore", "Guitar Pro")
                }
                CheckBox {
                    id: inGp4
                    text: "*.gp4"
                    tooltip: qsTranslate("Ms::MuseScore", "Guitar Pro")
                }
                CheckBox {
                    id: inGp5
                    text: "*.gp5"
                    tooltip: qsTranslate("Ms::MuseScore", "Guitar Pro")
                }
                CheckBox {
                    id: inGpx
                    text: "*.gpx"
                    tooltip: qsTranslate("Ms::MuseScore", "Guitar Pro")
                }
                CheckBox {
                    id: inGp
                    enabled: (mscoreMajorVersion >= 4 || (mscoreMajorVersion == 3 && mscoreMinorVersion >= 5)) ? true : false // MuseScore 3.5
                    visible: enabled // hide if not enabled
                    text: "*.gp"
                    tooltip: qsTranslate("Ms::MuseScore", "Guitar Pro")
                }
                CheckBox {
                    id: inPtb
                    enabled: (mscoreMajorVersion >= 3) ? true : false // MuseScore 3
                    visible: enabled // hide if not enabled
                    text: "*.ptb"
                    tooltip: qsTranslate("Ms::MuseScore", "Power Tab Editor Files (experimental)")
                }
                CheckBox {
                    id: inMsczComma
                    enabled: (mscoreMajorVersion >= 4 || (mscoreMajorVersion == 3 && mscoreMinorVersion >= 5)) ? true : false // MuseScore 3.5
                    visible: enabled // hide if not enabled
                    text: "*.mscz,"
                    tooltip: qsTranslate("Ms::MuseScore", "MuseScore Backup Files")
                }
                CheckBox {
                    id: inMscxComma
                    enabled: (mscoreMajorVersion >= 4 || (mscoreMajorVersion == 3 && mscoreMinorVersion >= 5)) ? true : false // MuseScore 3.5
                    visible: enabled // hide if not enabled
                    text: "*.mscx,"
                    tooltip: qsTranslate("Ms::MuseScore", "MuseScore Backup Files")
                }
            } // Column
        } // inFormats
        ColumnLayout {
            Layout.alignment: Qt.AlignTop | Qt.AlignRight
            RowLayout {
                Label {
                    text: " ===> "
                    Layout.fillWidth: true // left align (?!)
                }
                GroupBox {
                    id: outFormats
                    title: " " + qsTr("Output Formats") + " "
                    property var extensions: new Array
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
                            tooltip: qsTranslate("Ms::MuseScore", "MuseScore 3 File")
                        }
                        CheckBox {
                            id: outMscx
                            text: "*.mscx"
                            //exclusiveGroup: mscx
                            onClicked: {
                                if (checked && inMscx.checked)
                                    inMscx.checked = false
                            }
                            tooltip: qsTranslate("Ms::MuseScore", "Uncompressed MuseScore 3 File")
                        }
                        CheckBox {
                            id: outXml
                            text: "*.xml"
                            enabled: (mscoreMajorVersion == 2 && mscoreMinorVersion <= 1) ? true : false // MuseScore <= 2.1
                            //could also export to musicxml and then rename that to xml in versions after 2.1
                            visible: enabled // hide if not enabled
                            //exclusiveGroup: xml
                            onClicked: {
                                if (checked && inXml.checked)
                                    inXml.checked = false
                            }
                            tooltip: qsTranslate("Ms::MuseScore", "Uncompressed MusicXML File (outdated)")
                        }
                        CheckBox {
                            id: outMusicXml
                            text: "*.musicxml"
                            enabled: (mscoreMajorVersion >= 3 || (mscoreMajorVersion == 2 && mscoreMinorVersion > 1)) ? true : false // MuseScore > 2.1
                            //could also export to musicxml and then rename that to xml in versions after 2.1
                            visible: enabled // hide if not enabled
                            //exclusiveGroup: musicxml
                            onClicked: {
                                if (checked && inMusicXml.checked)
                                    inMusicXml.checked = false
                            }
                            tooltip: qsTranslate("Ms::MuseScore", "Uncompressed MusicXML File")
                        }
                        CheckBox {
                            id: outMxl
                            text: "*.mxl"
                            //exclusiveGroup: mxl
                            onClicked: {
                                if (checked && inMxl.checked)
                                    inMxl.checked = false
                            }
                            tooltip: qsTranslate("Ms::MuseScore", "Compressed MusicXML File")
                        }
                        CheckBox {
                            id: outMid
                            text: "*.mid"
                            //exclusiveGroup: mid
                            onClicked: {
                                if (checked && inMid.checked)
                                    inMid.checked = false
                            }
                            tooltip: qsTranslate("Ms::MuseScore", "Standard MIDI File")
                        }
                        CheckBox {
                            id: outMidi
                            enabled: (mscoreMajorVersion >= 4 || (mscoreMajorVersion == 3 && mscoreMinorVersion >= 5)) ? true : false // MuseScore 3.5
                            visible: enabled // hide if not enabled
                            text: "*.midi"
                            //exclusiveGroup: midi
                            onClicked: {
                                if (checked && inMidi.checked)
                                    inMidi.checked = false
                            }
                            tooltip: qsTranslate("Ms::MuseScore", "Standard MIDI File")
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
                            tooltip: qsTranslate("Ms::MuseScore", "PDF File")
                        }
                        CheckBox {
                            id: outPs
                            text: "*.ps"
                            enabled: (mscoreMajorVersion < 2) ? true : false // MuseScore < 2.0
                            visible: enabled // hide if not enabled
                            tooltip: qsTranslate("Ms::MuseScore", "PostStript File")
                        }
                        CheckBox {
                            id: outPng
                            text: "*.png"
                            tooltip: qsTranslate("Ms::MuseScore", "PNG Bitmap Graphic")
                        }
                        CheckBox {
                            id: outSvg
                            text: "*.svg"
                            tooltip: qsTranslate("Ms::MuseScore", "Scalable Vector Graphics")
                        }
                        CheckBox {
                            id: outLy
                            text: "*.ly"
                            enabled: (mscoreMajorVersion < 2) ? true : false // MuseScore < 2.0, or via xml2ly?
                            visible: enabled // hide if not enabled
                            tooltip: qsTranslate("Ms::MuseScore", "LilyPond Format")
                        }
                        CheckBox {
                            id: outWav
                            text: "*.wav"
                            tooltip: qsTranslate("Ms::MuseScore", "Wave Audio")
                        }
                        CheckBox {
                            id: outFlac
                            text: "*.flac"
                            tooltip: qsTranslate("Ms::MuseScore", "FLAC Audio")
                        }
                        CheckBox {
                            id: outOgg
                            text: "*.ogg"
                            tooltip: qsTranslate("Ms::MuseScore", "Ogg Vorbis Audio")
                        }
                        CheckBox { // needs lame_enc.dll
                            id: outMp3
                            text: "*.mp3"
                            tooltip: qsTranslate("Ms::MuseScore", "MP3 Audio")
                        }
                        CheckBox {
                            id: outMpos
                            text: "*.mpos"
                            enabled: (mscoreMajorVersion >= 2) ? true : false // MuseScore >= 2.0
                            visible: enabled // hide if not enabled
                            tooltip: qsTr("Positions of measures (XML)")
                        }
                        CheckBox {
                            id: outSpos
                            text: "*.spos"
                            enabled: (mscoreMajorVersion >= 2) ? true : false // MuseScore >= 2.0
                            visible: enabled // hide if not enabled
                            tooltip: qsTr("Positions of segments (XML)")
                        }
                        CheckBox {
                            id: outMlog
                            text: "*.mlog"
                            tooltip: qsTr("Internal file sanity check log (JSON)")
                        }
                        CheckBox {
                            id: outMetaJson
                            text: "*.metajson"
                            tooltip: qsTr("Metadata JSON")
                        }
                    } //Column
                } //outFormats
            } // RowLayout
            CheckBox {
                id: exportExcerpts
                text: /*qsTr("Export linked parts")*/ qsTranslate("action", "Export parts")
                enabled: (mscoreMajorVersion == 3 && mscoreMinorVersion > 0 || (mscoreMinorVersion == 0 && mscoreUpdateVersion > 2)) ? true : false // MuseScore > 3.0.2
                visible: enabled //  hide if not enabled
            } // exportExcerpts
            CheckBox {
                id: traverseSubdirs
                text: qsTr("Process\nSubdirectories")
            } // traverseSubdirs
            CheckBox {
                id: differentExportPath
                // Only allow different export path if not traversing subdirs.
                // Would be better disabled than invisible, but couldn't find the way to change to disabled color,
                // and having the same enabled and disabled is very confusing.
                visible: !traverseSubdirs.checked
                text: qsTr("Different Export\nPath")
            } // differentExportPath
            Button {
                id: reset
                text: /*qsTr("Reset to Defaults")*/ qsTranslate("QPlatformTheme", "Restore Defaults")
                onClicked: {
                    resetDefaults()
                } // onClicked
            } // reset
            GroupBox {
                id: cancelOk
                Layout.alignment: Qt.AlignBottom | Qt.AlignRight
                Row {
                    Button {
                        id: ok
                        text: /*qsTr("Ok")*/ qsTranslate("QPlatformTheme", "OK")
                        //isDefault: true // needs more work
                        onClicked: {
                            if (collectInOutFormats())
                                sourceFolderDialog.open()
                        } // onClicked
                    } // ok
                    Button {
                        id: cancel
                        text: /*qsTr("Cancel")*/ qsTranslate("QPlatformTheme", "Cancel")
                        onClicked: {
                            batchConvert.parent.Window.window.close();
                        }
                    } // Cancel
                } // Row
            } // cancelOk
        } // ColumnLayout
    } // RowLayout
    //} // Window
    // remember settings
    Settings {
        id: settings
        category: "BatchConvertPlugin"
        // in options
        property alias inMscz:  inMscz.checked
        property alias inMscx:  inMscx.checked
        property alias inMsc:   inMsc.checked
        property alias inXml:   inXml.checked
        property alias inMusicXml: inMusicXml.checked
        property alias inMxl:   inMxl.checked
        property alias inMid:   inMid.checked
        property alias inMidi:  inMidi.checked
        property alias inKar:   inKar.checked
        property alias inMd:    inMd.checked
        property alias inPdf:   inPdf.checked
        property alias inCap:   inCap.checked
        property alias inCapx:  inCapx.checked
        property alias inMgu:   inMgu.checked
        property alias inSgu:   inSgu.checked
        property alias inOve:   inOve.checked
        property alias inScw:   inScw.checked
        property alias inBmw:   inBmw.checked
        property alias inBww:   inBww.checked
        property alias inGtp:   inGtp.checked
        property alias inGp3:   inGp3.checked
        property alias inGp4:   inGp4.checked
        property alias inGp5:   inGp5.checked
        property alias inGpx:   inGpx.checked
        property alias inGp:    inGp.checked
        property alias inPtb:   inPtb.checked
        property alias inMsczComma: inMsczComma.checked
        property alias inMscxComma: inMscxComma.checked
        // out options
        property alias outMscz: outMscz.checked
        property alias outMscx: outMscx.checked
        property alias outXml:  outXml.checked
        property alias outMusicXml: outMusicXml.checked
        property alias outMxl:  outMxl.checked
        property alias outMid:  outMid.checked
        property alias outMidi: outMidi.checked
        property alias outPdf:  outPdf.checked
        property alias outPs:   outPs.checked
        property alias outPng:  outPng.checked
        property alias outSvg:  outSvg.checked
        property alias outLy:   outLy.checked
        property alias outWav:  outWav.checked
        property alias outFlac: outFlac.checked
        property alias outOgg:  outOgg.checked
        property alias outMp3:  outMp3.checked
        property alias outMpos: outMpos.checked
        property alias outSpos: outSpos.checked
        property alias outMlog: outMlog.checked
        property alias outMetaJson: outMetaJson.checked
        // other options
        property alias exportE: exportExcerpts.checked
        property alias travers: traverseSubdirs.checked
        property alias diffEPath: differentExportPath.checked  // different export path
        property alias iPath: mscorePathsSettings.myScores // import path
        property alias ePath: mscorePathsSettings.myScores // export path
    }

    FileDialog {
        id: sourceFolderDialog
        title: traverseSubdirs.checked ?
                   qsTr("Select Sources Startfolder"):
                   qsTr("Select Sources Folder")
        selectFolder: true
        folder: "file:///" + settings.ipath // transform to URL

        onAccepted: {
            if (differentExportPath.checked && !traverseSubdirs.checked)
                targetFolderDialog.open(); // work we be called from within the target folder dialog
            else
                work()
        }
        onRejected: {
            console.log("No source folder selected")
            batchConvert.parent.Window.window.close();
        }

        Component.onDestruction: {
            settings.ipath = sourceFolderDialog.folder
        }
    } // sourceFolderDialog
    
    FileDialog {
        id: targetFolderDialog
        title: qsTr("Select Target Folder")
        selectFolder: true

        folder: "file:///" + settings.epath // transform to URL

        property string folderPath: ""
        onAccepted: {
            // remove the file:/// at the beginning of the return value of targetFolderDialog.folder
            // However, what needs to be done depends on the platform.
            // See this stackoverflow post for more details:
            // https://stackoverflow.com/questions/24927850/get-the-path-from-a-qml-url
            if (folder.toString().indexOf("file:///") != -1) // startsWith is EcmaScript6, so not for now
                folderPath = folder.toString().substring(folder.toString().charAt(9) === ':' ? 8 : 7)
            else
                folderPath = folder
            work()
        }

        onRejected: {
            console.log("No target folder selected")
            batchConvert.parent.Window.window.close();
        }
        Component.onDestruction: {
            settings.epath = targetFolderDialog.folder
        }
    } // targetFolderDialog

    function resetDefaults() {
        inMscx.checked = inXml.checked = inMusicXml.checked = inMxl.checked = inMid.checked =
                inMidi.checked = inKar.checked = inMd.checked = inPdf.checked = inCap.checked =
                inCapx.checked = inMgu.checked = inSgu.checked = inOve.checked = inScw.checked =
                inBmw.checked = inBww.checked = inGp4.checked = inGp5.checked = inGpx.checked =
                inGp.checked = inPtb.checked = inMsczComma.checked = inMscxComma.checked = false
        outMscz.checked = outMscx.checked = outXml.checked = outMusicXml.checked = outMxl.checked =
                outMid.checked = outMidi.checked = outPdf.checked = outPs.checked = outPng.checked =
                outSvg.checked = outLy.checked = outWav.checked = outFlac.checked =
                outOgg.checked = outMp3.checked = outMpos.checked = outSPos.checked =
                outMLog.checked = outMetaJson.checked = false
        traverseSubdirs.checked = false
        exportExcerpts.checked = false
        // 'uncheck' everything, then 'check' the next few
        inMscz.checked = outPdf.checked = true
        differentExportPath.checked = false
    } // resetDefaults

    function collectInOutFormats() {
        if (inMscz.checked) inFormats.extensions.push("mscz")
        if (inMscx.checked) inFormats.extensions.push("mscx")
        if (inXml.checked)  inFormats.extensions.push("xml")
        if (inMusicXml.checked) inFormats.extensions.push("musicxml")
        if (inMxl.checked)  inFormats.extensions.push("mxl")
        if (inMid.checked)  inFormats.extensions.push("mid")
        if (inMidi.checked) inFormats.extensions.push("midi")
        if (inKar.checked)  inFormats.extensions.push("kar")
        if (inMd.checked)   inFormats.extensions.push("md")
        if (inPdf.checked)  inFormats.extensions.push("pdf")
        if (inCap.checked)  inFormats.extensions.push("cap")
        if (inCapx.checked) inFormats.extensions.push("capx")
        if (inMgu.checked)  inFormats.extensions.push("mgu")
        if (inSgu.checked)  inFormats.extensions.push("sgu")
        if (inOve.checked)  inFormats.extensions.push("ove")
        if (inScw.checked)  inFormats.extensions.push("scw")
        if (inBmw.checked)  inFormats.extensions.push("bmw")
        if (inBww.checked)  inFormats.extensions.push("bww")
        if (inGtp.checked)  inFormats.extensions.push("gtp")
        if (inGp3.checked)  inFormats.extensions.push("gp3")
        if (inGp4.checked)  inFormats.extensions.push("gp4")
        if (inGp5.checked)  inFormats.extensions.push("gp5")
        if (inGpx.checked)  inFormats.extensions.push("gpx")
        if (inGp.checked)   inFormats.extensions.push("gp")
        if (inPtb.checked)  inFormats.extensions.push("ptb")
        if (inMsczComma.checked) inFormats.extensions.push("mscz,")
        if (inMscxComma.checked) inFormats.extensions.push("mscx,")
        if (!inFormats.extensions.length)
            console.log("No input format selected")

        if (outMscz.checked) outFormats.extensions.push("mscz")
        if (outMscx.checked) outFormats.extensions.push("mscx")
        if (outXml.checked)  outFormats.extensions.push("xml")
        if (outMusicXml.checked) outFormats.extensions.push("musicxml")
        if (outMxl.checked)  outFormats.extensions.push("mxl")
        if (outMid.checked)  outFormats.extensions.push("mid")
        if (outMidi.checked) outFormats.extensions.push("midi")
        if (outPdf.checked)  outFormats.extensions.push("pdf")
        if (outPs.checked)   outFormats.extensions.push("ps")
        if (outPng.checked)  outFormats.extensions.push("png")
        if (outSvg.checked)  outFormats.extensions.push("svg")
        if (outLy.checked)   outFormats.extensions.push("ly")
        if (outWav.checked)  outFormats.extensions.push("wav")
        if (outFlac.checked) outFormats.extensions.push("flac")
        if (outOgg.checked)  outFormats.extensions.push("ogg")
        if (outMp3.checked)  outFormats.extensions.push("mp3")
        if (outMpos.checked) outFormats.extensions.push("mpos")
        if (outSpos.checked) outFormats.extensions.push("spos")
        if (outMlog.checked) outFormats.extensions.push("mlog")
        if (outMetaJson.checked) outFormats.extensions.push("metajson")
        if (!outFormats.extensions.length)
            console.log("No output format selected")

        return (inFormats.extensions.length && outFormats.extensions.length)
    } // collectInOutFormats

    // flag for abort request
    property bool abortRequested: false

    // dialog to show progress
    Dialog {
        id: workDialog
        modality: Qt.ApplicationModal
        visible: false
        width: 720
        standardButtons: StandardButton.Abort

        Label {
            id: currentStatus
            width: 600
            text: qsTr("Running...")
        }

        TextArea {
            id: resultText
            width: 700
            height: 250
            anchors {
                top: currentStatus.bottom
                topMargin: 5
            }
        }

        onAccepted: {
            Qt.quit()
        }

        onRejected: {
            abortRequested = true
            batchConvert.parent.Window.window.close();
        }
    }

    function inInputFormats(suffix) {
        var found = false

        for (var i = 0; i < inFormats.extensions.length; i++) {
            if (inFormats.extensions[i].toUpperCase() === suffix.toUpperCase()) {
                found = true
                break
            }
        }
        return found
    }

    // createDefaultFileName
    // remove some special characters in a score title
    // when creating a file name
    function createDefaultFileName(fn) {
        fn = fn.trim()
        fn = fn.replace(/ /g,"_")
        fn = fn.replace(/\n/g,"_")
        fn = fn.replace(/[\\\/:\*\?\"<>|]/g,"_")
        return fn
    }

    // global list of folders to process
    property var folderList
    // global list of files to process
    property var fileList
    // global list of linked parts to process
    property var excerptsList

    // variable to remember current parent score for parts
    property var curBaseScore

    // FolderListModel can be used to search the file system
    FolderListModel {
        id: files
    }

    FileIO {
        id: fileExcerpt
    }
    
    FileIO {
        id: fileScore // We need two because they they are used from 2 different processes,
        // which could cause threading problems
    }

    Timer {
        id: excerptTimer
        interval: 1
        running: false

        // this function processes one linked part and
        // gives control back to Qt to update the dialog
        onTriggered: {
            var curScoreInfo = excerptsList.shift()
            var thisScore = curScoreInfo[0].partScore
            var partTitle = curScoreInfo[0].title
            var filePath = curScoreInfo[1]
            var fileName = curScoreInfo[2]
            var srcModifiedTime = curScoreInfo[3]

            // create full file path for part
            var targetBase;
            if (differentExportPath.checked && !traverseSubdirs.checked)
                targetBase = targetFolderDialog.folderPath + "/" + fileName
                        + "-" + createDefaultFileName(partTitle) + "."
            else
                targetBase = filePath + fileName + "-" + createDefaultFileName(partTitle) + "."

            // write for all target formats
            for (var j = 0; j < outFormats.extensions.length; j++) {
                // get modification time of destination file (if it exists)
                // modifiedTime() will return 0 for non-existing files
                // if src is newer than existing write this file
                fileExcerpt.source = targetBase + outFormats.extensions[j]
                if (srcModifiedTime > fileExcerpt.modifiedTime()) {
                    var res = writeScore(thisScore, fileExcerpt.source, outFormats.extensions[j])
                    if (res)
                        resultText.append("%1 → %2".arg(fileExcerpt.source).arg(outFormats.extensions[j]))
                    else
                        resultText.append(qsTr("Error: %1 → %2 not exported").arg(fileExcerpt.source).arg(outFormats.extensions[j]))
                }
                else // file already up to date
                    resultText.append(qsTr("%1 is up to date").arg(fileExcerpt.source))
            }

            // check if more files
            if (!abortRequested && excerptsList.length > 0)
                excerptTimer.running = true
            else {
                // close base score
                closeScore(curBaseScore)
                processTimer.running = true
            }
        }
    }

    Timer {
        id: processTimer
        interval: 1
        running: false

        // this function processes one file and then
        // gives control back to Qt to update the dialog
        onTriggered: {
            if (fileList.length === 0) {
                // no more files to process
                workDialog.standardButtons = StandardButton.Ok
                if (!abortRequested)
                    currentStatus.text = /*qsTr("Done.")*/ qsTranslate("QWizzard", "Done") + "."
                else
                    console.log("abort!")
                return
            }

            var curFileInfo = fileList.shift()
            var filePath = curFileInfo[0]
            var fileName = curFileInfo[1]
            var fileExt = curFileInfo[2]

            var fileFullPath = filePath + fileName + "." + fileExt

            // read file
            var thisScore = readScore(fileFullPath, true)

            // make sure we have a valid score
            if (thisScore) {
                // get modification time of source file
                fileScore.source = fileFullPath
                var srcModifiedTime = fileScore.modifiedTime()
                // write for all target formats
                for (var j = 0; j < outFormats.extensions.length; j++) {
                    if (differentExportPath.checked && !traverseSubdirs.checked)
                        fileScore.source = targetFolderDialog.folderPath + "/" + fileName + "." + outFormats.extensions[j]
                    else
                        fileScore.source = filePath + fileName + "." + outFormats.extensions[j]

                    // get modification time of destination file (if it exists)
                    // modifiedTime() will return 0 for non-existing files
                    // if src is newer than existing write this file
                    if (srcModifiedTime > fileScore.modifiedTime()) {
                        var res = writeScore(thisScore, fileScore.source, outFormats.extensions[j])

                        if (res)
                            resultText.append("%1 → %2".arg(fileFullPath).arg(outFormats.extensions[j]))
                        else
                            resultText.append(qsTr("Error: %1 → %2 not exported").arg(fileFullPath).arg(outFormats.extensions[j]))
                    }
                    else
                        resultText.append(qsTr("%1 is up to date").arg(fileFullPath))
                }
                // check if we are supposed to export parts
                if (exportExcerpts.checked) {
                    // reset list
                    excerptsList = []
                    // do we have excertps?
                    var excerpts = thisScore.excerpts
                    for (var ex = 0; ex < excerpts.length; ex++) {
                        if (excerpts[ex].partScore !== thisScore) // only list when not base score
                            excerptsList.push([excerpts[ex], filePath, fileName, srcModifiedTime])
                    }
                    // if we have files start timer
                    if (excerpts.length > 0) {
                        curBaseScore = thisScore // to be able to close this later
                        excerptTimer.running = true
                        return
                    }
                }
                closeScore(thisScore)
            }
            else
                resultText.append(qsTr("ERROR reading file %1").arg(fileName))

            // next file
            if (!abortRequested)
                processTimer.running = true
        }
    }

    // FolderListModel returns what Qt calles the
    // completeSuffix for "fileSuffix" which means everything
    // that follows the first '.' in a file name. (e.g. 'tar.gz')
    // However, this is not what we want:
    // For us the suffix is the part after the last '.'
    // because some users have dots in their file names.
    // Qt::FileInfo::suffix() would get this, but seems not
    // to be available in FolderListModel.
    // So, we need to do this ourselves:
    function getFileSuffix(fileName) {

        var n = fileName.lastIndexOf(".");
        var suffix = fileName.substring(n+1);

        return suffix
    }

    // This timer contains the function that will be called
    // once the FolderListModel is set.
    Timer {
        id: collectFiles
        interval: 25
        running: false

        // Add all files found by FolderListModel to our list
        onTriggered: {
            // to be able to show what we're doing
            // we must create a list of files to process
            // and then use a timer to do the work
            // otherwise, the dialog window will not update

            for (var i = 0; i < files.count; i++) {

                // if we have a directory, we're supposed to
                // traverse it, so add it to folderList
                if (files.isFolder(i))
                    folderList.push(files.get(i, "fileURL"))
                else if (inInputFormats(getFileSuffix(files.get(i, "fileName")))) {
                    // found a file to process
                    // set file names for in and out files

                    // We need 3 things:
                    // 1) The file path: C:/Path/To/
                    // 2) The file name:            my_score
                    //                                      .
                    // 3) The file's extension:              mscz

                    var fln = files.get(i, "fileName") // returns  "my_score.mscz"
                    var flp = files.get(i, "filePath") // returns  "C:/Path/To/my_score.mscz"

                    var fileExt  = getFileSuffix(fln);  // mscz
                    var fileName = fln.substring(0, fln.length - fileExt.length - 1)
                    var filePath = flp.substring(0, flp.length - fln.length)

                    /// in doubt uncomment to double check
                    // console.log("fln", fln)
                    // console.log("flp", flp)
                    // console.log("fileExt", fileExt)
                    // console.log("fileName", fileName)
                    // console.log("filePath", filePath)

                    fileList.push([filePath, fileName, fileExt])
                }
            }

            // if folderList is non-empty we need to redo this for the next folder
            if (folderList.length > 0) {
                files.folder = folderList.shift()
                // restart timer for folder search
                collectFiles.running = true
            } else if (fileList.length > 0) {
                // if we found files, start timer do process them
                processTimer.running = true
            }
            else {
                // we didn't find any files
                // report this
                resultText.append(qsTr("No files found"))
                workDialog.standardButtons = StandardButton.Ok
                currentStatus.text = /*qsTr("Done.")*/ qsTranslate("QWizzard", "Done") + "."
            }
        }
    }

    function work() {
        console.log((traverseSubdirs.checked? "Sources Startfolder: ":"Sources Folder: ")
                    + sourceFolderDialog.folder)

        if (differentExportPath.checked && !traverseSubdirs.checked)
            console.log("Export folder: " + targetFolderDialog.folderPath)

        // initialize global variables
        fileList = []
        folderList = []

        // set folder and filter in FolderListModel
        files.folder = sourceFolderDialog.folder

        if (traverseSubdirs.checked) {
            files.showDirs = true
            files.showFiles = true
        }
        else {
            // only look for files
            files.showFiles = true
            files.showDirs = false
        }

        // wait for FolderListModel to update
        // therefore we start a timer that will
        // wait for 25 millis and then start working
        collectFiles.running = true
        workDialog.visible = true
    } // work
} // MuseScore
