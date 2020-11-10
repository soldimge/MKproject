import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt.labs.settings 1.0

Page {
    property alias hpage: hpage
    property alias textInput: textInput
    property alias outText: outText
    property alias button: button
    property alias button1: button1
    property alias comboBox: comboBox
    property alias cmdInput: cmdInput
    property alias tumbler: tumbler

    width: 360
    height: 560
    id: hpage

    Settings {
        id: settings
        property alias indxFromSettings: tumbler.currentIndex
    }

    Frame {
        id: frame
        anchors.left: button.left
        anchors.right: button1.right
        anchors.bottom: rectangle.top
        anchors.bottomMargin: rectangle.height/2
        height: rectangle.height

        Text {
            id: cmdText
            anchors.left: parent.left
            anchors.right: rectangle3.left
            anchors.bottom: parent.bottom
            anchors.top: parent.top
            font.pointSize: 16
            text: "CMD:"
            color: "#d7d6d5"
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
        }
    }

    Rectangle {
        id: rectangle2
        anchors.centerIn: parent
        height: rectangle.height*2
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
        anchors.topMargin: height*3
        height: parent.height/16
        color: "#d7d6d5"
    }

    TextInput {
        id: textInput
        anchors.fill: rectangle
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        text: ""
        font.pointSize: 16
        wrapMode: Text.Wrap
        clip: true
    }

    Text {
        id: outText
        anchors.fill: rectangle2
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        color: "#000000"
        text: ""
        font.pointSize: 16
        wrapMode: Text.Wrap
        clip: true
    }

    Connections {
                target: backEnd

                onSendToQml: {
                    outText.text = mes
                    if (mes == "Connected")
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
                    outText.text = "Search finished"
                }
    }

    Button {
        id: button
        anchors.left: rectangle.left
        anchors.top: rectangle.bottom
        anchors.topMargin: height/4
        text: "CLEAR"
        flat: true
        highlighted: true
        font.pointSize: 16
        onClicked:
        {
            textInput.text = ""
            cmdInput.text = ""
        }
        hoverEnabled: true

        ToolTip.delay: 1000
        ToolTip.timeout: 5000
        ToolTip.visible: hovered
        ToolTip.text: qsTr("Clear all fields")
    }

    Button {
        id: button1
        anchors.right: rectangle.right
        anchors.top: rectangle.bottom
        anchors.topMargin: height/4
        text: "SEND"
        flat: true
        highlighted: true
        font.pointSize: 16
        onClicked:
        {
            backEnd.sendMessageToDevice(cmdInput.text, textInput.text, tumbler.currentIndex)
        }
        hoverEnabled: true

        ToolTip.delay: 1000
        ToolTip.timeout: 5000
        ToolTip.visible: hovered
        ToolTip.text: qsTr("Send command to device")
    }

    ComboBox {
        visible: false
        id: comboBox
        model: listModel
        height: rectangle.height*2
        anchors.top: rectangle2.bottom
        anchors.topMargin: height
        anchors.left: rectangle.left
        anchors.right: rectangle.right
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
                    font.pointSize: 22
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                }
                popup: Popup {
                    dim: true
                    width: comboBox.width
                    x: comboBox.width - width
                    y: comboBox.height - height
                    leftPadding: 0
                    padding: 0
                    contentItem: ListView {
                        clip: true
                        implicitHeight: contentHeight
                        model: comboBox.popup.visible ? comboBox.delegateModel : null
                        currentIndex: comboBox.highlightedIndex
                    }
                }
        onActivated:
        {
            comboBox.displayText = comboBox.model[comboBox.currentIndex]
            backEnd.connect_toDevice_clicked(comboBox.displayText);
            toolButton2Pic.source = "qrc:/images/bluetooth_on.png";
        }
    }

    ListModel {
        id: listModel
    }

    ComboBox {
        id: tumbler
        anchors.right: frame.right
        anchors.rightMargin: 1
        anchors.bottom: frame.bottom
        anchors.top: frame.top
        width: button1.width*1.6
        background: Rectangle
                {
                    id: tbrect
                    color: "#273354"
                    border.width: 0
                }
        model: ["ASCII", "HEX", "DEC"]
        delegate: ItemDelegate {
                            width: tumbler.width
                            contentItem: Text {
                                text: modelData
                                color: "#d7d6d5"
                                font: tumbler.font
                                elide: Text.ElideRight
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignHCenter
                            }
                            highlighted: tumbler.highlightedIndex === index
                        }
                        contentItem: Text {
                            leftPadding: 20
                            text: tumbler.displayText
                            color: "#d7d6d5"
                            font.pointSize: 16
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                        }
        currentIndex: settings.indxFromSettings
    }

    Rectangle {
        id: rectangle3
        anchors.left: button.right
        anchors.top: frame.top
        anchors.topMargin: 1
        anchors.bottom: frame.bottom
        anchors.bottomMargin: 1
        width: button1.width *0.7
        color: "#d7d6d5"
        TextInput {
            id: cmdInput
            anchors.fill: parent
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            text: ""
            font.pointSize: 16
        }
    }
}

