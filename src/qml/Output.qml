import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Window 2.2
import QtWayland.Compositor 1.0
import QtQuick.Controls.Material 2.2

import org.fluke.TaskManager 1.0
import org.fluke.Session 1.0

WaylandOutput {
    id: output
    sizeFollowsWindow: true

    readonly property alias surfaceArea: workspace

    window: ApplicationWindow {
        width: 1024 // Qt.application.screens[0].width
        height: 768 // Qt.application.screens[0].height
        visible: true

        // TODO make configurable
        Material.theme: Material.Dark
        Material.accent: Material.Blue

        background: Image {
            id: background
            fillMode: Image.Tile
            asynchronous: true
            source: "qrc:/images/background.jpg"
        }

        header: Panel  {
            id: panel
            onLogout: {
                systemDialog.text = qsTr("Do you really want to logout?");
                systemDialog.acceptedFunctionCallback = function() { Qt.quit() }
                systemDialog.open();
            }
            onSuspend: {
                systemDialog.text = qsTr("Do you really want to suspend?");
                systemDialog.acceptedFunctionCallback = function() { Session.suspend() }
                systemDialog.open();
            }
            onReboot: {
                systemDialog.text = qsTr("Do you really want to reboot?");
                systemDialog.acceptedFunctionCallback = function() { Session.reboot() }
                systemDialog.open();
            }
            onShutdown: {
                systemDialog.text = qsTr("Do you really want to suspend?");
                systemDialog.acceptedFunctionCallback = function() { Session.shutdown() }
                systemDialog.open();
            }
        }

        footer: Dock {
            id: dock
            anchors.horizontalCenter: parent.horizontalCenter
        }

        WaylandMouseTracker {
            id: mouseTracker
            anchors.fill: parent
            z: 1000

            Item {
                id: workspace
                anchors.fill: parent
            }

            Loader {
                anchors.fill: parent
                source: "Keyboard.qml"
            }

            WaylandCursorItem {
                id: cursor
                inputEventsEnabled: false
                x: mouseTracker.mouseX
                y: mouseTracker.mouseY

                seat: output.compositor.defaultSeat
                visible: true
            }
        }

//        Shortcut {
//            sequence: "Meta+F"
//            onActivated: qtWindowManager.showIsFullScreen = !qtWindowManager.showIsFullScreen
//        }

        Shortcut {
            sequence: "Ctrl+Alt+Backspace"
            context: Qt.ApplicationShortcut
            onActivated: panel.logout();
        }

        Shortcut {
            sequence: "Ctrl+Alt+T"
            context: Qt.ApplicationShortcut
            onActivated: {
                console.info("!!! terminal");
                Runner.runCommand("konsole");
            }
        }

        Dialog {
            id: systemDialog
            title: qsTr("Log Out")
            x: (parent.width - width) / 2
            y: (parent.height - height) / 2
            modal: true
            focus: visible
            visible: false
            standardButtons: Dialog.Ok | Dialog.Cancel
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
