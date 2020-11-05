import QtQuick 2.15
import QtQuick.Controls 2.15
import TableModel 0.1

Page {
    width: 360
    height: 480

    title: qsTr("Logs")

    TableView {
        id: tv
        anchors.fill: parent
        columnSpacing: 1
        rowSpacing: 1
        clip: true

        model: TableModel {}

        delegate: Rectangle {
            border.width: 1
            implicitWidth: 170
            implicitHeight: 40
            Text {
                anchors.fill: parent
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                text: display
            }
        }
    }
}
