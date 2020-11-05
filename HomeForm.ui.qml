import QtQuick 2.15
import QtQuick.Controls 2.15

Page {
    property alias hpage: hpage
    property alias textInput: textInput
    property alias outText: outText
    property alias button: button
    property alias button1: button1
    property alias comboBox: comboBox

    width: 360
    height: 480
    id: hpage

    Rectangle {
        id: background
        anchors.fill: parent
        color: "#2d374a" //"#2d374a"
    }

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
                    else
                        busyIndicator.visible = false
                }                
                onAddDevice: {
                    listModel.append({"text" : name});
                }
                onEndOfSearch: {
                    listModel.clear()
                    comboBox.visible = true
                    toolButton4.enabled = true
                    busyIndicator.visible = false
                    toolButton2.enabled = true
//                    comboBox.popup.open()
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

    ComboBox {
        visible: false
        id: comboBox
        model: listModel
        height: rectangle.height*2
        anchors.bottom: parent.bottom
        anchors.bottomMargin: height
        anchors.left: parent.left
        anchors.right: parent.right
        flat: true
        currentIndex: -1
        displayText: "Choose device"
        background: Rectangle
                {
                    color: "#232a37"
                    border.width: 0
                }
        delegate: ItemDelegate {
                    width: comboBox.width
                    contentItem: Text {
                        text: modelData
                        color: "#9cbdec"
                        font: comboBox.font
                        elide: Text.ElideRight
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignHCenter
                    }
                    highlighted: comboBox.highlightedIndex === index
                }

                contentItem: Text {
                    leftPadding: 20
                    text: comboBox.displayText
                    color: "#9cbdec"
                    font.pointSize: 25
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                }
                popup: Popup {
                    dim: true
                    width: comboBox.width
                    x: hpage.width - width
                    y: comboBox.height - height
                    leftPadding: 0
                    implicitHeight: hpage.height/2
                    padding: 0
                    contentItem: ListView {
                        clip: true
                        implicitHeight: contentHeight
                        model: comboBox.popup.visible ? comboBox.delegateModel : null
                        currentIndex: comboBox.highlightedIndex
                    }
                }
            }
    ListModel {
        id: listModel
    }
}
