import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.12
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.0

MenuItem {
    id: drawrMenuItem
    property alias name: txt.text
    property alias image: image.source
    property alias pageName: drawrMenuItem.pageName
    property var pageName
    property bool isActive: stackView.currentItem.title === pageName

    Image {
        id: image
        anchors.left: parent.left
        anchors.leftMargin: 15
//        height: parent.height
        anchors.verticalCenter: parent.verticalCenter
        fillMode: Image.PreserveAspectFit
        ColorOverlay {
            id: colorOverlay
            visible: isActive
            anchors.fill: image
            source: image
            color: isDarkTheme == true ? "#9cbdec" : "#33cc33"
        }
    }
    Text {
        id: txt
        anchors.left: image.right
        anchors.leftMargin: 15
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        verticalAlignment: Text.AlignVCenter
        font.pointSize: Qt.platform.os === "windows" ? 12 : 16
        color: isDarkTheme == true ? "#ffffff" : "#000000"
    }

//    Material.foreground: "#000000"
    highlighted: isActive
    width: parent.width

    onTriggered: {
        if (name === "Home" && stackView.depth > 1)
        {
            stackView.clear()
            stackView.push(pageName)
        }
        else if (name != "Home")
            stackView.push(pageName)
        drawer.close()
    }
}
