import QtQuick 2.15
import QtQuick.Controls 2.15

Page {
    width: 360
    height: 640

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
        }
        ScrollIndicator.vertical: ScrollIndicator { }
    }
    ListModel {
        id: logsListModel
    }


//    ComboBox {
//        id: comboBox
//        model: logsListModel
//        anchors.fill: parent
//        flat: true
//        currentIndex: -1
//        displayText: "Choose device"
//        background: Rectangle
//                {
//                    color: "#232a37"
//                    border.width: 0
//                }
//        delegate: ItemDelegate {
//                    width: comboBox.width
//                    contentItem: Text {
//                        text: modelData
//                        color: "#9cbdec"
//                        font: comboBox.font
//                        elide: Text.ElideRight
//                        verticalAlignment: Text.AlignVCenter
//                        horizontalAlignment: Text.AlignHCenter
//                    }
//                    highlighted: comboBox.highlightedIndex === index
//                }

//                contentItem: Text {
//                    leftPadding: 20
//                    text: comboBox.displayText
//                    color: "#9cbdec"
//                    font.pointSize: 22
//                    verticalAlignment: Text.AlignVCenter
//                    horizontalAlignment: Text.AlignHCenter
//                }
//                popup: Popup {
//                    width: comboBox.width
//                    x: parent.width - width
//                    y: comboBox.height - height
//                    leftPadding: 0
//                    implicitHeight: parent.height*0.8
//                    padding: 0
//                    contentItem: ListView {
//                        clip: true
//                        implicitHeight: contentHeight
//                        model: comboBox.popup.visible ? comboBox.delegateModel : null
//                        currentIndex: comboBox.highlightedIndex
//                    }
//                }
//    }
}
