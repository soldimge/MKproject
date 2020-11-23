import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt.labs.settings 1.0
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15

Page {

    width: Qt.platform.os === "windows" ? 360 : Screen.desktopAvailableWidth
    height: Qt.platform.os === "windows" ? 560 : Screen.desktopAvailableHeight - toolBar.height

    Settings {
        id: appSetSettings
        property alias checkStateFromSettings: msCS.checkState
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
                checkState: appSetSettings.checkStateFromSettings
                onCheckStateChanged:
                {
                    backEnd.setAppSettings(msCS.checkState)
                    ms = msCS.checkState
                }
            }
        }
    }

    GroupBox {
        id: gb2
        anchors.top: gb1.bottom
        anchors.topMargin: 50
        anchors.horizontalCenter: parent.horizontalCenter
        ColumnLayout {
            Text {
                id: timeoutSliderText
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Timeout:       " + timeoutSlider.value + " ms"
                font.pointSize: Qt.platform.os === "windows" ? 12 : 16
                color: "#d7d6d5"
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
                value: appSetSettings.timeoutMsFromSettings === 0 ? 1000 : appSetSettings.timeoutMsFromSettings
                stepSize : 100
                snapMode : Slider.SnapAlways
                onValueChanged: {
                    backEnd.setTimeoutMS(timeoutSlider.value)
                }
            }
            Text {
                id: pauseSliderText
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Pause:          " + pauseSlider.value + " ms"
                font.pointSize: Qt.platform.os === "windows" ? 12 : 16
                color: "#d7d6d5"
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
            value: appSetSettings.pauseMsFromSettings === 0 ? 20 : appSetSettings.pauseMsFromSettings
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
             highlighted: true
             font.pointSize: Qt.platform.os === "windows" ? 12 : 16
             anchors.left: parent.left
             anchors.right: parent.right
             onClicked:
             {
                 pauseSlider.value = 20
                 timeoutSlider.value = 1000
             }
             hoverEnabled: true

//             ToolTip.delay: 1000
//             ToolTip.timeout: 5000
//             ToolTip.visible: hovered
//             ToolTip.text: qsTr("Reset to default")
         }
    }
    }
}




