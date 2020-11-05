import QtQuick 2.15
import QtQuick.Controls 2.15

ApplicationWindow {
    id: window
    width: 360
    height: 480
    visible: true
    title: qsTr("Stack")

    onClosing: {
        close.accepted = false
        dial.visible = true
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
            color: "#121c2f"
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
        contentHeight: toolButton.implicitHeight

        ToolButton {
            id: toolButton
            text: stackView.depth > 1 ? "\u25C0" : "\u2630"
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
//             text: "connect"
             Image {
                 id: toolButton2Pic
                 anchors.fill: parent
                 anchors.centerIn: parent
                 fillMode: Image.PreserveAspectFit
                 source: "qrc:/images/bluetooth_off.png"
                 scale: 0.55
             }
             anchors.right: toolButton3.left
             anchors.rightMargin: 10
             flat: true
             onClicked: {
                 if (toolButton2Pic.source == "qrc:/images/bluetooth_off.png")
                 {
                     console.log(toolButton2Pic.source);
                     toolButton2Pic.source = "qrc:/images/bluetooth_on.png"
                     backEnd.on_pushButton_Connect_clicked()
                 }
                 else
                 {
                     console.log(toolButton2Pic.source);
                     toolButton2Pic.source = "qrc:/images/bluetooth_off.png"
                     backEnd.on_pushButton_Disconnect_clicked()
                 }

             }
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
                text: "Перейти на сайт"
            }
            MenuItem {
                id: mit4
                Button {
                    id: butMit4VK
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.leftMargin: 3
                    width: height*0.86
                    flat: true
                    highlighted: true
                    Image {
                        anchors.fill: parent
                        anchors.centerIn: butMit4VK
                        fillMode: Image.PreserveAspectFit
                        source: "images/vk.png"
                        scale: 0.5
                    }
                }
                Button {
                    id: butMit4IN
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.left: butMit4VK.right
                    anchors.leftMargin: 3
                    width: height*0.86
                    flat: true
                    highlighted: true
                    Image {
                        anchors.fill: parent
                        anchors.centerIn: butMit4IN
                        fillMode: Image.PreserveAspectFit
                        source: "images/instagram.png"
                        scale: 0.5
                    }
                }
                Button {
                    id: butMit4FB
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.left: butMit4IN.right
                    anchors.leftMargin: 3
                    width: height*0.86
                    flat: true
                    highlighted: true
                    Image {
                        anchors.fill: parent
                        anchors.centerIn: butMit4FB
                        fillMode: Image.PreserveAspectFit
                        source: "images/fb.png"
                        scale: 0.5
                    }
                }
                Button {
                    id: butMit4VB
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.left: butMit4FB.right
                    anchors.leftMargin: 3
                    width: height*0.86
                    flat: true
                    highlighted: true
                    Image {
                        anchors.fill: parent
                        anchors.centerIn: butMit4VB
                        fillMode: Image.PreserveAspectFit
                        source: "images/viber.png"
                        scale: 0.5
                    }
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
                text: "Выход"
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
                text: qsTr("Logs")
                width: parent.width
                onClicked: {
                    stackView.push("Page1Form.ui.qml")
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
        }
    }

    StackView {
        id: stackView
        initialItem: "HomeForm.ui.qml"
        anchors.fill: parent
    }
    HomeForm
    {
        button.onClicked: {
            textInput.text = ""
        }
        button1.onClicked: {
            backEnd.sendMessageToDevice(textInput.text /*+ "\r"*/)
        }
    }
}
