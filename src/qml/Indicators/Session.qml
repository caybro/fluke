import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Window 2.2
import QtQuick.Controls.Material 2.2

import Qt.labs.settings 1.0

import org.fluke.Session 1.0

ToolButton {
    id: indicatorSession
    font.weight: Font.DemiBold
    text: "\uf013"

    property bool autohideDock: false

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
        y: parent.height - parent.bottomPadding

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

            MenuItem {
                id: autohideDockCheckbox
                checkable: true
                checked: indicatorSession.autohideDock
                onToggled: {
                    indicatorSession.autohideDock = checked
                }

                text: qsTr("Autohide Dock")
            }

            MenuSeparator {}

            MenuItem {
                text: "\uf2f5    " + qsTr("Logout")
                onClicked: indicatorSession.logout()
            }

            MenuItem {
                text: "\uf186    " + qsTr("Sleep")
                onClicked: indicatorSession.suspend()
                enabled: Session.canSuspend()
            }

            MenuItem {
                text: "\uf021    " + qsTr("Restart")
                onClicked: indicatorSession.reboot()
                enabled: Session.canReboot()
            }

            MenuItem {
                text: "\uf011    " + qsTr("Shutdown")
                onClicked: indicatorSession.shutdown()
                enabled: Session.canShutdown()
            }

            Component.onCompleted: {
                if (!debugMode) {
                    removeItem(0); // removes the "Fullscreen" checkbox in production mode
                }
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
