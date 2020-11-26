import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt.labs.settings 1.0
import QtQuick.Window 2.15
//import QtQuick.Controls.Styles 1.4

Page {
    property alias hpage: hpage
    property alias textInput: textInput
    property alias button: button
    property alias button1: button1
    property alias comboBox: comboBox
    property alias cmdInput: cmdInput
    property alias tumbler: tumbler
    property alias settings: settings
    property alias tumblerOutput: tumblerOutput

    width: Qt.platform.os === "windows" ? 360 : Screen.desktopAvailableWidth
    height: Qt.platform.os === "windows" ? 560 : Screen.desktopAvailableHeight - toolBar.height
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
        anchors.topMargin: 10
    }

    Text {
        id: cmdText
        anchors.left: frame.left
        anchors.right: tumbler.left
        anchors.verticalCenter: tumbler.verticalCenter
        font.pointSize: 16
        text: "DATA"
        color: "#9cbdec"
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
    }

    Text {
        id: dataText
        anchors.left: parent.left
        anchors.leftMargin: 8
        anchors.verticalCenter: tumbler.verticalCenter
        font.pointSize: 16
        text: "CMD"
        color: "#9cbdec"
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
    }

    Rectangle {
        id: rectangle2
        anchors.top: comboBox.bottom
//        anchors.topMargin: 4
        anchors.bottom: tumblerOutput.top
        anchors.left: cmdFrame.left
        anchors.right: frame.right
        color: "#cdd4dc"
        radius: 3
    }

    Rectangle {
        id: rectangle
        anchors.right: parent.right
        anchors.left: rectangle3.right
        anchors.rightMargin: 8
        anchors.leftMargin: 10
        anchors.top: tumbler.bottom
//        anchors.topMargin: height*2
        height: parent.width/10
        color: "#d7d6d5"
        radius: 3
        TextInput {
            id: textInput
            anchors.fill: rectangle
            anchors.leftMargin: 4
            anchors.rightMargin: 4
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignLeft
            text: ""
            font.pointSize: 16
            wrapMode: Text.Wrap
            clip: true
        }
    }

    ListView {
        id: logView

        keyNavigationWraps: false
        anchors.fill: rectangle2
        anchors.leftMargin: 4
        anchors.rightMargin: 4
        anchors.topMargin: 4
        anchors.bottomMargin: 4
        model: outTextModel
        clip: true
        delegate:
            Text {
                font.pointSize: 16
                text: modelData
                color: "#000000"
                wrapMode: Text.Wrap
                clip: true
        }
        ScrollIndicator.vertical: ScrollIndicator { }
        onCountChanged: {
            logView.currentIndex = logView.count - 1
        }
    }

    Connections {
                target: backEnd

                onAddDevice: {
                    listModel.append({"text" : name});
                }
                onEndOfSearch: {
                    listModel.clear()
                    btDevicesVisible = true
                    toolButton4.enabled = true
                    busyIndicator.visible = false
                    toolButton2.enabled = true
                    outText.text = "Search finished"
                    comboBox.displayText = "Choose device"
                    if (stackView.depth === 1)
                        comboBox.popup.visible = true
                    toolButton4.hoverEnabled = true
                }
    }

    Button {
        id: button
        anchors.left: parent.left
        anchors.top: frame.bottom
        anchors.bottom: button1.bottom
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
        visible: btDevicesVisible
//        visible: true
        id: comboBox
        model: listModel
        anchors.top: button.bottom
        anchors.topMargin: -6
        height: rectangle.height * 1.4
        anchors.left: parent.left
        anchors.leftMargin: 4
        anchors.right: parent.right
        anchors.rightMargin: 4
        flat: true
        currentIndex: -1
        displayText: "Choose device"
        background: Rectangle
                {
                    radius: 3
                    color: "#11ffffff"
                    border.width: 0
                }
        delegate: ItemDelegate {
                    width: comboBox.width
                    contentItem: Text {
                        text: modelData
                        color: "#d7d6d5"
                        font: comboBox.font
                        elide: Text.ElideRight
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Qt.platform.os === "windows" ? Text.AlignHCenter : Text.AlignLeft
                        anchors.leftMargin: 4
                    }
                    highlighted: comboBox.highlightedIndex === index             
                }

                contentItem: Text {
                    text: Qt.platform.os === "windows" ? comboBox.displayText : comboBox.displayText == "Choose device" ? comboBox.displayText : comboBox.displayText.substring(0, comboBox.displayText.indexOf("\t"))
                    color: "#d7d6d5"
                    font.pointSize: Qt.platform.os === "windows" ? 14 : 16
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                }
                popup: Popup {
                    dim: true
                    width: comboBox.width
                    x: comboBox.width - width
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
            Qt.platform.os === "windows" ? backEnd.connectToDevice(comboBox.displayText) : backEnd.connectToDevice(comboBox.displayText.substring(0, comboBox.displayText.indexOf("\t")))
            toolButton2Pic.source = "qrc:/images/bluetooth_on.png"
            toolButton4.enabled = true
        }
    }

    ListModel {
        id: listModel
    }

    ComboBox {
        id: tumbler
        anchors.right: rectangle.right
        height: comboBox.height
        flat: true
        anchors.top: frame.top
        anchors.left: button1.left
        background: Rectangle
            {
                radius: 3
                color: "#11ffffff"
                border.width: 0
            }
        currentIndex: settings.indxFromSettings
        model: ["ASCII", "HEX", "DEC"]
        displayText: currentIndex === -1 ? "ASCII" : tumbler.model[settings.indxFromSettings]
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
        }

    ComboBox {
        id: tumblerOutput
        anchors.right: parent.right
        anchors.rightMargin: 4
        anchors.bottom: parent.bottom
        flat: true
        height: tumbler.height
        width: tumbler.width
        background: Rectangle
                {
                    radius: 3
                    color: "#11ffffff"
                    border.width: 0
                }
        currentIndex: settings.indxFromSettings2
        model: ["ASCII", "HEX", "DEC"]
        displayText: currentIndex === -1 ? "ASCII" : tumblerOutput.model[settings.indxFromSettings2]
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
        onActivated:
        {
//            tumblerOutput.displayText = tumblerOutput.model[tumblerOutput.currentIndex]
            backEnd.setCmdType(tumblerOutput.currentIndex)
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
            text: "0"
            font.pointSize: 16
            wrapMode: Text.Wrap
            clip: true
        }
    }

    Button {
        id: button1
        anchors.right: frame.right
//        anchors.bottom: button.bottom
        anchors.top: button.top
        width: parent.width / 3.2
        height: tumbler.height * 1.2
        text: "SEND"
        flat: true
        highlighted: true
        font.pointSize: 16
        enabled: outText.text === "Connected" ? true : false
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
        anchors.top: tumblerOutput.top
        flat: true

        font.pointSize: 16
        highlighted: true
        onClicked:
        {
            outTextModel.clear()
        }
    }
}

