import QtQuick 2.9
import QtQuick.Controls 2.2

/**
* 1.1: set default leftPadding to 0 and stop adding 2 at the left of the indicator
*/
CheckBox {
    id: schk
    property alias boxWidth: box.implicitWidth
    leftPadding : 0
    indicator: Rectangle {
        id: box
        implicitWidth: 18
        implicitHeight: implicitWidth
        x: schk.leftPadding
        y: parent.height / 2 - height / 2
        border.color: "grey"

        Item {
            id: mainContainer
			property var _mw: Math.max(3,box.implicitWidth * 0.2)
			property var _mh: Math.max(3,box.implicitHeight * 0.2)
            width: box.implicitWidth - 2*_mw 
            height: box.implicitHeight - 2*_mh
            x: _mw
            y: _mh

            Canvas {
                id: drawingCanvas
                anchors.fill: parent
				visible: schk.checked
                onPaint: {
                    var ctx = getContext("2d");


                    ctx.lineWidth = Math.max(1.5,box.implicitWidth * 0.05);
                    ctx.strokeStyle = schk.color; //"black";
                    ctx.beginPath();
                    ctx.moveTo(0, 0);
                    ctx.lineTo(drawingCanvas.width, drawingCanvas.height);
                    ctx.stroke();
                    ctx.beginPath();
                    ctx.moveTo(drawingCanvas.width, 0);
                    ctx.lineTo(0, drawingCanvas.height);
                    // ctx.closePath();
                    ctx.stroke();
                }
            }
        }
    }
}