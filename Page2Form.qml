import QtQuick 2.15
import QtQuick.Controls 2.15

Page {
    width: 432
    height: 672

//    Label {
//        text: qsTr("You are on Page 2.")
//        anchors.centerIn: parent
//    }

    Rectangle {
        id: backgroundTf
        color: "#a0a04e"
        radius: 3
        anchors.right: parent.right
        anchors.left: parent.left
    }

    TextField {
        placeholderText : "DATA"
        anchors.centerIn: parent
        anchors.right: parent.right
        anchors.left: parent.left
        height: parent.height/16
        background : backgroundTf
    }
}
