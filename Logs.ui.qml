import QtQuick 2.15
import QtQuick.Controls 2.15

Page {
    width: 360
    height: 560

    Label {
        text: logsListModel.count > 0 ? "" : "Logs will be here"
        anchors.centerIn: parent
    }

    Connections {
                target: backEnd

                onAddLog: {
                    logsListModel.append({log});
                }
    }

    ListView {
        id: logView
        width: parent.width-10
        height: parent.height-10
        keyNavigationWraps: false
        cacheBuffer: 1000
        anchors.centerIn: parent
        model: logsListModel
        clip: true
        delegate:
            Text {
                font.pointSize: 10
                text: modelData
                color: "#d7d6d5"
                wrapMode: Text.Wrap
                clip: true
        }
        ScrollIndicator.vertical: ScrollIndicator { }
    }

    ListModel {
        id: logsListModel
    }
}
