import QtQuick 2.15
import QtQuick.Controls 2.15


Page {
    width: 360
    height: 560

    Label {
        text: logsListModel.count > 0 ? "" : "Logs will be here"
        anchors.centerIn: logView
    }
    ListView {
        id: logView

        keyNavigationWraps: false
        cacheBuffer: 1000
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.right: parent.right
        anchors.rightMargin: anchors.leftMargin
        anchors.top: parent.top
        anchors.topMargin: anchors.leftMargin
        anchors.bottom: clearLogsButton.top
        model: logsListModel
        clip: true
        delegate:
            Text {
                font.pointSize: Qt.platform.os === "windows" ? 10 : 14
                text: modelData
                color: "#d7d6d5"
                wrapMode: Text.Wrap
        }
        ScrollIndicator.vertical: ScrollIndicator { }
    }

    Button {
        id: clearLogsButton
        anchors.bottom: parent.bottom
        anchors.rightMargin: 10
        flat: true
        width: parent.width/2.2
        height: width/4
        anchors.right: parent.right
        text: "CLEAR"
        onClicked:
        {
            logsListModel.clear()
        }
        hoverEnabled: true

        ToolTip.delay: 1000
        ToolTip.timeout: 5000
        ToolTip.visible: hovered
        ToolTip.text: qsTr("Clear logs")
    }

    Button {
        id: shareLogsButton
        anchors.bottom: parent.bottom
        anchors.leftMargin: 10
        flat: true
        width: parent.width/2.2
        height: width/4
        anchors.left: parent.left
        text: Qt.platform.os === "windows" ? "COPY" : "COPY" //SHARE will be here
        onClicked:
        {
            if (Qt.platform.os === "windows")
            {
                backEnd.copyToBuffer(logString);
            }
            if (Qt.platform.os === "android")
            {
                console.log(logString)
                backEnd.copyToBuffer(logString);
            }
            ttCopy.show("Copied", 3000)
        }
        ToolTip {
            id: ttCopy
            parent: shareLogsButton.handle
        }
        hoverEnabled: true

        ToolTip.delay: 1000
        ToolTip.timeout: 5000
        ToolTip.visible: hovered
        ToolTip.text: qsTr("Copy logs to buffer")
    }
}
