import QtQuick 2.15
import QtQuick.Controls 2.15

Page {
    property alias hpage: hpage
    property alias textInput: textInput
    property alias outText: outText
    property alias button: button
    property alias button1: button1
    property alias busyIndicator: busyIndicator

    width: 360
    height: 480
    id: hpage

    Rectangle {
        id: rectangle2
        anchors.centerIn: parent
        height: rectangle.height
        width: rectangle.width
        color: "#d7d6d5"
    }

    Rectangle {
        id: rectangle
        anchors.right: parent.right
        anchors.left: parent.left
        anchors.rightMargin: 20
        anchors.leftMargin: 20
        anchors.top: parent.top
        anchors.topMargin: height*2
        height: 30
        color: "#d7d6d5"
    }

    TextInput {
        id: textInput
        anchors.fill: rectangle
        horizontalAlignment: Text.AlignHCenter
        text: ""
        font.pointSize: 16
    }

    Text {
        id: outText
        anchors.fill: rectangle2
        horizontalAlignment: Text.AlignHCenter
        color: "#000000"
        text: ""
        font.pointSize: 10
    }

    Connections {
                target: backEnd

                onSendToQml: {
                    outText.text = mes
                    if (outText.text == "Connecting to device.")
                        busyIndicator.visible = true
                    else (outText.text == "Connection established.")
                        busyIndicator.visible = false
                }
    }

    Button {
        id: button
        anchors.left: rectangle.left
        anchors.top: rectangle.bottom
        anchors.topMargin: height/4
        text: "clear"
        flat: true
        highlighted: true
        font.pointSize: 14
    }

    Button {
        id: button1
        anchors.right: rectangle.right
        anchors.top: rectangle.bottom
        anchors.topMargin: height/4
        text: "send"
        flat: true
        highlighted: true
        font.pointSize: 14
    }

    BusyIndicator {
        id: busyIndicator
        anchors.centerIn: parent
        visible: false
    }
}
