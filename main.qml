import QtQuick 2.15
import QtQuick.Controls 2.15

ApplicationWindow {
    id: window
    width: 360
    height: 640
    visible: true

    property string logString
    property int ms : 0
    property int tumblerIndx
    property int tumblerIndx2

    title: qsTr("LaserApp")

    onClosing: {
        close.accepted = false
        dial.visible = true
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
            outText.text = mes
        }
    }

    Dialog {
        id: dial
        visible: false
        title: "Закрыть и выйти?"
        modal: true
        Overlay.modal: Rectangle {
                    color: "#aacfdbe7"
                }
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        contentItem: Rectangle {
            implicitWidth: 130
            implicitHeight: 40
            color: "#273354"
            Button {
                id: b1
                flat: true
                highlighted: true
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                onClicked:
                {
                    Qt.callLater(Qt.quit)
                }
                Text {
                    text: "Да"
                    font.pointSize: 12
                    color: "#d7d6d5"
                    anchors.centerIn: parent
                }
            }
            Button {
                flat: true
                highlighted: true
                anchors.left: parent.left
                anchors.bottom: parent.bottom
                onClicked: dial.visible = false
                Text {
                    text: "Нет"
                    font.pointSize: 12
                    color: "#d7d6d5"
                    anchors.centerIn: parent
                }
            }
        }
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
            font.pointSize: Qt.application.font.pointSize * 1.6
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
             onClicked: {
                 if (toolButton2Pic.source == "qrc:/images/bluetooth_off.png")
                 {
                     console.log(toolButton2Pic.source);
                     toolButton2Pic.source = "qrc:/images/bluetooth_on.png"
                     backEnd.on_pushButton_Connect_clicked()
                     busyIndicator.visible = true
                     toolButton4.enabled = false;
                     backEnd.setAppSettings(ms, tumblerIndx)
                 }
                 else
                 {
                     console.log(toolButton2Pic.source);
                     toolButton2Pic.source = "qrc:/images/bluetooth_off.png"
                     backEnd.on_pushButton_Disconnect_clicked()
                     busyIndicator.visible = false
                     toolButton4.enabled = true;
                 }
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
                    toolButton4.enabled = false;
                    busyIndicator.visible = true
                    backEnd.setAppSettings(ms, tumblerIndx)
                    backEnd.on_pushButton_Search_clicked()
                    toolButton2.enabled = false;             
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

                Text {
                    anchors.centerIn: toolButton3
                    text: "⋮"
                    bottomPadding: 5
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pointSize: 36
                    color: "#000000"
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
                text: qsTr("Page with logs")
                width: parent.width
                onClicked: {
                    stackView.push("Logs.qml")
                    drawer.close()
                }
            }
            ItemDelegate {
                text: qsTr("Page 2")
                width: parent.width
                onClicked: {
                    stackView.push("Page2Form.ui.qml")
                    drawer.close()
                }
            }
            ItemDelegate {
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
