import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Window 2.3
import QtWayland.Compositor 1.0
import QtQuick.Controls.Material 2.2

import org.fluke.TaskManager 1.0
import org.fluke.Session 1.0

WaylandOutput {
    id: output
    sizeFollowsWindow: true

    property alias screen: win.screen
    readonly property alias surfaceArea: workspace
    property var viewsBySurface: ({}) // QWaylandSurface -> QWaylandView

    Component.onCompleted: {
        compositor.defaultSeat.keymap.layout = "cz";
        compositor.defaultSeat.keymap.variant = "qwerty";
    }

    readonly property Connections _conn: Connections {
        target: compositor
        onSurfaceAboutToBeDestroyed: {
            delete viewsBySurface[surface];
        }
    }

    readonly property SystemPalette _pal: SystemPalette {
        colorGroup: SystemPalette.Active
    }

    window: ApplicationWindow {
        id: win
        x: Screen.virtualX
        y: Screen.virtualY
        width: 1024 // screen.width // FIXME enable when running in a real session
        height: 768 // screen.height
        visible: true

        Material.theme: Material.Dark
        Material.accent: _pal.highlight

        background: Image {
            fillMode: Image.Tile
            asynchronous: true
            source: "qrc:/images/background.jpg"
        }

        WaylandMouseTracker {
            id: mouseTracker
            anchors.fill: parent
            windowSystemCursorEnabled: false

            Panel  {
                id: panel
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                appLauncherVisible: appLauncher.visible
                onLogout: {
                    systemDialog.title = qsTr("Log Out");
                    systemDialog.text = qsTr("Do you really want to logout?");
                    systemDialog.acceptedFunctionCallback = function() { Qt.quit() }
                    systemDialog.open();
                }
                onSuspend: {
                    systemDialog.title = qsTr("Suspend");
                    systemDialog.text = qsTr("Do you really want to suspend the computer?");
                    systemDialog.acceptedFunctionCallback = function() { Session.suspend() }
                    systemDialog.open();
                }
                onReboot: {
                    systemDialog.title = qsTr("Restart");
                    systemDialog.text = qsTr("Do you really want to restart the computer?");
                    systemDialog.acceptedFunctionCallback = function() { Session.reboot() }
                    systemDialog.open();
                }
                onShutdown: {
                    systemDialog.title = qsTr("Shutdown");
                    systemDialog.text = qsTr("Do you really want to turn off the computer?");
                    systemDialog.acceptedFunctionCallback = function() { Session.shutdown() }
                    systemDialog.open();
                }
                onShowLauncher: appLauncher.visible ? appLauncher.hide() : appLauncher.show()
            }

            Item {
                id: workspace
                focus: true
                readonly property alias appLauncherVisible: appLauncher.visible
                anchors.top: panel.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: dock.top
            }

            ApplicationLauncher {
                id: appLauncher
                anchors.fill: workspace
                opacity: 0.0
            }

            Dock {
                id: dock
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
            }

            //            Loader {
            //                anchors.fill: parent
            //                source: "Keyboard.qml"
            //            }

            WaylandCursorItem {
                id: cursor
                inputEventsEnabled: false
                x: mouseTracker.mouseX
                y: mouseTracker.mouseY

                seat: output.compositor.defaultSeat
                visible: mouseTracker.containsMouse
            }
        }

        Shortcut {
            sequence: "Ctrl+Alt+Backspace"
            context: Qt.ApplicationShortcut
            onActivated: panel.logout();
        }

        Shortcut {
            sequence: "Ctrl+Alt+T"
            context: Qt.ApplicationShortcut
            onActivated: {
                Runner.runCommand("konsole");
            }
        }

        Shortcut {
            sequence: Qt.Key_VolumeMute
            context: Qt.ApplicationShortcut
            onActivated: panel.soundIndicator ? panel.soundIndicator.toggleMute() : undefined
        }

        Shortcut {
            sequence: Qt.Key_VolumeUp
            context: Qt.ApplicationShortcut
            onActivated: panel.soundIndicator ? panel.soundIndicator.increaseVolume() : undefined
        }

        Shortcut {
            sequence: Qt.Key_VolumeDown
            context: Qt.ApplicationShortcut
            onActivated: panel.soundIndicator ? panel.soundIndicator.decreaseVolume() : undefined
        }

        Dialog {
            id: systemDialog
            x: (parent.width - width) / 2
            y: (parent.height - height) / 2
            modal: true
            focus: visible
            visible: false
            standardButtons: Dialog.Ok | Dialog.Cancel
            onOpened: forceActiveFocus(Qt.PopupFocusReason)
            onAccepted: acceptedFunctionCallback()
            onClosed: acceptedFunctionCallback = function() {} // reset
            property alias text: label.text
            property var acceptedFunctionCallback: function() {}
            Label {
                id: label
            }
        }
    }
}
