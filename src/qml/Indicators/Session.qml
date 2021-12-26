import QtQuick 2.12
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import QtQuick.Window 2.2
import QtQuick.Controls.Material 2.12

import Qt.labs.settings 1.0

import org.fluke.Session 1.0

ToolButton {
    id: indicatorSession
    icon.width: 16
    icon.height: 16
    icon.source: Platform.chassis == "laptop" ? "qrc:/icons/material/laptop-24px.svg"
                                              : "qrc:/icons/material/desktop_windows-24px.svg";
    down: popupLoader.item && popupLoader.item.visible
    hoverEnabled: true

    property bool autohideDock: false
    property bool darkMode: true

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
        width: 300

        sourceComponent: Menu {
            closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

            MenuItem {
                checkable: true
                checked: window.visibility === Window.FullScreen
                onToggled: {
                    window.visibility = checked ? Window.FullScreen : Window.Windowed
                }
                text: qsTr("Fullscreen")
            }

            MenuItem {
                checkable: true
                checked: indicatorSession.darkMode
                onToggled: {
                    indicatorSession.darkMode = checked
                }
                text: qsTr("Dark Theme")
            }

            MenuItem {
                text: qsTr("Autohide Dock")
                checkable: true
                checked: indicatorSession.autohideDock
                onToggled: {
                    indicatorSession.autohideDock = checked
                }
            }

            MenuSeparator {}

            MenuItem {
                text: qsTr("Logout")
                icon.source: "qrc:/icons/material/login-24px.svg"
                icon.height: 16
                icon.width: 16
                onClicked: indicatorSession.logout()
            }

            MenuItem {
                text: qsTr("Sleep")
                icon.source: "qrc:/icons/material/brightness_3-24px.svg"
                icon.height: 16
                icon.width: 16
                onClicked: indicatorSession.suspend()
                enabled: Session.canSuspend()
            }

            MenuItem {
                text: qsTr("Restart")
                icon.source: "qrc:/icons/material/autorenew-24px.svg"
                icon.height: 16
                icon.width: 16
                onClicked: indicatorSession.reboot()
                enabled: Session.canReboot()
            }

            MenuItem {
                text: qsTr("Shutdown")
                icon.source: "qrc:/icons/material/power_settings_new-24px.svg"
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
