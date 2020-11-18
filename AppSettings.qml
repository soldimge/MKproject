import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt.labs.settings 1.0
import QtQuick.Layouts 1.15

Page {
    width: 360
    height: 560

    Settings {
        id: appSetSettings
        property alias checkStateFromSettings: msCS.checkState
    }

    GroupBox {
        title: qsTr("Settings")

        anchors.top: parent.top
        anchors.topMargin: 50
        anchors.left: parent.left
        anchors.leftMargin: 50
        anchors.right: parent.right
        anchors.rightMargin: 50
        ColumnLayout {
            CheckBox
            {
                id: msCS
                text: qsTr("Show ms in logs")
                checkState: appSetSettings.checkStateFromSettings
                onCheckStateChanged:
                {
                    backEnd.setAppSettings(msCS.checkState)
                    ms = msCS.checkState
                }
            }
        }
    }
}

