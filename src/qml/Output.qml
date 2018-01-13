import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Window 2.3
import QtWayland.Compositor 1.1
import QtQuick.Controls.Material 2.2

import Qt.labs.settings 1.0

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

    readonly property Connections _compConn: Connections {
        target: compositor
        onSurfaceAboutToBeDestroyed: {
            delete viewsBySurface[surface];
        }
    }

    readonly property Connections _appConn: Connections {
        target: Applications
        onApplicationQuit: {
            if (appId == dock.activeApp) {
                dock.activeApp = "";
            }
            if (appId == workspace.fullscreenAppId) {
                workspace.fullscreenAppId = "";
            }

            activateNextApplication();
        }
    }

    readonly property SystemPalette _pal: SystemPalette {
        colorGroup: SystemPalette.Active
    }

    function activateView(view) {
        view.takeFocus();
        view.raise();
        dock.activeApp = view.appId;
    }

    function activateApplication(appId) {
        var surfaces = Object.keys(viewsBySurface);
        for (var i = surfaces.length - 1; i >= 0; i--) {
            var view = viewsBySurface[surfaces[i]];
            if (view.appId === appId) {
                view.minimized = false;
                activateView(view);
                return;
            }
        }
    }

    function activateNextApplication() {
        var surfaces = Object.keys(viewsBySurface);
        for (var i = surfaces.length - 1; i >= 0; i--) {
            var view = viewsBySurface[surfaces[i]];
            if (!view.minimized) {
                activateView(view);
                return;
            }
        }
        dock.activeApp = "";
    }

    function indexOfActivatedSurface() {
        var surfaces = Object.keys(viewsBySurface);
        for (var i = 0; i < surfaces.length; i++) {
            var view = viewsBySurface[surfaces[i]];
            if (view.activated && !view.minimized) {
                return i;
            }
        }
        return -1;
    }

    function focusNextNonMinimized(startIndex) {
        var currentIndex = startIndex !== undefined ? startIndex : indexOfActivatedSurface() + 1;
        var surfaces = Object.keys(viewsBySurface);
        if (currentIndex >= surfaces.length) {
            focusNextNonMinimized(0); // try again from the beginning
        } else if (currentIndex !== -1) {
            for (var i = currentIndex; i < surfaces.length; i++) {
                var view = viewsBySurface[surfaces[i]];
                if (!view.minimized) {
                    if (view.fullscreen) {
                        workspace.fullscreenAppId = view.appId;
                    }
                    activateView(view);
                    return;
                }
            }
        }
    }

    function focusPreviousNonMinimized(startIndex) {
        var currentIndex = startIndex !== undefined ? startIndex : indexOfActivatedSurface() - 1;
        var surfaces = Object.keys(viewsBySurface);
        if (currentIndex < 0) {
            focusPreviousNonMinimized(surfaces.length - 1); // try again from the end
        } else if (currentIndex !== -1) {
            for (var i = currentIndex; i >= 0; i--) {
                var view = viewsBySurface[surfaces[i]];
                if (!view.minimized) {
                    if (view.fullscreen) {
                        workspace.fullscreenAppId = view.appId;
                    }
                    activateView(view);
                    return;
                }
            }
        }
    }

    window: ApplicationWindow {
        id: win
        x: Screen.virtualX
        y: Screen.virtualY
        width: debugMode ? 1024 : screen.width
        height: debugMode ? 768 : screen.height
        visibility: debugMode ? Window.Windowed : Window.FullScreen
        visible: true

        Material.theme: Material.Dark
        Material.accent: _pal.highlight

        background: Image {
            fillMode: Image.PreserveAspectFit
            asynchronous: true
            source: settings.wallpaper
            sourceSize: Qt.size(win.width, win.height)
        }

        Component.onDestruction: {
            settings.wallpaper = background.source;
        }

        Settings {
            id: settings
            property alias autohideDock: panel.autohideDock
            property url wallpaper: "qrc:/images/background.jpg"
        }

        WaylandMouseTracker {
            id: mouseTracker
            anchors.fill: parent
            windowSystemCursorEnabled: false

            onMouseYChanged: {
                if (dock.autohide && !workspace.fullscreenAppId) {
                    if (!dock.visible && mouseY >= win.height - 5) {
                        dock.show();
                    } else if (dock.visible && !dock.contains(mapToItem(dock, mouseX, mouseY)) &&
                               mouseY < win.height - dock.height) {
                        dock.hide();
                    }
                }
            }

            Panel  {
                id: panel
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                appLauncherVisible: appLauncher.visible
                visible: !workspace.fullscreenAppId || dock.activeApp != workspace.fullscreenAppId
                height: visible ? implicitHeight : 0
                onLogout: {
                    systemDialog.title = qsTr("Log Out");
                    systemDialog.text = qsTr("Do you really want to logout?");
                    systemDialog.acceptedFunctionCallback = function() { Qt.quit() } // TODO also quit the session
                    systemDialog.open();
                }
                onSuspend: {
                    systemDialog.title = qsTr("Suspend");
                    systemDialog.text = qsTr("Do you really want to suspend the computer?");
                    systemDialog.acceptedFunctionCallback = function() {
                        // @disable-check M127
                        debugMode ? console.info("SIMULATION: suspend") : Session.suspend();
                    }
                    systemDialog.open();
                }
                onReboot: {
                    systemDialog.title = qsTr("Restart");
                    systemDialog.text = qsTr("Do you really want to restart the computer?");
                    systemDialog.acceptedFunctionCallback = function() {
                        // @disable-check M127
                        debugMode ? console.info("SIMULATION: restart") : Session.reboot()
                    }
                    systemDialog.open();
                }
                onShutdown: {
                    systemDialog.title = qsTr("Shutdown");
                    systemDialog.text = qsTr("Do you really want to turn off the computer?");
                    systemDialog.acceptedFunctionCallback = function() {
                        // @disable-check M127
                        debugMode ? console.info("SIMULATION: shutdown") : Session.shutdown()
                    }
                    systemDialog.open();
                }
                onHideLauncher: appLauncher.hide()
            }

            Workspace {
                id: workspace
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: panel.bottom
                anchors.bottom: appLauncherVisible ? parent.bottom : dock.top
                focus: true

                appLauncherVisible: appLauncher.visible // used in Chrome.qml

                onActivated: {
                    dock.activeApp = appId;
                }
                onMinimized: {
                    output.activateNextApplication();
                }

                onChangeWallpaper: win.background.source = fileUrl
                onShowLauncher: appLauncher.show()
                onLogout: panel.logout()
            }

            ApplicationLauncher {
                id: appLauncher
                anchors.fill: workspace
                opacity: 0.0
            }

            Dock {
                id: dock
                anchors.horizontalCenter: parent.horizontalCenter
                y: autohide ? win.height : win.height - dock.height + dock.background.radius
                visible: (autohide ? y < win.height && !appLauncher.visible && count > 0
                                  : !appLauncher.visible && count > 0) &&
                         (!workspace.fullscreenAppId || dock.activeApp != workspace.fullscreenAppId)

                property alias autohide: settings.autohideDock
                onAutohideChanged: { // FIXME this shouldn't be necessary
                    if (!autohide) {
                        show();
                    }
                }

                onActivateApplication: {
                    output.activateApplication(appId);
                }
                onShowLauncher: appLauncher.show()
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

        Shortcut {
            sequence: debugMode ? "Ctrl+Tab" : "Alt+Tab"
            enabled: dock.activeApp
            context: Qt.ApplicationShortcut
            onActivated: focusNextNonMinimized()
        }

        Shortcut {
            sequence: debugMode ? "Ctrl+Shift+Tab" : "Alt+Shift+Tab"
            enabled: dock.activeApp
            context: Qt.ApplicationShortcut
            onActivated: focusPreviousNonMinimized()
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
