import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15
import StatusBar 0.1
import QtQuick.Controls.Material 2.12
import Qt.labs.settings 1.0

ApplicationWindow {
    id: window
    width: Qt.platform.os === "windows" ? 360 : Screen.desktopAvailableWidth
    height: Qt.platform.os === "windows" ? 640 : Screen.desktopAvailableHeight
    visible: true

//    minimumWidth : width
//    minimumHeight : height
//    maximumHeight : height
//    maximumWidth : width

    Settings {
            id: mainSettings
            property alias isDarkThemeSettings: window.isDarkTheme
            property alias isWakeOnSettings: window.isWakeOn
        }

    property string logString
//    property int ms
    property int tumblerIndx
    property int tumblerIndx2
    property bool btDevicesVisible

    property bool isDarkTheme: mainSettings.value("isDarkThemeSettings", true)
    property bool isWakeOn: mainSettings.value("isWakeOn", true)

    Material.theme: Material.Light

    onIsDarkThemeChanged: {
//        console.log(isDarkTheme)
        if(isDarkTheme == true) {
            Material.background = "#273354"
            Material.foreground = "#d7d6d5"
            Material.primary = "#9cbdec"
            Material.accent = "#d7d6d5"
            statusBar.color = "#9cbdec"
        }
        else {
            Material.background = "#f3f3f3"
            Material.foreground = "#000000"
            Material.primary = "#f3f3f3"
            Material.accent = "#33cc33"
            statusBar.color = "#f3f3f3"
        }
    }

    StatusBar {
        id: statusBar
        theme: StatusBar.Light //dark background WHITE TEXT
        color: isDarkTheme == true ? "#9cbdec" : "#f3f3f3"
    }

    title: qsTr("Bluetooth Wake Terminal")

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
            {
                busyIndicator.visible = false
                toolButton2.enabled = true
                outText.text = mes
            }
            else if (mes == "Disconnected")
            {
                toolButton2Pic.source = "qrc:/images/bluetooth_off.png"
                toolButton2.enabled = false
                outText.text = mes
            }
            else if (mes == "Search not possible due to turned off Location service")
            {
                dialError.visible = true
            }  
        }
    }

    Dialog {
        id: aboutDialog
        modal: true
        focus: true
        title: "About"
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        width: parent.width*0.7
        contentHeight: aboutColumn.height

        Column {
            id: aboutColumn
            spacing: 20

            Label {
                width: aboutDialog.availableWidth
                text: "Bluetooth terminal\nwith WAKE Serial Protocol\nfor hc-06/hc-05 & similar\nVersion 0.1"
                wrapMode: Label.Wrap
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: Qt.platform.os === "windows" ? 12 : 14
            }

            Label {
                width: aboutDialog.availableWidth
                text: "Contact the developer:"
                    + "<br><style type=\"text/css\"></style><a href=\"mailto:soldimge@gmail.com?subject=Bluetooth terminal%20android%20app\">soldimge@gmail.com</a><br>"
                wrapMode: Label.Wrap
                font.pointSize: Qt.platform.os === "windows" ? 10 : 14
                onLinkActivated: Qt.openUrlExternally(link)
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }

    Dialog {
        id: dialError
        title: "Search not possible due to\nturned off Location service"
        Label {
            width: aboutDialog.availableWidth
            text: "Turn on?"
            wrapMode: Label.Wrap
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: Qt.platform.os === "windows" ? 12 : 14
        }
        modal: true
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        standardButtons: Dialog.Ok | Dialog.Cancel
        onAccepted: {
            toolButton2Pic.source = "qrc:/images/bluetooth_off.png"
            toolButton2.enabled = false
            busyIndicator.visible = false
            toolButton4.enabled = true
            backEnd.openSystemLocationSettings()
        }
        onRejected: {
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

        Label {
            text: stackView.currentItem.title
            anchors {
                top: parent.top
                right: toolButton4.left
                left: toolButton.right
                leftMargin: 20
                bottom: parent.bottom
            }
            verticalAlignment: Text.AlignVCenter
            font.pointSize: Qt.platform.os === "windows" ? 14 : 20
        }

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
            visible: false
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
//                    visible: stackView.depth > 1 ? false : true
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
                text: "About WAKE"
                onClicked:
                {
                    Qt.openUrlExternally("http://www.leoniv.diod.club/articles/wake/wake.html")
                }
            }
            MenuItem {
                highlighted: false
                text: isDarkTheme == true ? qsTr("Light theme") : qsTr("Standard theme")
                onTriggered: {
                    isDarkTheme = (isDarkTheme == true) ? false : true
                }
            }
            MenuItem {
                highlighted: false
                text: "About"
                onTriggered: {
                    aboutDialog.open()
                }
            }
            MenuSeparator {
                width: parent.width
                padding: 0
                topPadding: 4
                bottomPadding: 4
            }
            MenuItem {
                text: "Exit"
                onClicked: Qt.callLater(Qt.quit)
            }
        }
    }

    Drawer {
        id: drawer
        width: window.width * 0.76
        height: window.height

        Column {
            anchors.fill: parent
            DrawerMenuItem {
                image: isDarkTheme == true ? "qrc:/images/Drawer/baseline_home_white@4x.png" : "qrc:/images/Drawer/home@4x.png"
                pageName: "Terminal"
                name: "Home"
                pageSource: "HomeForm.qml"
            }
            MenuSeparator {
                width: parent.width
                padding: 0
                topPadding: 4
                bottomPadding: 4
            }
            DrawerMenuItem {
                image: isDarkTheme == true ? "qrc:/images/Drawer/baseline_article_white@4x.png" : "qrc:/images/Drawer/baseline_article_black@4x.png"
                pageName: "Logs"
                name: "Page with logs"
                pageSource: "Logs.qml"
            }
            DrawerMenuItem {
                image: isDarkTheme == true ? "qrc:/images/Drawer/baseline_settings_white@4x.png" : "qrc:/images/Drawer/baseline_settings_black@4x.png"
                pageName: "Settings"
                name: "Settings"       
                pageSource: "AppSettings.qml"
            }
            MenuSeparator {
                width: parent.width
                padding: 0
                topPadding: 4
                bottomPadding: 4
            }
            DrawerMenuItem {
                image: isDarkTheme == true ? "qrc:/images/Drawer/helpWhite@4x.png" : "qrc:/images/Drawer/helpBlack@4x.png"
                pageName: "F.A.Q."
                name: "F.A.Q."
                pageSource: "FAQ.qml"
            }
        }
    }

    StackView {
        id: stackView
        initialItem: "HomeForm.qml"
        anchors.fill: parent
    }
}
