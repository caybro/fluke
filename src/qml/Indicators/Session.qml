import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import QtQuick.Window 2.2
import QtQuick.Controls.Material 2.3

import Qt.labs.settings 1.0

import org.fluke.Session 1.0

ToolButton {
    id: indicatorSession
    icon.width: 16
    icon.height: 16
    down: popupLoader.item && popupLoader.item.visible
    hoverEnabled: true

    property bool autohideDock: false

    ToolTip.text: qsTr("Session")
    ToolTip.visible: hovered && (!popupLoader.item || !popupLoader.item.visible)

    signal logout()
    signal suspend()
    signal reboot()
    signal shutdown()

    Component.onCompleted: {
        indicatorSession.icon.source = Platform.chassis == "laptop" ? "qrc:/icons/laptop-solid.svg" : "qrc:/icons/desktop-solid.svg";
    }

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
                icon.source: "qrc:/icons/sign-out-alt-solid.svg"
                icon.height: 16
                icon.width: 16
                onClicked: indicatorSession.logout()
            }

            MenuItem {
                text: qsTr("Sleep")
                icon.source: "qrc:/icons/moon-solid.svg"
                icon.height: 16
                icon.width: 16
                onClicked: indicatorSession.suspend()
                enabled: Session.canSuspend()
            }

            MenuItem {
                text: qsTr("Restart")
                icon.source: "qrc:/icons/sync-solid.svg"
                icon.height: 16
                icon.width: 16
                onClicked: indicatorSession.reboot()
                enabled: Session.canReboot()
            }

            MenuItem {
                text: qsTr("Shutdown")
                icon.source: "qrc:/icons/power-off-solid.svg"
                icon.height: 16
                icon.width: 16
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
