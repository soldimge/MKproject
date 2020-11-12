import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt.labs.settings 1.0

Page {
    width: 360
    height: 560

    property alias appSetSettings: appSetSettings
    property alias switch1: switch1

    Settings {
        id: appSetSettings
        property bool tumblerIndxFromSettings: false
    }

    Switch {
        id: switch1
        anchors.top: parent.top
        anchors.topMargin: 50
        anchors.left: parent.left
        anchors.leftMargin: 50
        text: qsTr("Show ms in logs")
        onClicked: {
            appSetSettings.tumblerIndxFromSettings = !appSetSettings.tumblerIndxFromSettings
            ms = appSetSettings.tumblerIndxFromSettings
            backEnd.setAppSettings(appSetSettings.tumblerIndxFromSettings, tumblerIndx)
        }
        position: appSetSettings.tumblerIndxFromSettings
    }
}

