import QtQuick 2.9
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import QtQuick.Window 2.2
import QtQuick.Controls.Material 2.2

import Qt.labs.settings 1.0

import org.fluke.Session 1.0

ToolButton {
    id: indicatorSession
    font.weight: Font.DemiBold
    down: popupLoader.item && popupLoader.item.visible

    icon {
        name: "computer-symbolic"
        height: 16
    }

    property bool autohideDock: false

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
                text: qsTr("Logout")
                icon.name: "application-exit-symbolic"
                icon.height: 16
                onClicked: indicatorSession.logout()
            }

            MenuItem {
                text: qsTr("Sleep")
                icon.name: "night-light-symbolic"
                icon.height: 16
                onClicked: indicatorSession.suspend()
                enabled: Session.canSuspend()
            }

            MenuItem {
                text: qsTr("Restart")
                icon.name: "view-refresh-symbolic"
                icon.height: 16
                onClicked: indicatorSession.reboot()
                enabled: Session.canReboot()
            }

            MenuItem {
                text: qsTr("Shutdown")
                icon.name: "system-shutdown-symbolic"
                icon.height: 16
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
