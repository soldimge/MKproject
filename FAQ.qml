import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.12

Page {
    title: "FAQ.qml"

    Pane {
        id: mainPane
        Material.background: "#f3f3f3"

        anchors {
            top: parent.top
            right: parent.right
            left: parent.left
            bottom: parent.bottom
            margins: 10
        }
        Material.elevation: 2

        Flickable {
            anchors.fill: parent
            clip: true
            contentWidth: parent.width
            contentHeight: innerItem.height

            Column {
                id: innerItem
                spacing: 5
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                }

                Loader {
                    sourceComponent: textContentComponent
                    asynchronous: true
                    width: parent.width
                }
            }
        }
    }

    Component {
        id: textContentComponent
        Label {
            text: "
<h3 style=\"text-align:center;\">IT DOESN'T WORK!</h3><p>For the first connection, first connect your devices in " + "<a href=\"bluetooth\">system settings.</a></p>
<h3 style=\"text-align:center;\">WHY DOES THIS APP NEED LOCATION SERVICE?</h3><p>This issue was brought up to Google where they responded saying that this was the intended behavior and they won't fix it. They directed developers to " + "<a href=\"https://developer.android.com/about/versions/marshmallow/android-6.0-changes.html#behavior-hardware-id\">this site</a>" + " where it points out that location permission is now needed for hardware identifier access. It is now the developer's responsibility to make their users aware of the requirement.</p>
<h3 style=\"text-align:center;\">HOW CAN I ENABLE THE LOCATION SERVICE?</h3><p>In " + "<a href=\"location\">system settings.</a></p>
<h3 style=\"text-align:center;\">HOW CAN I REPORT WISHES AND SUGGESTIONS OR BUGS?</h3><p>You can " + "<style type=\"text/css\"></style><a href=\"mailto:soldimge@gmail.com?subject=Bluetooth terminal%20android%20app\">email me.</a>"
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            horizontalAlignment: Text.AlignJustify
            font.pointSize: Qt.platform.os === "windows" ? 10 : 16
            color: "#000000"
            textFormat: Text.RichText
            onLinkActivated: {
                if(link === "bluetooth")
                    Qt.platform.os === "windows" ? console.log(link) : backEnd.openSystemBluetoothSettings()
                else if(link === "location")
                    Qt.platform.os === "windows" ? console.log(link) : backEnd.openSystemLocationSettings()
                else
                    Qt.openUrlExternally(link)
            }
        }
    }
}

