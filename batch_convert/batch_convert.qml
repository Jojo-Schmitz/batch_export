import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Dialogs 1.2 // FileDialogs
import QtQuick.Window 2.3
import Qt.labs.folderlistmodel 2.2
import Qt.labs.settings 1.0
import QtQml 2.8
import MuseScore 3.0
import FileIO 3.0

/**********************
/*  2.0.1: Initial version with new UI
/*  4.1.0: Use Composer if Arranger, Lyricist, Copywriter are missing
/*  4.1.0: Error when dealing with parts of an already opened score.
/*  4.1.0: The score name was added twice to the excported file when exporting parts.
/*  4.1.0: Parts of which name starts with a "." will not be exported.
/*  4.1.0: Unnecessary folders were created when exporting parts. 
/*  4.1.0: Port to MuseScore 4.0 
/*  4.1.0: Export current score 
/*  4.1.0: Creation of folders in Windows with name without spaces was not working 
/*  4.2.0: Parts export choice
/*  4.2.0: Bug when the current score was opened on part (insread of the main score)
/*  4.2.0: Bug when the current score was new and unsaved
/*  4.2.1: Add a Apply! button in the Preview summary
/*  4.2.1: More dark mode tweaks
/*  4.2.2: Export choice was not saved in the settings
/*  4.3.0: Allow to export to dedicaded folder when parsing subdirs
/*  4.3.0: Export the main score when only the parts are to be exported and there are no parts
/*  4.3.1: New optin to rename the files
/*  4.3.1: mei support in 4.2
/*  4.3.2: prepare for 4.4
/**********************************************/
MuseScore {
    menuPath: "Plugins." + qsTr("Batch Convert")
    version: "4.3.2"
    // currently not working in MuseScore 4, so an open score is required regardless of this setting
    // see https://github.com/musescore/MuseScore/issues/13162 and https://github.com/musescore/MuseScore/pull/13582
    requiresScore: false
    description: qsTr("This plugin converts multiple files from various formats"
                      + " into various formats")
    pluginType: "dialog"

    id: batchConvert
    //4.4 title: qsTr("Batch Convert")
    //4.4 thumbnailName: "batch_convert_thumbnail.png"
    //4.4 categoryCode: "batch-processing"
    Component.onCompleted : {
        if (mscoreMajorVersion >= 4 && mscoreMinorVersion <= 3) {
            batchConvert.title = qsTr("Batch Convert");
            batchConvert.thumbnailName = "batch_convert_thumbnail.png";
            batchConvert.categoryCode = "batch-processing";
        }
    }

    MessageDialog {
        id: versionError
        visible: false
        title: qsTr("Unsupported MuseScore Version")
        text: qsTr("This plugin needs MuseScore 3 or later")
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
        if (settings.iPath==="")
            settings.iPath=mscorePathsSettings.myScores;
        if (settings.ePath==="")
            settings.ePath=settings.iPath;
        
        var lastoption = importWhat.buttons[settings.importWhat];
        if (lastoption) lastoption.checked=true;

        var lastoptionES = exportParts.buttons[settings.exportParts];
        if (lastoptionES) lastoptionES.checked=true;
    }

    // `width` and `height` allegedly are not valid property names, works regardless and seems needed?!
    width: mainRow.childrenRect.width + mainRow.anchors.margins*2
    height: mainRow.childrenRect.height + mainRow.anchors.margins*2


    // Mutally exclusive in/out formats, doesn't work properly
    ButtonGroup  { id: mscz }
    ButtonGroup  { id: mscx }
    ButtonGroup  { id: xml }
    ButtonGroup  { id: mxl }
    ButtonGroup  { id: musicxml }
    ButtonGroup  { id: mid }
    ButtonGroup  { id: midi }
    ButtonGroup  { id: pdf }
    ButtonGroup  { id: mei }

    GridLayout {
        id: mainRow
        columnSpacing: 2
        columns: 3
        anchors.margins: 10
        
        RowLayout {
            Layout.margins: 10
            Layout.alignment: Qt.AlignTop | Qt.AlignHCenter
            Layout.column: 0
            Layout.row: 0
            Layout.columnSpan: 3
            ButtonGroup {
                id: importWhat
            }
            NiceRadioButton {
                id: rdbCurrent
                text: qsTr("Export current score")
                checked: true
                ButtonGroup.group: importWhat
            }
            NiceRadioButton {
                id: rdbOpened
                text: qsTr("Export opened scores")
                ButtonGroup.group: importWhat
            }

            NiceRadioButton {
                id: rdbImport
                text: qsTr("Import")
                ButtonGroup.group: importWhat
            }
            
        }

        GroupBox {
            id: inFormats
            title: " " + qsTr("Input Formats") + " "
            Layout.margins: 10
            Layout.alignment: Qt.AlignTop | Qt.AlignLeft
            Layout.column: 0
            Layout.row: 1
            Layout.rowSpan: 1
            property var extensions: new Array
            
            // tweak dark mode
            label: Label {
                x: inFormats.leftPadding
                width: inFormats.availableWidth
                text: inFormats.title
                elide: Text.ElideRight
                    color: sysActivePalette.text // tweak dark mode
            }
    
            Grid {
                spacing: 0
                columns: 2
                flow: Flow.TopToBottom
                enabled: rdbImport.checked
                SmallCheckBox {
                    id: inMscz
                    text: "*.mscz"
                    checked: true
                    //ButtonGroup.group: mscz
                    onClicked: {
                        if (checked && outMscz.checked)
                            outMscz.checked = false
                    }
                    ToolTip.visible: hovered
                    ToolTip.text: mscoreMajorVersion > 3 ? qsTranslate("project", "MuseScore files")
                      : qsTranslate("Ms::MuseScore", "MuseScore Files")
                }
                SmallCheckBox {
                    id: inMscx
                    text: "*.mscx"
                    //ButtonGroup.group: mscx
                    onClicked: {
                        if (checked && outMscx.checked)
                            outMscx.checked = false
                    }
                    ToolTip.visible: hovered
                    ToolTip.text: mscoreMajorVersion > 3 ? qsTranslate("project", "Uncompressed MuseScore folders (experimental)")
                      : qsTranslate("Ms::MuseScore", "MuseScore Files")
                }
                SmallCheckBox {
                    id: inMsc
                    text: "*.msc"
                    visible: (mscoreMajorVersion < 2) ? true : false // MuseScore < 2.0
                    ToolTip.visible: hovered
                    ToolTip.text: qsTranslate("Ms::MuseScore", "MuseScore Files")
                }
                SmallCheckBox {
                    id: inXml
                    text: "*.xml"
                    //ButtonGroup.group: xml
                    onClicked: {
                        if (checked && outXml.checked)
                            outXml.checked = !checked
                    }
                    ToolTip.visible: hovered
                    ToolTip.text: mscoreMajorVersion > 3 ? qsTranslate("project/export", "Uncompressed MusicXML files")
                      : qsTranslate("Ms::MuseScore", "MusicXML Files")
                }
                SmallCheckBox {
                    id: inMusicXml
                    text: "*.musicxml"
                    //ButtonGroup.group: musicxml
                    visible: (mscoreMajorVersion >= 3 || (mscoreMajorVersion == 2 && mscoreMinorVersion > 1)) ? true : false // MuseScore > 2.1
                    onClicked: {
                        if (checked && outMusicXml.checked) 
                            outMusicXml.checked = !checked
                    }
                    ToolTip.visible: hovered
                    ToolTip.text: mscoreMajorVersion > 3 ? qsTranslate("project/export", "Uncompressed MusicXML files")
                      : qsTranslate("Ms::MuseScore", "MusicXML Files")
                }
                SmallCheckBox {
                    id: inMxl
                    text: "*.mxl"
                    //ButtonGroup.group: mxl
                    onClicked: {
                        if (checked && outMxl.checked)
                            outMxl.checked = false
                    }
                    ToolTip.visible: hovered
                    ToolTip.text: mscoreMajorVersion > 3 ? qsTranslate("project/export", "Compressed MusicXML files")
                      : qsTranslate("Ms::MuseScore", "MusicXML Files")
                }
                SmallCheckBox {
                    id: inMid
                    text: "*.mid"
                    //ButtonGroup.group: mid
                    onClicked: {
                        if (checked && outMid.checked)
                            outMid.checked = false
                    }
                    ToolTip.visible: hovered
                    ToolTip.text: mscoreMajorVersion > 3 ? qsTranslate("project/export", "MIDI files")
                      : qsTranslate("Ms::MuseScore", "MIDI Files")
                }
                SmallCheckBox {
                    id: inMidi
                    text: "*.midi"
                    //ButtonGroup.group: midi
                    onClicked: {
                        if (checked && outMidi.checked)
                            outMidi.checked = false
                    }
                    ToolTip.visible: hovered
                    ToolTip.text: mscoreMajorVersion > 3 ? qsTranslate("project/export", "MIDI files")
                      : qsTranslate("Ms::MuseScore", "MIDI Files")
                }
                SmallCheckBox {
                    id: inKar
                    text: "*.kar"
                    ToolTip.visible: hovered
                    ToolTip.text: mscoreMajorVersion > 3 ? qsTranslate("project/export", "MIDI files")
                     : qsTranslate("Ms::MuseScore", "MIDI Files")
                }
                SmallCheckBox {
                    id: inMd
                    text: "*.md"
                    ToolTip.visible: hovered
                    ToolTip.text: mscoreMajorVersion > 3 ? qsTranslate("project", "MuseData files")
                      : qsTranslate("Ms::MuseScore", "MuseData Files")
                }
                SmallCheckBox {
                    id: inPdf
                    text: "*.pdf"
                    visible: false // needs OMR, MuseScore > 2.0 or > 3.5 and < 4?
                    //ButtonGroup.group: pdf
                    onClicked: {
                        if (checked && outPdf.checked)
                            outPdf.checked = false
                    }
                    ToolTip.visible: hovered
                    ToolTip.text: qsTranslate("Ms::MuseScore", "Optical Music Recognition")
                }
                SmallCheckBox {
                    id: inCap
                    text: "*.cap"
                    ToolTip.visible: hovered
                    ToolTip.text: mscoreMajorVersion > 3 ? qsTranslate("project", "Capella files")
                      : qsTranslate("Ms::MuseScore", "Capella Files")
                }
                SmallCheckBox {
                    id: inCapx
                    text: "*.capx"
                    ToolTip.visible: hovered
                    ToolTip.text: mscoreMajorVersion > 3 ? qsTranslate("project", "Capella files")
                     : qsTranslate("Ms::MuseScore", "Capella Files")
                }
                SmallCheckBox {
                    id: inMgu
                    text: "*.mgu"
                    ToolTip.visible: hovered
                    ToolTip.text: mscoreMajorVersion > 3 ? qsTranslate("project", "BB files (experimental)")
                      : qsTranslate("Ms::MuseScore", "BB Files (experimental)")
                }
                SmallCheckBox {
                    id: inSgu
                    text: "*.sgu"
                    ToolTip.visible: hovered
                    ToolTip.text: mscoreMajorVersion > 3 ? qsTranslate("project", "BB files (experimental)")
                      : qsTranslate("Ms::MuseScore", "BB Files (experimental)")
                }
                SmallCheckBox {
                    id: inOve
                    text: "*.ove"
                    ToolTip.visible: hovered
                    ToolTip.text: mscoreMajorVersion > 3 ? qsTranslate("project", "Overture / Score Writer files (experimental)")
                      : qsTranslate("Ms::MuseScore", "Overture / Score Writer Files (experimental)")
                }
                SmallCheckBox {
                    id: inScw
                    text: "*.scw"
                    ToolTip.visible: hovered
                    ToolTip.text: mscoreMajorVersion > 3 ? qsTranslate("project", "Overture / Score Writer files (experimental)")
                      : qsTranslate("Ms::MuseScore", "Overture / Score Writer Files (experimental)")
                }
                SmallCheckBox {
                    id: inBmw
                    visible: ((mscoreMajorVersion > 3) || (mscoreMajorVersion == 3 && mscoreMinorVersion >= 5)) ? true : false // MuseScore 3.5
                    text: "*.bmw"
                    ToolTip.visible: hovered
                    ToolTip.text: mscoreMajorVersion > 3 ? qsTranslate("project", "Bagpipe Music Writer files (experimental)")
                      : qsTranslate("Ms::MuseScore", "Bagpipe Music Writer Files (experimental)")
                }
                SmallCheckBox {
                    id: inBww
                    text: "*.bww"
                    ToolTip.visible: hovered
                    ToolTip.text: mscoreMajorVersion > 3 ? qsTranslate("Ms::MuseScore", "Bagpipe Music Writer files (experimental)")
                      : qsTranslate("Ms::MuseScore", "Bagpipe Music Writer Files (experimental)")
                }
                SmallCheckBox {
                    id: inGtp
                    text: "*.gtp"
                    ToolTip.visible: hovered
                    ToolTip.text: mscoreMajorVersion > 3 ? qsTranslate("project", "Guitar Pro files")
                      : qsTranslate("Ms::MuseScore", "Guitar Pro")
                }
                SmallCheckBox {
                    id: inGp3
                    text: "*.gp3"
                    ToolTip.visible: hovered
                    ToolTip.text: mscoreMajorVersion > 3 ? qsTranslate("project", "Guitar Pro files")
                      : qsTranslate("Ms::MuseScore", "Guitar Pro")
                }
                SmallCheckBox {
                    id: inGp4
                    text: "*.gp4"
                    ToolTip.visible: hovered
                    ToolTip.text: mscoreMajorVersion > 3 ? qsTranslate("project", "Guitar Pro files")
                      : qsTranslate("Ms::MuseScore", "Guitar Pro")
                }
                SmallCheckBox {
                    id: inGp5
                    text: "*.gp5"
                    ToolTip.visible: hovered
                    ToolTip.text: mscoreMajorVersion > 3 ? qsTranslate("project", "Guitar Pro files")
                      : qsTranslate("Ms::MuseScore", "Guitar Pro")
                }
                SmallCheckBox {
                    id: inGpx
                    text: "*.gpx"
                    ToolTip.visible: hovered
                    ToolTip.text: mscoreMajorVersion > 3 ? qsTranslate("project", "Guitar Pro files")
                      : qsTranslate("Ms::MuseScore", "Guitar Pro")
                }
                SmallCheckBox {
                    id: inGp
                    visible: ((mscoreMajorVersion > 3) || (mscoreMajorVersion == 3 && mscoreMinorVersion >= 5)) ? true : false // MuseScore 3.5
                    text: "*.gp"
                    ToolTip.visible: hovered
                    ToolTip.text: mscoreMajorVersion > 3 ? qsTranslate("project", "Guitar Pro files")
                     : qsTranslate("Ms::MuseScore", "Guitar Pro")
                }
                SmallCheckBox {
                    id: inPtb
                    visible: (mscoreMajorVersion > 3) ? true : false // MuseScore 3
                    text: "*.ptb"
                    ToolTip.visible: hovered
                    ToolTip.text: mscoreMajorVersion > 3 ? qsTranslate("project", "Power Tab Editor files (experimental)")
                      : qsTranslate("Ms::MuseScore", "Power Tab Editor Files (experimental)")
                }
                SmallCheckBox {
                    id: inMsczComma // or inMsczBackup?
                    visible: ((mscoreMajorVersion > 3) || (mscoreMajorVersion == 3 && mscoreMinorVersion >= 5)) ? true : false // MuseScore 3.5 and later
                    text: mscoreMajorVersion > 3 ? "*.mscz~" : "*.mscz,"
                    ToolTip.visible: hovered
                    ToolTip.text: mscoreMajorVersion > 3 ? qsTranslate("project", "MuseScore backup files")
                      : qsTranslate("Ms::MuseScore", "MuseScore Backup Files")
                }
                SmallCheckBox {
                    id: inMscxComma
                    visible: (mscoreMajorVersion == 3 && mscoreMinorVersion >= 5) ? true : false // MuseScore 3.5 and 3.6 only
                    text: "*.mscx,"
                    ToolTip.visible: hovered
                    ToolTip.text: qsTranslate("Ms::MuseScore", "MuseScore Backup Files")
                }
                SmallCheckBox {
                    id: inMscs
                    visible: mscoreMajorVersion > 3 ? true : false // MuseScore 4 and later
                    text: "*.mscs"
                    ToolTip.visible: hovered
                    ToolTip.text: qsTranslate("project", "MuseScore developer files")
                }
                SmallCheckBox {
                    id: inMei
                    visible: ((mscoreMajorVersion > 4) || (mscoreMajorVersion == 4 && mscoreMinorVersion >= 2)) ? true : false // MuseScore 4.2 and later
                    //ButtonGroup.group: mei
                    onClicked: {
                        if (checked && outMei.checked)
                            outMei.checked = false
                    }
                    text: "*.mei"
                    ToolTip.visible: hovered
                    ToolTip.text: qsTranslate("project", "MEI files")
                }
            } // Column
        } // inFormats

        Label {
            Layout.column: 1
            Layout.row: 1
            Layout.fillHeight: false
            text: " ===> "
            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
        }
        GroupBox {
            id: outFormats
            Layout.column: 2
            Layout.row: 1
            Layout.alignment: Qt.AlignTop | Qt.AlignLeft
            Layout.fillHeight: false
            Layout.margins: 10
            title: " " + qsTr("Output Formats") + " "
            property var extensions: new Array

            label: Label {
                x: outFormats.leftPadding
                width: outFormats.availableWidth
                text: outFormats.title
                elide: Text.ElideRight
                color: sysActivePalette.text // tweak dark mode
            }

            Grid {
                spacing: 0
                columns: 2
                flow: Flow.TopToBottom
                SmallCheckBox {
                    id: outMscz
                    text: "*.mscz"
                    //ButtonGroup.group: mscz
                    onClicked: {
                        if (checked && inMscz.checked)
                            inMscz.checked = false
                    }
                    ToolTip.visible: hovered
                    ToolTip.text: mscoreMajorVersion > 3 ? qsTranslate("project", "MuseScore files")
                      : qsTranslate("Ms::MuseScore", "MuseScore 3 File")
                }
                SmallCheckBox {
                    id: outMscx
                    text: "*.mscx"
                    //ButtonGroup.group: mscx
                    onClicked: {
                        if (checked && inMscx.checked)
                            inMscx.checked = false
                    }
                    ToolTip.visible: hovered
                    ToolTip.text: mscoreMajorVersion > 3 ? qsTranslate("project", "Uncompressed MuseScore folders (experimental)")
                      : qsTranslate("Ms::MuseScore", "Uncompressed MuseScore 3 File")
                }
                SmallCheckBox {
                    id: outXml
                    text: "*.xml"
                    visible: (mscoreMajorVersion == 2 && mscoreMinorVersion <= 1)
                      || (mscoreMajorVersion == 3 && mscoreMinorVersion >= 5)
                      || (mscoreMajorVersion > 3) ?
                    true : false // MuseScore <= 2.1 or >= 3.5
                    //could also export to musicxml and then rename that to xml in versions after 2.1 / before 3.5
                    //ButtonGroup.group: xml
                    onClicked: {
                        if (checked && inXml.checked)
                            inXml.checked = false
                    }
                    ToolTip.visible: hovered
                    ToolTip.text: mscoreMajorVersion > 3 || (mscoreMajorVersion == 3 && mscoreMinorVersion > 5)
                      ? qsTranslate("project/export", "Uncompressed MusicXML files")
                      : qsTranslate("Ms::MuseScore", "Uncompressed MusicXML File (outdated)")
                }
                SmallCheckBox {
                    id: outMusicXml
                    text: "*.musicxml"
                    visible: (mscoreMajorVersion >= 3 || (mscoreMajorVersion == 2 && mscoreMinorVersion > 1)) ? true : false // MuseScore > 2.1
                    //could also export to musicxml and then rename that to xml in versions after 2.1
                    //exclusiveGroup: musicxml
                    onClicked: {
                        if (checked && inMusicXml.checked)
                            inMusicXml.checked = false
                    }
                    ToolTip.visible: hovered
                    ToolTip.text: mscoreMajorVersion > 3 || (mscoreMajorVersion == 3 && mscoreMinorVersion > 5)
                      ? qsTranslate("project/export", "Uncompressed MusicXML files")
                      : qsTranslate("Ms::MuseScore", "Uncompressed MusicXML File")
                }
                SmallCheckBox {
                    id: outMxl
                    text: "*.mxl"
                    //ButtonGroup.group: mxl
                    onClicked: {
                        if (checked && inMxl.checked)
                            inMxl.checked = false
                    }
                    ToolTip.visible: hovered
                    ToolTip.text: mscoreMajorVersion > 3 || (mscoreMajorVersion == 3 && mscoreMinorVersion > 5)
                      ? qsTranslate("project/export", "Compressed MusicXML files")
                      : qsTranslate("Ms::MuseScore", "Compressed MusicXML File")
                }
                SmallCheckBox {
                    id: outMid
                    text: "*.mid"
                    //ButtonGroup.group: mid
                    onClicked: {
                        if (checked && inMid.checked)
                            inMid.checked = false
                    }
                    ToolTip.visible: hovered
                    ToolTip.text: mscoreMajorVersion > 3 ? qsTranslate("project/export", "MIDI files")
                      : qsTranslate("Ms::MuseScore", "Standard MIDI File") // "MIDI"?
                }
                SmallCheckBox {
                    id: outMidi
                    visible: (mscoreMajorVersion > 3 || (mscoreMajorVersion == 3 && mscoreMinorVersion >= 5)) ? true : false // MuseScore 3.5 and later
                    text: "*.midi"
                    //ButtonGroup.group: midi
                    onClicked: {
                        if (checked && inMidi.checked)
                            inMidi.checked = false
                    }
                    ToolTip.visible: hovered
                    ToolTip.text: mscoreMajorVersion > 3 ? qsTranslate("project/export", "MIDI files")
                      : qsTranslate("Ms::MuseScore", "Standard MIDI File") // "MIDI"?
                }
                SmallCheckBox {
                    id: outPdf
                    text: "*.pdf"
                    checked: true
                    //ButtonGroup.group: pdf
                    onClicked: {
                        if (checked && inPdf.checked)
                            inPdf.checked = false
                    }
                    ToolTip.visible: hovered
                    ToolTip.text: mscoreMajorVersion > 3 ? qsTranslate("project/export", "PDF files")
                     : qsTranslate("Ms::MuseScore", "PDF File") //???
                }
                SmallCheckBox {
                    id: outPs
                    text: "*.ps"
                    visible: (mscoreMajorVersion < 2) ? true : false // MuseScore < 2.0
                    ToolTip.visible: hovered
                    ToolTip.text: qsTranslate("Ms::MuseScore", "PostStript File")
                }
                SmallCheckBox {
                    id: outPng
                    text: "*.png"
                    ToolTip.visible: hovered
                    ToolTip.text: mscoreMajorVersion > 3 ? qsTranslate("project/export", "PNG images")
                      : qsTranslate("Ms::MuseScore", "PNG Bitmap Graphic")
                }
                SmallCheckBox {
                    id: outSvg
                    text: "*.svg"
                    ToolTip.visible: hovered
                    ToolTip.text: mscoreMajorVersion > 3 ? qsTranslate("project/export", "SVG images")
                      : qsTranslate("Ms::MuseScore", "Scalable Vector Graphics")
                }
                SmallCheckBox {
                    id: outLy
                    text: "*.ly"
                    visible: (mscoreMajorVersion < 2) ? true : false // MuseScore < 2.0, or via xml2ly?
                    ToolTip.visible: hovered
                    ToolTip.text: qsTranslate("Ms::MuseScore", "LilyPond Format")
                }
                SmallCheckBox {
                    id: outWav
                    text: "*.wav"
                    ToolTip.visible: hovered
                    ToolTip.text: mscoreMajorVersion > 3 ? qsTranslate("Ms::MuseScore", "WAV audio files")
                      : qsTranslate("Ms::MuseScore", "Wave Audio")
                }
                SmallCheckBox {
                    id: outFlac
                    text: "*.flac"
                    ToolTip.visible: hovered
                    ToolTip.text: mscoreMajorVersion > 3 ? qsTranslate("project/export", "FLAC audio files")
                      : qsTranslate("Ms::MuseScore", "FLAC Audio")
                }
                SmallCheckBox {
                    id: outOgg
                    text: "*.ogg"
                    ToolTip.visible: hovered
                    ToolTip.text: mscoreMajorVersion > 3 ? qsTranslate("project/export", "OGG audio files")
                      : qsTranslate("Ms::MuseScore", "Ogg Vorbis Audio")
                }
                SmallCheckBox { // needs lame_enc.dll
                    id: outMp3
                    text: "*.mp3"
                    ToolTip.visible: hovered
                    ToolTip.text: mscoreMajorVersion > 3 ? qsTranslate("project/export", "MP3 audio files")
                      : qsTranslate("Ms::MuseScore", "MP3 Audio")
                }
                SmallCheckBox {
                    id: outMpos
                    text: (mscoreMajorVersion > 3) ? "*.mposXML" : "*.mpos"
                    visible: (mscoreMajorVersion > 3) ? true : false // MuseScore 3 and later
                    ToolTip.visible: hovered
                    ToolTip.text: qsTr("Positions of measures (XML)")
                }
                SmallCheckBox {
                    id: outSpos
                    text: (mscoreMajorVersion > 3) ? "*.sposXML" : "*.spos"
                    visible: mscoreMajorVersion > 3 ? true : false // MuseScore 3 and later
                    ToolTip.visible: hovered
                    ToolTip.text: qsTr("Positions of segments (XML)")
                }
                SmallCheckBox {
                    id: outMlog
                    visible: mscoreMajorVersion == 3 ? true : false // MuseScore 3 only
                    text: "*.mlog"
                    ToolTip.visible: hovered
                    ToolTip.text: qsTr("Internal file sanity check log (JSON)")
                }
                SmallCheckBox {
                    id: outMetaJson
                    visible: mscoreMajorVersion == 3 ? true : false // MuseScore 3 only
                    text: "*.metajson"
                    ToolTip.visible: hovered
                    ToolTip.text: qsTr("Metadata JSON")
                }
                SmallCheckBox {
                    id: outBrf
                    visible: mscoreMajorVersion > 3 ? true : false // MuseScore 4 and later
                    text: "*.brf"
                    ToolTip.visible: hovered
                    ToolTip.text: qsTranslate("project/export", "Braille files")
                }
                SmallCheckBox {
                    id: outMei
                    visible: ((mscoreMajorVersion > 4) || (mscoreMajorVersion == 4 && mscoreMinorVersion >= 2)) ? true : false // MuseScore 4.2 and later
                    //ButtonGroup.group: mei
                    onClicked: {
                        if (checked && inMei.checked)
                            inMei.checked = false
                    }
                    text: "*.mei"
                    ToolTip.visible: hovered
                    ToolTip.text: qsTranslate("project/export", "MEI files")
                }
            } //Column
        } //outFormats

        GridLayout {
            Layout.row: 2
            Layout.column: 0
            Layout.columnSpan: 3
            Layout.margins: 10
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignTop | Qt.AlignLeft
            rowSpacing: 1
            columnSpacing: 1
            columns: 2
            
            // SmallCheckBox {
                // id: exportExcerpts
                // Layout.columnSpan: 2
                // text: qsTr("Export parts")
                // enabled: (mscoreMajorVersion == 3 && mscoreMinorVersion > 0 || (mscoreMinorVersion == 0 && mscoreUpdateVersion > 2)) ? true : false // MuseScore > 3.0.2
                // visible: enabled //  hide if not enabled
            // } // exportExcerpts
            RowLayout {
                Layout.columnSpan: 2
                ButtonGroup {
                    id: exportParts
                }
                Label {
                    text: qsTr("Export","parts") + ":"
                    color: sysActivePalette.text 
                }
                NiceRadioButton {
                    id: rdbExpScore
                    text: qsTr("Score","parts")
                    checked: true
                    ButtonGroup.group: exportParts
                }
                NiceRadioButton {
                    id: rdbExpScoreParts
                    text: qsTr("Score and parts","parts")
                    ButtonGroup.group: exportParts
                }

                NiceRadioButton {
                    id: rdbExpPartsOnly
                    text: qsTr("Parts only","parts")
                    ButtonGroup.group: exportParts
                }
            }
            Label {
                text: qsTr("Import from") + ":"
                color: sysActivePalette.text 
                opacity: rdbImport.checked ? 1 : 0.3
            }
            RowLayout {
                TextField {
                    Layout.preferredWidth: 400
                    id: importFrom
                    text: ""
                    enabled: false
                    //color: sysActivePalette.text
                    color: rdbImport.checked ? sysDisabledPalette.shadow : sysDisabledPalette.mid //sysDisabledPalette.buttonText
                }
                Button {
                    enabled: rdbImport.checked
                    text: qsTr("Browse") + "..."
                    onClicked: {
                        sourceFolderDialog.open()
                    }
                }
            }
            SmallCheckBox {
                id: traverseSubdirs
                Layout.columnSpan: 2
                enabled: rdbImport.checked
                property var valid : traverseSubdirs.enabled && traverseSubdirs.checked
                text: qsTr("Process Subdirectories")
            } // traverseSubdirs
            SmallCheckBox {
                id: filterContent
                enabled: rdbImport.checked
                text: qsTr("Filter files with") + ":"
            }
            RowLayout {
                spacing: 2
                TextField {
                    Layout.preferredWidth: 200
                    id: contentFilterString
                    text: ""
                    enabled: filterContent.checked && rdbImport.checked
                    placeholderText: qsTr("E.g. *Concerto*")
                }
                SmallCheckBox {
                    id: filterWithRegExp
                    text: qsTr("Regular expression")
                    enabled: filterContent.checked && rdbImport.checked
                    checked: true
                }
            }
            SmallCheckBox {
                id: differentExportPath
                // // Only allow different export path if not traversing subdirs.
                // enabled: !traverseSubdirs.checked
                // property var valid: !traverseSubdirs.checked && differentExportPath.checked
                enabled: true
                property var valid: differentExportPath.checked
                text: qsTr("Export to") + ":"
                ToolTip.visible: hovered
                ToolTip.text: qsTr("Use a different export path")
            } // differentExportPath
            RowLayout {
                TextField {
                    Layout.preferredWidth: 400
                    id: exportTo
                    text: ""
                    color: differentExportPath.valid ? sysDisabledPalette.shadow : sysDisabledPalette.mid //sysDisabledPalette.buttonText
                    enabled: false
                }
                Button {
                    text: qsTr("Browse") + "..."
                    enabled: differentExportPath.checked && differentExportPath.valid
                    onClicked: {
                        targetFolderDialog.open()
                    }
                }
                Item {
                    Layout.minimumWidth: 50
                    Layout.fillHeight: true
                    Label {
                        text: "⚠"
                        color: "red"
                        font.bold: true
                        ToolTip.visible: maAlert.containsMouse
                        ToolTip.text: qsTr("The parsed subdirs will be flatten into the select folder")
                        visible: traverseSubdirs.valid && differentExportPath.checked
                        MouseArea {
                            id: maAlert
                            anchors.fill: parent
                            hoverEnabled: true
                        }
                        anchors.fill: parent
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        
                    }                    
                }
            }
            SmallCheckBox {
                id: useExportStructure
                // // Only allow different export path if not traversing subdirs.
                // enabled: !traverseSubdirs.checked
                // property var valid: !traverseSubdirs.checked && useExportStructure.checked
                enabled: true
                property var valid: useExportStructure.checked
                text: qsTr("Export structure") + ":"
                ToolTip.visible: hovered
                ToolTip.text: qsTr("Stucture the export folder depending on the file properties")
            } // useExportStructure
            RowLayout {
                spacing: 2
                TextField {
                    Layout.preferredWidth: 400
                    id: exportStructure
                    text: ""
                    ToolTip.visible: hovered
                    ToolTip.text: qsTr("Allowed keywords") + ":\n" +
                    "%FORMAT%\n%TITLE%\n%LYRICIST%\n%COMPOSER%\n%ARRANGER%\n%WORKNUMBER%\n%MOVEMENTNUMBER%\n%MOVEMENTTITLE%\n%YEAR%\n%PART%\n"
                      + "%1: %*?\"<>:|".arg(qsTr("Any character except")) + "\n"
                      + "%1: /".arg(qsTr("Folder separator"));
                    enabled: useExportStructure.valid
                }
                SmallCheckBox {
                    id: includeMissingProperty
                    // Only allow different export path if not traversing subdirs.
                    enabled: useExportStructure.valid
                    property var valid: useExportStructure.valid && includeMissingProperty.checked
                    text: qsTr("With missing properties") + ":"
                    ToolTip.visible: hovered
                    ToolTip.text: qsTr("Include the files with missing properties, and replace these properties by a keyword such as \"unspecified\".")
                } // includeMissingProperty
                TextField {
                    Layout.preferredWidth: 200
                    id: missingPropertyDefault
                    text: qsTr("unspecified")
                    placeholderText: qsTr("E.g. \"unspecified\"")
                    enabled: includeMissingProperty.valid
                }
            }
            SmallCheckBox {
                id: renameFiles
                property var valid: renameFiles.checked
                text: qsTr("Rename files") + ":"
                ToolTip.visible: hovered
                ToolTip.text: qsTr("rename_file_explnantion")
            } 
            RowLayout {
                spacing: 5
                Label {
                    text: qsTr("Replace")
                    color: sysActivePalette.text 
                    opacity: renameFiles.valid ? 1 : 0.3
                }
                TextField {
                    Layout.preferredWidth: 200
                    id: renameRegExp
                    placeholderText: qsTr("Regular expression")
                    enabled: renameFiles.valid
                }
                Label {
                    text: qsTr("With")
                    color: sysActivePalette.text 
                    opacity: renameFiles.valid ? 1 : 0.3
                }
                TextField {
                    Layout.preferredWidth: 200
                    id: renameReplace
                    placeholderText: qsTr("Text")
                    enabled: renameFiles.valid
                    ToolTip.visible: hovered
                    ToolTip.text: qsTr("Use $1 for matching group 1")
                }
            }
        } // options Column

        Item {
            //color: "#FFAACC"
            Layout.alignment: Qt.AlignBottom | Qt.AlignLeft
            Layout.columnSpan: 3
            Layout.column: 0
            Layout.row: 3
            Layout.fillWidth: true
            Layout.rightMargin: 10
            Layout.leftMargin: 10
            Layout.topMargin: 5
            Layout.preferredHeight: btnrow.implicitHeight
            RowLayout {
                id: btnrow
                spacing: 5
                anchors.fill: parent
                Button {
                    id: reset
                    text: qsTranslate("QPlatformTheme", "Restore Defaults")
                    onClicked: {
                        resetDefaults()
                    } // onClicked
                } // reset

                Button {
                    id: openlog
                    text: qsTr("View log")
                    onClicked: {
                        workDialog.open()
                    } // onClicked
                } // openLog

                Item { // spacer
                    id: spacer
                    implicitHeight: 10
                    Layout.fillWidth: true
                }

                Button {
                    id: preview
                    text: qsTr("Preview")
                    highlighted: true
                    //isDefault: true // needs more work
                    enabled: (!differentExportPath.valid || exportTo.text !== "") && (importFrom.text !== "") && (!includeMissingProperty.valid || missingPropertyDefault.text.trim() != "")
                    onClicked: {
                        convert = false;
                        work();
                    } // onClicked
                } // ok
                Button {
                    id: ok
                    enabled: (!differentExportPath.valid || exportTo.text !== "") && (importFrom.text !== "" || !rdbImport.checked) && (!includeMissingProperty.valid || missingPropertyDefault.text.trim() != "")
                    text: qsTr("Convert!")
                    onClicked: {
                        convert = true;
                        work();

                    } // onClicked
                } // ok
                Button {
                    id: cancel
                    text: /*qsTr("Cancel")*/ qsTranslate("QPlatformTheme", "Close")
                    onClicked: {
                        for (var i = 0; i < importWhat.buttons.length; i++) {
                            console.log(importWhat.buttons[i].text+": "+importWhat.buttons[i].checked);
                            if (importWhat.buttons[i].checked) {
                                settings.importWhat = i;
                                break;
                            }
                        }
                        for (var i = 0; i < exportParts.buttons.length; i++) {
                            console.log(exportParts.buttons[i].text+": "+exportParts.buttons[i].checked);
                            if (exportParts.buttons[i].checked) {
                                settings.exportParts = i;
                                break;
                            }
                        }
                        batchConvert.parent.Window.window.close();
                    }
                } // Cancel
            } // RowLayout
        } // Item
    } // GridLayout
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
        property alias inMei:   inMei.checked
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
        property alias outBrf: outBrf.checked
        property alias outMei: outMei.checked
        // other options
        property alias travers: traverseSubdirs.checked
        property alias diffEPath: differentExportPath.checked  // different export path
        property alias iPath: importFrom.text // import path
        property alias ePath: exportTo.text // export path
        property alias filter: filterContent.checked
        property alias filterString: contentFilterString.text
        property alias filterIsRegExp: filterWithRegExp.checked
        property alias exportStructure: exportStructure.text
        property alias useExportStructure: useExportStructure.checked
        property alias includeMissingProperty: includeMissingProperty.checked
        property alias missingPropertyDefault: missingPropertyDefault.text
        property alias renameFiles: renameFiles.checked;
        property alias renameRegExp: renameRegExp.text;
        property alias renameReplace: renameReplace.text;

        property int importWhat
        property int exportParts
    }

    FileDialog {
        id: sourceFolderDialog
        title: traverseSubdirs.checked ?
          qsTr("Select Sources Startfolder"):
          qsTr("Select Sources Folder")
        selectFolder: true
        folder: Qt.resolvedUrl(importFrom.text);


        onAccepted: {
            importFrom.text = sourceFolderDialog.folder.toString();
        }
        onRejected: {
            console.log("No source folder selected")
        }

    } // sourceFolderDialog

    FileDialog {
        id: targetFolderDialog
        title: qsTr("Select Target Folder")
        selectFolder: true
        folder: Qt.resolvedUrl(exportTo.text);

        onAccepted: {
            exportTo.text = targetFolderDialog.folder.toString();
        }

        onRejected: {
            console.log("No target folder selected")
        }
    } // targetFolderDialog

    function urlToPath(urlString) {
        var s;
        if (urlString.startsWith("file:///")) {
            var k = urlString.charAt(9) === ':' ? 8 : 7
            s = urlString.substring(k)
        } else {
            s = urlString
        }
        return decodeURIComponent(s);
    }

    function resetDefaults() {
        inMscx.checked = inXml.checked = inMusicXml.checked = inMxl.checked = inMid.checked =
                inMidi.checked = inKar.checked = inMd.checked = inPdf.checked = inCap.checked =
                inCapx.checked = inMgu.checked = inSgu.checked = inOve.checked = inScw.checked =
                inBmw.checked = inBww.checked = inGp4.checked = inGp5.checked = inGpx.checked =
                inGp.checked = inPtb.checked = inMsczComma.checked = inMscxComma.checked =
                inMscs.checked = inMei.checked = false
        outMscz.checked = outMscx.checked = outXml.checked = outMusicXml.checked = outMxl.checked =
                outMid.checked = outMidi.checked = outPdf.checked = outPs.checked = outPng.checked =
                outSvg.checked = outLy.checked = outWav.checked = outFlac.checked =
                outOgg.checked = outMp3.checked = outMpos.checked = outSpos.checked =
                outMlog.checked = outMetaJson.checked = outBrf.checked = outMei.checked = false
        traverseSubdirs.checked = false
        rdbExpScore.checked = true;
        filterWithRegExp.checked=false;
        filterContent.checked=true;
        contentFilterString.text="";
        differentExportPath.checked = false
        useExportStructure.checked=false;
        exportStructure.text="";
        includeMissingProperty.checked=false;
        missingPropertyDefault.text=qsTr("unspecified");
        renameFiles.checked=false;
        renameRegExp.text="";
        renameReplace.text="";
        

        // 'uncheck' everything, then 'check' the next few
        inMscz.checked = outPdf.checked = true
    } // resetDefaults

    function collectInOutFormats() {
        inFormats.extensions.length=0;
        outFormats.extensions.length=0;
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
        if (inMsczComma.checked) inFormats.extensions.push(mscoreMajorVersion > 3 ? "mscz~" : "mscz,")
        if (inMscxComma.checked) inFormats.extensions.push("mscx,")
        if (inMscs.checked) inFormats.extensions.push("mscs")
        if (inMei.checked) inFormats.extensions.push("mei")
        if (!inFormats.extensions.length)
            console.warn("No input format selected")

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
        if (outMpos.checked) outFormats.extensions.push(mscoreMajorVersion > 3 ? "mposXML" : "mpos")
        if (outSpos.checked) outFormats.extensions.push(mscoreMajorVersion > 3 ? "sposXML" : "spos")
        if (outMlog.checked) outFormats.extensions.push("mlog")
        if (outMetaJson.checked) outFormats.extensions.push("metajson")
        if (outBrf.checked)  outFormats.extensions.push("brf")
        if (outMei.checked)  outFormats.extensions.push("mei")
        if (!outFormats.extensions.length)
            console.warn("No output format selected")

        return (inFormats.extensions.length && outFormats.extensions.length)
    } // collectInOutFormats

    // flag for abort request
    property bool abortRequested: false

    // dialog to show progress
    Dialog {
        id: workDialog
        modality: Qt.ApplicationModal
        visible: false
        width: 900
        height: 700
        standardButtons: StandardButton.Close


        ColumnLayout {

            anchors.fill: parent
            spacing: 5
            anchors.topMargin: 10
            anchors.rightMargin: 10
            anchors.leftMargin: 10
            anchors.bottomMargin: 5

            Label {
                id: currentStatus
                Layout.preferredWidth: 600
                Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                text: qsTr("Pending...")
                    color: sysActivePalette.text // tweak dark mode
            }

            ScrollView {
                id: view
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.maximumHeight: 700
                Layout.minimumWidth: 900
                clip: true

                TextArea {
                    id: resultText
                    //anchors.fill: parent
                    anchors.margins: 5
                    selectByMouse: true
                    selectByKeyboard: true
                    cursorVisible: true
                    readOnly: true
                    focus: true
                    color: sysActivePalette.text // tweak dark mode
                }

                ScrollBar.horizontal.policy: ScrollBar.AsNeeded
                ScrollBar.horizontal.position: 0
                ScrollBar.vertical.policy: ScrollBar.AsNeeded

            }

        }

        onDiscard: { // Abort
            abortRequested = true
        }

        onRejected: { // Close
            standardButtons = StandardButton.Close
        }
        
        onApply: { // Apply
            console.log("Apply!!")
            convert = true;
            work();
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
    function createDefaultFileName(fn, allowWhitespace) {
        if (allowWhitespace===undefined) allowWhitespace=false;
        fn = fn.trim()
        if (!allowWhitespace) fn = fn.replace(/ /g,"_")
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

    // cleaned import path of export
    property var importFromPath
    // cleaned path of export
    property var exportToPath
    // regxep to filter the files to convert
    property var regexp
    // regxep to rename the file names
    property var regexpRename
    // conversion mode : effectively do the conversion, or preview only
    property bool convert: false

    SystemPalette { id: sysActivePalette; colorGroup: SystemPalette.Active }
    SystemPalette { id: sysDisabledPalette; colorGroup: SystemPalette.Disabled }



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

    QProcess {
        id: procExcerpt
    }

    QProcess {
        id: procScore
    }

    Timer {
        id: excerptTimer
        interval: 1
        running: false

        // this function processes one linked part and
        // gives control back to Qt to update the dialog
        onTriggered: {
            var curScoreInfo = excerptsList.shift();
            var thisScore = curScoreInfo[0].partScore;
            var partTitle = curScoreInfo[0].title;
            var filePath = curScoreInfo[1];
            var fileName = curScoreInfo[2];
            var srcModifiedTime = curScoreInfo[3];
            var targetPath = curScoreInfo[4];
            var isCurScore = curScoreInfo[5];

            var missing = (includeMissingProperty.checked) ? missingPropertyDefault.text : undefined;

            // - create full file path for part
            var targetBase = buildExportPath(targetPath, /%part%/i, "parts", missing);
            var logTargetName = (targetBase.startsWith(exportToPath)) ? targetBase.substring(exportToPath.length) : targetBase;

            var doExport = true;

            // - checking if the path is complete
            // if it contains still %, it means that they were some missing properties that we haven't replaced by an "unspecified" text
            if (targetBase.replace(/%format%/gi, "").includes("%")) {
                resultText.append("  %1 → %2 - %3".arg(partTitle).arg(logTargetName).arg(qsTr("Skipped")))
                doExport = false;
            }

            if (doExport) {
                // - write for all target formats
                var partFileName = fileName + "-" + createDefaultFileName(partTitle) + ".";

                for (var j = 0; j < outFormats.extensions.length; j++) {

                    var format = outFormats.extensions[j];
                    var tb = buildExportPath(targetBase, /%format%/i, format);
                    var partFileNameExtension = partFileName + format;
                    var dest = tb + partFileNameExtension;

                    // - checking if the target folder exists
                    fileExcerpt.source = tb;

                    if (convert && !fileExcerpt.exists()) {
                        mkdir(procExcerpt, fileExcerpt.source);
                    }

                    if (convert && !fileExcerpt.exists()) {
                        resultText.append("  " + qsTr("Folder not available") + ": %1 → %2 - %3".arg(partTitle).arg(logTargetName).arg(qsTr("Not exported")));
                        continue;
                    }
                    // get modification time of destination file (if it exists)
                    // modifiedTime() will return 0 for non-existing files
                    // if src is newer than existing write this file
                    fileExcerpt.source = dest;
                    logTargetName = (fileExcerpt.source.startsWith(exportToPath)) ? fileExcerpt.source.substring(exportToPath.length) : fileExcerpt.source;
                    if (srcModifiedTime > fileExcerpt.modifiedTime()) {
                        var res = convert ? writeScore(thisScore, fileExcerpt.source, outFormats.extensions[j]) : true;
                        if (res)
                            resultText.append("  %1 → %2 - %3".arg(partTitle).arg(logTargetName).arg(convert ? qsTr("Exported") : qsTr("Will be exported")));
                        else
                            resultText.append("  " + qsTr("Error") + ": %1 → %2 - %3".arg(partTitle).arg(logTargetName).arg(qsTr("Not exported")))
                    } else // file already up to date
                        resultText.append("  %1 → %2 - %3".arg(partTitle).arg(logTargetName).arg(qsTr("Up to date")));
                }

            }

            view.ScrollBar.horizontal.position = 0;

            // check if more files
            if (!abortRequested && excerptsList.length > 0)
                excerptTimer.restart();
            else {
                // close base score
                if (!isCurScore)
                    closeScore(curBaseScore);
                processTimer.restart();
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
            if (fileList.length === 0 || abortRequested) {
                // no more files to process
                if (!abortRequested) {
                    workDialog.standardButtons = (convert) ? StandardButton.Close : StandardButton.Apply | StandardButton.Close;
                    currentStatus.text = qsTr("Done") /*qsTranslate("QWizard", "Done")*/ + "."; // Gramatically incorrect translation of QWizard::Done in french
                } else {
                    workDialog.standardButtons = StandardButton.Close;
                    console.log("abort!");
                    currentStatus.text = qsTr("Aborted!")
                }
                return;
            }
            console.log("--Remaing items to convert: "+fileList.length+"--");

            var curFileInfo = fileList.shift();
            var filePath, fileName, fileExt;
            var fileFullPath, thisScore;
            var isCurScore = false;
            
            if (Array.isArray(curFileInfo)) {
                // Coming from the Import action
                filePath = curFileInfo[0];
                fileName = curFileInfo[1];
                fileExt = curFileInfo[2];
                fileFullPath = filePath + fileName + "." + fileExt;
                // read file
                thisScore = readScore(fileFullPath, true);

                // Make sure we have a valid score
                // Rem: MS fails a reading a score ("readScore" above) if the score is already opened. 
                // => So we check if a score with the same path is already opened.
                if (!thisScore) {
                    console.log("Failed to read "+fileFullPath+".\nChecking if it is already open.");
                    var opened = scores;
                    for(var i=0;i<opened.length;i++) {
                        var score=opened[i];
                        console.log("--> Checking if curScore is this file: "+score.path);
                        if (score.path.toLowerCase()===fileFullPath.toLowerCase()) {
                            thisScore=score;
                            isCurScore=true;
                            break;
                        }
                    }
                    console.log("==> And it "+((!thisScore)?"is not":"is"));
                }

            } else {
                // Coming from the current/opened action
                thisScore = curFileInfo;
                var full= thisScore.path;
                fileName = thisScore.scoreName;
                
                isCurScore = true;

                // Make sure we have a valid score
                // Rem: no fullPath means we are either an unsaved score or an excerpt/part 
                // => So we browse the opened scores to find the parent to which belongs this part
                if (!full) {
                    console.log("Failed to find a score path for " + fileName + ".\nChecking if it is already opened part.");
                    for (var k = 0; i < scores.length; ++k) {
                        var s = scores[k];
                        console.log("--> " + s.path + "/" + s.scorName);
                        if (s.is(thisScore)) {
                            break;
                        }

                        var sExcerpts = s.excerpts;

                        for (var ei = 0; ei < sExcerpts.length; ++ei) {
                            var es = sExcerpts[ei].partScore;
                            console.log("----> " + es.path + "/" + es.scorName);
                            if (es.is(thisScore)) {
                                full = s.path;
                                break;
                            }
                        }
                    }
                    console.log("==> And it " + ((!full) ? "is not" : "is"));
                }
                
                if (full) {
                    fileFullPath = urlToPath(full); // c:/path/to/my_score.mscz
                    fileExt = getFileSuffix(fileFullPath); // mscz
                    filePath = fileFullPath.substring(0, fileFullPath.length - fileExt.length - fileName.length - 1);
                }
            }

            if (thisScore && fileFullPath) {
                // get modification time of source file
                fileScore.source = fileFullPath
                var logSourceName = (fileFullPath.toUpperCase().startsWith(importFromPath))?fileFullPath.substring(importFromPath.length):fileFullPath;


                var srcModifiedTime = fileScore.modifiedTime()

                // DEBUG META INFO
                console.log("--title: "+thisScore.title);
                console.log("--lyricist: "+thisScore.lyricist);
                console.log("--composer: "+thisScore.composer);
                console.log("--arranger: "+thisScore.metaTag("arranger"));
                console.log("--workNumber: "+thisScore.metaTag("workNumber"));
                console.log("--movementNumber: "+thisScore.metaTag("movementNumber"));
                console.log("--movementTitle: "+thisScore.metaTag("movementTitle"));
                console.log("--creation year: "+Qt.formatDate(new Date(thisScore.metaTag("creationDate")),"yyyy"));


                // - create full file path for part
                var targetPath=(differentExportPath.valid)?exportToPath:filePath;
                var missing =  (includeMissingProperty.checked)?missingPropertyDefault.text:undefined;

                if (useExportStructure.valid) {
                    var sub=exportStructure.text;
                    sub=buildExportPath(sub,/%title%/i,thisScore.title,missing);
                    sub=buildExportPath(sub,/%lyricist%/i,thisScore.lyricist);
                    if(sub.match(/%lyricist%/i))
                        sub=buildExportPath(sub,/%lyricist%/i,thisScore.composer,missing); // if no lyticst use composer 
                    sub=buildExportPath(sub,/%composer%/i,thisScore.composer,missing);
                    sub=buildExportPath(sub,/%arranger%/i,thisScore.metaTag("arranger"));
                    if(sub.match(/%arranger%/i))
                        sub=buildExportPath(sub,/%arranger%/i,thisScore.composer,missing); // if no arranger use composer 
                    sub=buildExportPath(sub,/%worknumber%/i,thisScore.metaTag("workNumber"),missing);
                    sub=buildExportPath(sub,/%movementnumber%/i,thisScore.metaTag("movementNumber"),missing);
                    sub=buildExportPath(sub,/%movementtitle%/i,thisScore.metaTag("movementTitle"),missing);
                    sub=buildExportPath(sub,/%year%/i, Qt.formatDate(new Date(thisScore.metaTag("creationDate")),"yyyy"),missing);

                    targetPath += sub + "/" ;
                }

                var targetBase=buildExportPath(targetPath,/%part%/i,"scores",missing)
                var logTargetName = (targetBase.startsWith(exportToPath))?targetBase.substring(exportToPath.length):targetBase;

                var doExport = true;

                // - checking if the path is complete
                // if it contains still %, it means that they were some missing properties that we haven't replaced by an "unspecified" text
                if (targetBase.replace(/%format%/gi,"").includes("%")) {
                    resultText.append("%1 → %2 - %3".arg(logSourceName).arg(logTargetName).arg(qsTr("Skipped")))
                    doExport=false;
                }

                if (doExport) {
                    // constuct the export filename
                    if (regexpRename) {
                        console.log("Checking file rename on "+fileName)
                        var match = regexpRename.test(fileName);
                        console.log("match: "+match);
                        
                        if (match) {
                            var test = fileName.replace(regexpRename, renameReplace.text);
                            console.log("result: "+test);
                            if (test !== "") {
                                fileName = test;
                            }
                        }

                    }
                    // - write for all target formats
                    for (var j = 0; j < outFormats.extensions.length; j++) {

                        var format=outFormats.extensions[j];
                        var tb=buildExportPath(targetBase,/%format%/i, format);
                        var fileNameExtension = fileName + "." + format;
                        var dest=tb + fileNameExtension;

                        // - checking if the target folder exists
                        fileScore.source =  tb;
                        if (convert && !fileScore.exists() ) {
                            mkdir(procScore, fileScore.source);
                        }

                        if (convert && !fileScore.exists() ) {
                            console.log("Failed to create "+fileScore.source+"\nBypassing this file.");
                            resultText.append(qsTr("Folder not available")+": %1 → %2 - %3".arg(logSourceName).arg(logTargetName).arg(qsTr("Not exported")))
                            continue;
                        }
                        fileScore.source =  dest;
                        logTargetName = (fileScore.source.startsWith(exportToPath))?fileScore.source.substring(exportToPath.length):fileScore.source;

                        var hasExcerpts = (thisScore.excerpts.length>0)


                        if (rdbExpPartsOnly.checked && hasExcerpts) {
                            // Export only the parts ( <=> there are parts)
                            // => log as "not applicable"
                            resultText.append("%1 - %2".arg(logSourceName).arg(qsTr("n/a")))
                        } else if (srcModifiedTime > fileScore.modifiedTime()) {
                            // Export the score or export the parts only but there are no parts
                            // if an the current score is more recent than the last export
                            // => export
                            var res = convert ? writeScore(thisScore, fileScore.source, outFormats.extensions[j]) : true

                            if (res)
                                resultText.append("%1 → %2 - %3".arg(logSourceName).arg(logTargetName).arg(convert?qsTr("Exported"):qsTr("Will be exported")))
                            else
                                resultText.append(qsTr("Error")+": %1 → %2 - %3".arg(logSourceName).arg(logTargetName).arg(qsTr("Not exported")))
                        }
                        else
                            // Export the score, and the current score is older/same as the last export
                            // => Log as up to date
                            resultText.append("%1 → %2 - %3".arg(logSourceName).arg(logTargetName).arg(qsTr("Up to date")))
                    }  

                    // check if we are supposed to export parts
                    // if (exportExcerpts.checked) {
                    if (rdbExpPartsOnly.checked || rdbExpScoreParts.checked) {
                        // reset list
                        excerptsList = []
                        // do we have excertps?
                        var tExcerpts = thisScore.excerpts
                        for (var ex = 0; ex < tExcerpts.length; ex++) {
                            var partScore=tExcerpts[ex].partScore;
                            var partName=tExcerpts[ex].title;
                            if (partScore === thisScore) continue; // only list when not base score
                            if (partName.charAt(0) === ".") continue; // only list when not starting with a "."
                            excerptsList.push([tExcerpts[ex], filePath, fileName, srcModifiedTime, targetPath, isCurScore])
                        }
                        // if we have files start timer
                        if (tExcerpts.length > 0) {
                            curBaseScore = thisScore // to be able to close this later
                            excerptTimer.running = true
                            return
                        }
                    }
                }
                if (!isCurScore) closeScore(thisScore)
            }
            else if(!thisScore) {
                resultText.append(qsTr("ERROR reading file %1").arg(fileName));
            }
            else {
                resultText.append(qsTr("ERROR unsaved file %1").arg(fileName));
            }

            view.ScrollBar.horizontal.position = 0

            // next file
            if (!abortRequested)
                processTimer.restart();
            else 
                workDialog.standardButtons = (convert)?StandardButton.Close:StandardButton.Apply|StandardButton.Close;

        }
    }

    function buildExportPath(dest,tag,value, missing) {
        if (!value || value.trim()==="") {
            if (missing) {
                value=missing;
            } else {
                return dest; // return as such
            }
        } else {
            value=createDefaultFileName(value,true); // allow whitespaces
        }
        return dest.replace(tag,value);
    }

    function mkdir(qproc, path) {
        var cmd;
        var res = false;

        // Platform-based command
        switch (Qt.platform.os) {
        case "windows":
            var wpath=path.replace(/\//g,"\\");
            cmd = "cmd /c mkdir \"" + wpath + "\"";
            break;
        default:
            cmd = "/bin/sh -c \"mkdir -p '"+path+"'\"";
        }

        // Execution
        // var res = qproc.waitForStarted(3000);
        // if (res) {
        console.log("-- MKDIR PATH: " + path);
        console.log("-- MKDIR CMD: " + cmd);
        qproc.start(cmd);
        res = qproc.waitForFinished(5000);
        if (res) {
            console.log("-- MKDIR CMD : OK");
        } else {
            console.log("-- MKDIR CMD : ERR");
        }

        // DEBUG
        try {
            console.log("-- MKDIR STDOUT : " + qproc.readAllStandardOutput());
        } catch (err) {
            console.log("--" + err.message);
        }

        // !! "true" doesn't mean it all went right. E.g. calling "cmd /c foobar" will return true even if the foobar" command does not exist !!
        return (res ? true : false);
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

                    var match=true;
                    if (regexp) {
                        // console.log("--Filter files--");
                        // console.log(filterWithRegExp.checked?"--RegExp--":"--Regular--");
                        // console.log("--with \""+contentFilterString.text+"\"--");
                        match=regexp.test(fileName);
                        // console.log("Match RegExp: ", match)
                    } else {
                        // console.log("--Don't filter files--");
                    }

                    if (match)
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
                processTimer.restart();
            } else {
                // we didn't find any files
                // report this
                resultText.append(qsTr("No files found"))
                workDialog.standardButtons = StandardButton.Close
                currentStatus.text = qsTr("Done") /*qsTranslate("QWizard", "Done")*/ + ".";  // Gramatically incorrect translation of QWizard::Done in french
            }
        }
    }

    function work() {

        workDialog.standardButtons = StandardButton.Discard
        currentStatus.text = qsTr("Running...");
        abortRequested=false;
        if (resultText.text!=="") resultText.append("---------------------------------");

        workDialog.visible = true

        // Verifications
        var validation=true;
        // 1) in and out formats selection
        if (!collectInOutFormats()) {
            resultText.append(qsTr("Incomplete in and out format selection "));
            validation=false;
        }

        // 2) import folders
        if (!rdbImport.checked && !curScore) {
            resultText.append(qsTr("No current score"));
            validation = false;
        } else if (rdbImport.checked && !importFrom.text) {
            resultText.append(qsTr("Missing import folder"));
            validation = false;
        }
        // 2b) export folders
        if (differentExportPath.valid && !exportTo.text) {
            resultText.append(qsTr("Missing export folder"));
            validation = false;
        }
        // 3) Filter regexp
        if (rdbImport.checked && filterContent.checked) {
            try {
                regexp=filterWithRegExp.checked?new RegExp(contentFilterString.text): RegExp('^' + contentFilterString.text.replace(/\*/g, '.*') + '$');
            } catch(err) {
                resultText.append(err.message);
                validation=false;
            }
        } else {
            regexp=undefined;
        }

        // 4) Rename Regexp
        if (renameFiles.valid && renameRegExp.text!== "") {
            try {
                regexpRename = new RegExp(renameRegExp.text);
            } catch(err) {
                resultText.append(err.message);
                validation=false;
            }

        } else {
            regexpRename=undefined;
        }

        // 4) export structuture
        if (useExportStructure.valid) {

            exportStructure.text=exportStructure.text.replace(/\/\s*$/,""); // delete trailing "/"
            exportStructure.text=exportStructure.text.replace(/\\/,"/"); // remove "\" by "/"
            exportStructure.text=exportStructure.text.trim(); // delete starting and trailing spaces

            var check1 = /\/\//;
            var check2 = /^((%FORMAT%|%COMPOSER%|%TITLE%|%YEAR%|%WORKNUMBER%|%LYRICIST%|%ARRANGER%|%MOVEMENTNUMBER%|%MOVEMENTTITLE%|%PART%)([^:\\/%*?"<>|]*\/?[^:\\/%*?"<>|]*)*)+$/i



            var valid;
            if (exportStructure.text.match(check1)) { // checking for "//" : not authorized
                valid = false
            } else if (!exportStructure.text.match(check2)) {  // checking keywords and structure
                valid = false
            } else {
                valid = true
            }

            if(!valid) {
                resultText.append(qsTr("Invalid export structure"));
                validation=false;
            }
        }

        // 5) missing property default
        if (includeMissingProperty.valid) {
            missingPropertyDefault.text=createDefaultFileName(missingPropertyDefault.text,true); // accept whitespaces
        }

        if (!validation) {
            workDialog.standardButtons = StandardButton.Close
            return;
        }

        // Preparation

        // remove the file:/// at the beginning of the return value of targetFolderDialog.folder
        // However, what needs to be done depends on the platform.
        // See this stackoverflow post for more details:
        // https://stackoverflow.com/questions/24927850/get-the-path-from-a-qml-url

        // 1b) Import Path
        if (rdbCurrent.checked) {
            importFromPath = urlToPath(curScore.path);
        } else {
            importFromPath = urlToPath(importFrom.text);
        }
        if (!importFromPath.endsWith('/')) importFromPath+='/';
        //importFromPath=importFromPath.toUpperCase(); //21/11/22 Linux testing

        // 1b) Export Path
        if (differentExportPath.valid) {
            exportToPath = urlToPath(exportTo.text);
            if (!exportToPath.endsWith('/')) exportToPath += '/';
            //exportToPath=exportToPath.toUpperCase(); //21/11/22 Linux testing
        } else {
                exportToPath=importFromPath;
        }
        
        console.log((traverseSubdirs.checked? "Sources Startfolder: ":"Sources Folder: ")
                    + importFromPath);
        console.log("Exporting to: "+exportToPath);

        // initialize global variables
        
        fileList = []
        folderList = []
        
        if (!rdbImport.checked) {
            var what=[];
            if (rdbCurrent.checked) {
                what.push(curScore);
            } else {
                what=scores;
            }

            for(var i=0;i<what.length;i++) {
                var score = what[i];
                fileList.push(score)
            }
            // if we found files, start timer do process them
            processTimer.restart();
        } else {
        
            // set folder and filter in FolderListModel
            files.folder = importFrom.text

            if (traverseSubdirs.checked) {
                files.showDirs = true
                files.showFiles = true
            } else {
                // only look for files
                files.showFiles = true
                files.showDirs = false
            }

            // wait for FolderListModel to update
            // therefore we start a timer that will
            // wait for 25 millis and then start working
            collectFiles.running = true
        }
    } // work
    
    
    function xyz(obj) {
        return "" + obj + " (" + (typeof obj) + " - null: " + (obj===null) + ")";
    }
} // MuseScore
