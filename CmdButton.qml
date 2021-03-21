import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.2
import QtQuick.Layouts 1.15
import Qt.labs.settings 1.0

Button {
    Dialog {
        id: inputDialog

        x: (parent.width - width) / 2
        y: (parent.height - height) / 3
        parent: Overlay.overlay
        width: window.width*0.9
        modal: true
        title: "Save"
        standardButtons: Dialog.Ok | Dialog.Cancel

//        onAccepted: auth.signIn(emailAu.text, passwordAu.text)

        ColumnLayout {
            spacing: 20
            anchors.fill: parent

            TextField {
                id: cmdTF
                focus: true
                placeholderText: "Cmd"
                horizontalAlignment: Text.AlignHCenter
                placeholderTextColor: "#6b7176"
                wrapMode: Text.Wrap
                text: cmdButSettings.value("cmdStrSettings" , "")
                Layout.fillWidth: true
            }

            TextField {
                id: dataTF
                focus: true
                placeholderText: "Data"
                horizontalAlignment: Text.AlignHCenter
                placeholderTextColor: "#6b7176"
                wrapMode: Text.Wrap
                text: cmdButSettings.value("comStrSettings" , "")
                Layout.fillWidth: true
            }

        }
    }
    id: buttonCmd
    property alias name: txt.text

    Settings {
            id: cmdButSettings
            property alias comStrSettings: dataTF.text
            property alias cmdStrSettings: cmdTF.text
        }

    width: (parent.width - 4 * 10) / 5
    height: width * 0.8
    Label {
        id: txt
        anchors.centerIn: parent
        font.pointSize: Qt.platform.os === "windows" ? 11 : 14
    }
    onClicked: {
        console.log("Clicked")
    }
    onPressAndHold: {
        inputDialog.open()
    }

    Material.background: isDarkTheme == true ? "#35415f" : "#d7d6d5"
}
