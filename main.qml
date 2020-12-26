import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15
import StatusBar 0.1

ApplicationWindow {
    id: window
    width: Qt.platform.os === "windows" ? 360 : Screen.desktopAvailableWidth
    height: Qt.platform.os === "windows" ? 640 : Screen.desktopAvailableHeight
    visible: true

    minimumWidth : width
    minimumHeight : height
    maximumHeight : height
    maximumWidth : width

    property string logString
    property int ms
    property int tumblerIndx
    property int tumblerIndx2
    property bool btDevicesVisible

    StatusBar{
        theme: StatusBar.Light //dark background WHITE TEXT
        color: "#9cbdec"
    }

    title: qsTr("LaserApp")

    onClosing: {
        close.accepted = false
        stackView.depth > 1 ? stackView.pop() : dial.open()
    }

    ListModel {
        id: logsListModel
    }

    ListModel {
        id: outTextModel
    }

    Connections {
        target: backEnd

        onAddLog: {
            logsListModel.append({"text" : log})
            if (logString == "")
                logString = log
            else
                logString = logString + "\n" + log
        }

        onAddMes: {
            outTextModel.append({"text" : message})
        }

        onSendToQml: {
            if (mes == "Connected")
                busyIndicator.visible = false      
            else if (mes == "Disconnected")
            {
                toolButton2Pic.source = "qrc:/images/bluetooth_off.png"
                toolButton2.enabled = false
            }
            else if (mes == "Search not possible due to turned off Location service")
            {
                dialError.visible = true
            }

            outText.text = mes
        }
    }

    Dialog {
        id: dialError
        visible: false
        title: "Search not possible due to\nturned off Location service"
        modal: true
        Overlay.modal: Rectangle {
                    color: "#aacfdbe7"
                }
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2

        Button {
                flat: true
                highlighted: true
                width: dialError.width
                anchors.left: parent.left
                anchors.right: parent.right
                onClicked: dialError.visible = false

                Text {
                    text: "Close"
                    font.pointSize: Qt.platform.os === "windows" ? 12 : 16
                    color: "#d7d6d5"
                    anchors.centerIn: parent
                }

        }

        onClosed: {
            toolButton2Pic.source = "qrc:/images/bluetooth_off.png"
            toolButton2.enabled = false
            busyIndicator.visible = false
            toolButton4.enabled = true
        }
    }

    Dialog {
        id: dial
        title: "Close and exit?"
        modal: true
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        standardButtons: Dialog.Ok | Dialog.Cancel
        onAccepted: Qt.callLater(Qt.quit)
    }

    header: ToolBar {
        id: toolBar
        contentHeight: toolButton.implicitHeight

        Text {
            id: outText
            anchors.right: toolButton4.left
            anchors.rightMargin: toolButton4.height/6
            anchors.left: toolButton.right
            anchors.leftMargin: toolButton4.height/6
            anchors.bottom: parent.bottom
            anchors.top: parent.top
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            color: "#000000"
            text: ""
            font.pointSize: 11
            wrapMode: Text.Wrap
            clip: true
        }

        ToolButton {
            id: toolButton
            Image {
                id: toolButtonPic
                anchors.fill: parent
                anchors.centerIn: parent
                fillMode: Image.PreserveAspectFit
                source: stackView.depth > 1 ? "qrc:/images/back.png" : "qrc:/images/drawer.png"
                scale: 0.55
            }
            onClicked: {
                if (stackView.depth > 1) {
                    stackView.pop()
                } else {
                    drawer.open()
                }
            }
        }

        Label {
            text: stackView.currentItem.title
            anchors.centerIn: parent
        }

        ToolButton {
             id: toolButton2
             Image {
                 id: toolButton2Pic
                 anchors.fill: parent
                 anchors.centerIn: parent
                 fillMode: Image.PreserveAspectFit
                 source: "qrc:/images/bluetooth_off.png"
                 scale: 0.55
             }
             anchors.right: toolButton3.left
             anchors.rightMargin: toolButton2.height/6
             flat: true
             enabled: false
             onClicked: {
//                 if (toolButton2Pic.source == "qrc:/images/bluetooth_off.png")
//                 {
//                     toolButton2Pic.source = "qrc:/images/bluetooth_on.png"
////                     backEnd.btConnect()
//                     busyIndicator.visible = true
//                     toolButton4.enabled = false
//                 }
//                 else
//                 {
                     toolButton2Pic.source = "qrc:/images/bluetooth_off.png"
                     backEnd.btDisconnect()
                     busyIndicator.visible = false
                     toolButton4.enabled = true
                     toolButton2.enabled = false
//                 }
             }
        }

        ToolButton {
                id: toolButton4
                anchors.right: toolButton2.left
                anchors.rightMargin: toolButton2.height/6

                Image {
                    id: toolButton4Pic
                    anchors.fill: parent
                    anchors.centerIn: parent
                    fillMode: Image.PreserveAspectFit
                    source: "qrc:/images/search.png"
                    scale: 0.5
                }
                onClicked:
                {
                    toolButton4.enabled = false
                    busyIndicator.visible = true
                    backEnd.btSearch()
                    toolButton2.enabled = true
                    toolButton2Pic.source = "qrc:/images/bluetooth_on.png"
                    btDevicesVisible = false
                    hoverEnabled = false
                }
                hoverEnabled: true

                ToolTip.delay: 1000
                ToolTip.timeout: 5000
                ToolTip.visible: hovered
                ToolTip.text: qsTr("Scan BT devices")
            }


        BusyIndicator {
            id: busyIndicator
            anchors.centerIn: toolButton2
            visible: false
            running: true
        }

        ToolButton {
                id: toolButton3
                anchors.right: parent.right

                Image {
                    id: toolButton3Pic
                    anchors.fill: parent
                    anchors.centerIn: parent
                    fillMode: Image.PreserveAspectFit
                    source: "qrc:/images/menu.png"
                    scale: 0.5
                }
                onClicked: menu.open()
            }

        Menu {
            id: menu
            width: 180
            x: parent.width - width
            y: 0

            MenuItem {
                id: mit2
                text: "Open website"
                onClicked:
                {
                    Qt.openUrlExternally("https://github.com/soldimge/MKproject")
                }
            }
            MenuSeparator {
                padding: 0
                topPadding: 4
                bottomPadding: 4
                contentItem: Rectangle {
                    implicitWidth: 120
                    implicitHeight: 1
                    color: "#0b0d12"
                }
            }
            MenuItem {
                text: "Exit"
                onClicked: Qt.callLater(Qt.quit)
            }
        }
    }

    Drawer {
        id: drawer
        width: window.width * 0.66
        height: window.height

        Column {
            anchors.fill: parent

            ItemDelegate {
                id: logs
                text: qsTr("Page with logs")
                width: parent.width
                onClicked: {
                    stackView.push("Logs.qml")
                    drawer.close()
                }
            }
//            ItemDelegate {
//                text: qsTr("Page 2")
//                width: parent.width
//                onClicked: {
//                    stackView.push("Page2Form.qml")
//                    drawer.close()
//                }
//            }
            ItemDelegate {
                id: appSettings
                text: qsTr("AppSettings")
                width: parent.width
                onClicked: {
                    stackView.push("AppSettings.qml")
                    drawer.close()
                }
            }
        }
    }

    StackView {
        id: stackView
        initialItem: "HomeForm.qml"
        anchors.fill: parent
    }
}
