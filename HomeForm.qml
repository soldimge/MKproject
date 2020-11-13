import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt.labs.settings 1.0

Page {
    property alias hpage: hpage
    property alias textInput: textInput
//    property alias outText: outText
    property alias button: button
    property alias button1: button1
    property alias comboBox: comboBox
    property alias cmdInput: cmdInput
    property alias tumbler: tumbler
    property alias settings: settings

    width: 360
    height: 560
    id: hpage

    Settings {
        id: settings
        property alias indxFromSettings: tumbler.currentIndex
        property alias indxFromSettings2: tumblerOutput.currentIndex
    }
    Frame {
        id: cmdFrame
        anchors.left: dataText.left
        anchors.right: dataText.right
        anchors.top: frame.top
        anchors.bottom: rectangle3.bottom
        anchors.rightMargin: -4
        anchors.leftMargin: -4
        anchors.bottomMargin: -4
    }
    Frame {
        id: frame
        anchors.left: rectangle.left
        anchors.right: rectangle.right
        anchors.rightMargin: -4
        anchors.leftMargin: -4
        anchors.bottom: rectangle.bottom
        anchors.bottomMargin: -4
        anchors.top: parent.top
        anchors.topMargin: 20
        Text {
            id: cmdText
            anchors.bottom: dataText.bottom
            anchors.top: dataText.top
            font.pointSize: 16
            text: "DATA"
            color: "#d7d6d5"
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
        }
    }

    Text {
        id: dataText
        anchors.left: parent.left
        anchors.leftMargin: 8
        anchors.top: tumbler.top
        anchors.bottom: tumbler.bottom
        font.pointSize: 16
        text: "CMD"
        color: "#d7d6d5"
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
    }

    Rectangle {
        id: rectangle2
        anchors.top: button.bottom
        anchors.topMargin: 4
        anchors.bottom: tumblerOutput.top
        anchors.left: cmdFrame.left
        anchors.right: frame.right
//        anchors.rightMargin: 20
//        anchors.leftMargin: 20
        color: "#b0bdce"
        radius: 3
    }

    Rectangle {
        id: rectangle
        anchors.right: parent.right
        anchors.left: rectangle3.right
        anchors.rightMargin: 8
        anchors.leftMargin: 10
        anchors.top: parent.top
        anchors.topMargin: height*2
        height: parent.height/16
        color: "#d7d6d5"
        radius: 3
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
    }

//    Text {
//        id: outText
//        anchors.fill: rectangle2
//        verticalAlignment: Text.AlignVCenter
//        horizontalAlignment: Text.AlignHCenter
//        color: "#000000"
//        text: ""
//        font.pointSize: 16
//        wrapMode: Text.Wrap
//        clip: true
//    }

    ListView {
        id: logView

        keyNavigationWraps: false
        anchors.fill: rectangle2
        model: outTextModel
        clip: true
        delegate:
            Text {
                font.pointSize: 16
                text: modelData
                color: "#000000"
                wrapMode: Text.Wrap
        }
        ScrollIndicator.vertical: ScrollIndicator { }
    }

    Connections {
                target: backEnd

//                onSendToQml: {
//                    outText.text = mes
//                    if (mes == "Connected")
//                        busyIndicator.visible = false
//                }
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
                    comboBox.displayText = "Choose device"
                }
    }

    Button {
        id: button
        anchors.left: parent.left
        anchors.top: frame.bottom
        anchors.leftMargin: 4
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


    ComboBox {
        visible: false
        id: comboBox
        model: listModel
//        height: rectangle.height*1.8
        anchors.bottom: button.bottom
        anchors.top: button.top
        anchors.left: button.right
        anchors.leftMargin: 4
        anchors.right: button1.left
        anchors.rightMargin: 4
        flat: true
        currentIndex: -1
        displayText: "Choose device"
        background: Rectangle
                {
                    radius: 3
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
//                    leftPadding: 20
                    text: comboBox.displayText
                    color: "#9cbdec"
                    font.pointSize: 14
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                }
                popup: Popup {
                    dim: true
                    width: comboBox.width
                    x: comboBox.width - width
//                    y: comboBox.height + height
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
        anchors.right: rectangle.right
        anchors.bottom: rectangle.top
        anchors.top: frame.top
        width: button1.width*1.6
        background: Rectangle
                {
                    radius: 3
                    color: "#232a37"
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

    ComboBox {
        id: tumblerOutput
        anchors.right: parent.right
        anchors.rightMargin: 4
        anchors.bottom: parent.bottom
        height: tumbler.height
//        anchors.top: comboBox.top
        width: button1.width*1.6
        background: Rectangle
                {
                    radius: 3
                    color: "#232a37"
                    border.width: 0
                }
        model: ["ASCII", "HEX", "DEC"]
        delegate: ItemDelegate {
                            width: tumblerOutput.width
                            contentItem: Text {
                                text: modelData
                                color: "#d7d6d5"
                                font: tumblerOutput.font
                                elide: Text.ElideRight
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignHCenter
                            }
                            highlighted: tumblerOutput.highlightedIndex === index
                        }
                        contentItem: Text {
                            leftPadding: 20
                            text: tumblerOutput.displayText
                            color: "#d7d6d5"
                            font.pointSize: 16
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignHCenter
                        }
                        popup: Popup {
                            width: tumblerOutput.width
                            x: tumblerOutput.width - width
                            y: tumblerOutput.height - height
                            leftPadding: 0
                            padding: 0
                            contentItem: ListView {
                                clip: true
                                implicitHeight: contentHeight
                                model: tumblerOutput.popup.visible ? tumblerOutput.delegateModel : null
                                currentIndex: tumblerOutput.highlightedIndex
                            }
                        }
        currentIndex: settings.indx2FromSettings
        onActivated:
        {
            tumblerOutput.displayText = tumblerOutput.model[tumblerOutput.currentIndex]
            backEnd.setAppSettings(ms, tumblerOutput.currentIndex)
            tumblerIndx = tumblerOutput.currentIndex
        }
    }

    Rectangle {
        id: rectangle3
        anchors.left: cmdFrame.left
        anchors.leftMargin: 4
        anchors.right: dataText.right
        anchors.top: rectangle.top
        anchors.bottom: rectangle.bottom
        radius: 3
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

    Button {
        id: button1
        anchors.right: frame.right
        anchors.bottom: button.bottom
        anchors.top: button.top
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

    Button {
        id: button2
        text: "CLEAR"
        anchors.left: parent.left
        anchors.leftMargin: 4
        anchors.bottom: parent.bottom
        flat: true

        font.pointSize: 16
        highlighted: true
        onClicked:
        {
            outTextModel.clear()
        }
    }
}

