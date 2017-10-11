import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Window 2.2
import QtQuick.Controls.Material 2.2

import org.fluke.Session 1.0

ToolButton {
    id: indicatorSession
    font.pointSize: 14
    font.weight: Font.DemiBold
    text: "\uf013"

    Component.onCompleted: {
        indicatorSession.text = Platform.chassis == "laptop" ? "\uf109" : "\uf108";
    }

    ToolTip.text: qsTr("Session")
    ToolTip.visible: hovered && (!popupLoader.item || !popupLoader.item.visible)

    signal logout()
    signal suspend()
    signal reboot()
    signal shutdown()

    Loader {
        id: popupLoader
        active: false
        focus: visible
        y: parent.height

        sourceComponent: Menu {
            closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

            MenuItem {
                checkable: true
                checked: window.visibility == Window.FullScreen
                onToggled: {
                    window.visibility = checked ? Window.FullScreen : Window.Windowed
                }
                text: qsTr("Fullscreen")
            }

            MenuItem {
                checkable: true
                checked: window.Material.theme === Material.Dark
                onToggled: {
                    window.Material.theme = checked ? Material.Dark : Material.Light
                }
                text: qsTr("Dark Theme")
            }

            MenuSeparator {}

            MenuItem {
                text: "\uf08b\t" + qsTr("Logout")
                onClicked: indicatorSession.logout()
            }

            MenuItem {
                text: "\uf186\t" + qsTr("Sleep")
                onClicked: indicatorSession.suspend()
                enabled: Session.canSuspend()
            }

            MenuItem {
                text: "\uf021\t" + qsTr("Restart")
                onClicked: indicatorSession.reboot()
                enabled: Session.canReboot()
            }

            MenuItem {
                text: "\uf011\t" + qsTr("Shutdown")
                onClicked: indicatorSession.shutdown()
                enabled: Session.canShutdown()
            }
        }
    }

    onClicked: {
        if (!popupLoader.item) {
            popupLoader.active = true;
        }

        if (popupLoader.item.visible) {
            popupLoader.item.close();
        } else {
            popupLoader.item.open();
        }
    }
}
