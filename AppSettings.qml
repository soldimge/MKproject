import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt.labs.settings 1.0
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import QtQuick.Controls.Material 2.12

Page {
    id: settingsPage
    title: "Settings"

    Settings {
        id: appSetSettings
        property alias checkStateFromSettings: msCS.checkState
        property alias useWakeFromSettings: useWake.checkState
        property alias use10FromSettings: use10.checkState
        property alias pauseMsFromSettings: pauseSlider.value
        property alias timeoutMsFromSettings: timeoutSlider.value
    }

    GroupBox {
        id: gb1

        anchors.top: parent.top
        anchors.topMargin: 50
        anchors.left: gb2.left
        anchors.right: gb2.right
        ColumnLayout {
            CheckBox
            {
                id: msCS
                text: qsTr("Show ms in logs")
                checkState: appSetSettings.value("checkStateFromSettings", Qt.Unchecked)
                onCheckStateChanged:
                {
                    backEnd.setAppSettings(msCS.checkState, useWake.checkState)
//                    ms = msCS.checkState
                }
            }
            CheckBox
            {
                id: use10
                text: qsTr("10 command buttons")
                checkState: appSetSettings.value("use10FromSettings", Qt.Unchecked)
                onCheckStateChanged:
                {
                    cmdButtons10 = use10.checkState
                }
            }
            CheckBox
            {
                id: useWake
                text: qsTr("WAKE Serial Protocol")
                checkState: appSetSettings.value("useWakeFromSettings", Qt.Checked)
                onCheckStateChanged:
                {
                    backEnd.setAppSettings(msCS.checkState, useWake.checkState)
                    isWakeOn = useWake.checkState
                }
            }
        }
    }

    Image {
        id: image
        anchors.top: gb1.bottom
        anchors.left: gb1.left
        anchors.right: gb1.right
        fillMode: Image.PreserveAspectFit
        source: isDarkTheme == true ? "qrc:/images/wake.png" : "qrc:/images/wake_logo.gif"
        scale: 0.5
        opacity: useWake.checkState ? 1 : 0.2
    }

    GroupBox {
        id: gb2
        enabled: useWake.checkState
        anchors.top: image.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        ColumnLayout {
            Label {
                id: timeoutSliderText
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Timeout:       " + timeoutSlider.value + " ms"
                font.pointSize: Qt.platform.os === "windows" ? 12 : 16
//                color: "#d7d6d5"
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignLeft
            }
            Slider {
                id: timeoutSlider
                anchors.left: parent.left
                anchors.leftMargin: 10
                anchors.right: parent.right
                to: 5000
                from: 100
                anchors.rightMargin: 10
                orientation: Qt.Horizontal
                value: appSetSettings.value("timeoutMsFromSettings" , 1000)
                stepSize : 100
                snapMode : Slider.SnapAlways
                onValueChanged: {
                    backEnd.setTimeoutMS(timeoutSlider.value)
                }
            }
            Label {
                id: pauseSliderText
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Pause:          " + pauseSlider.value + " ms"
                font.pointSize: Qt.platform.os === "windows" ? 12 : 16
//                color: "#d7d6d5"
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignLeft
            }
         Slider {
            id: pauseSlider
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.right: parent.right
            to: 50
            from: 5
            anchors.rightMargin: 10
            orientation: Qt.Horizontal
            value: appSetSettings.value("pauseMsFromSettings" , 20)
            stepSize : 5
            snapMode : Slider.SnapAlways
            onValueChanged: {
                backEnd.setPauseMS(pauseSlider.value)
            }
         }
         Button {
             id: button
             text: "RESET"
             flat: true
             font.pointSize: Qt.platform.os === "windows" ? 12 : 16
             anchors.left: parent.left
             anchors.right: parent.right
             onClicked:
             {
                 pauseSlider.value = 20
                 timeoutSlider.value = 1000
             }
         }
    }
    }
}




