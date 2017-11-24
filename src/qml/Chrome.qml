import QtQuick 2.9
import QtQuick.Window 2.2
import QtWayland.Compositor 1.0

import org.fluke.TaskManager 1.0

ShellSurfaceItem {
    id: rootChrome

    readonly property bool isChild: parent.shellSurface !== undefined
    readonly property alias appId: priv.appId
    readonly property bool activated: shellSurface.activated

    property bool isPopup: false
    property bool minimized: false
    property Item workspace

    opacity: !minimized && !workspace.appLauncherVisible ? 1 : 0
    visible: opacity > 0

    Behavior on opacity { NumberAnimation { duration: 200 } }

    Component.onCompleted: {
        takeFocus();
        raise();
    }

    QtObject {
        id: priv
        readonly property int pid: shellSurface.surface.client.processId
        property string appId
    }

    onSurfaceDestroyed: {
        if (isPopup) {
            rootChrome.destroy();
        } else {
            bufferLocked = true;
            destroyAnimation.start();
        }
    }

    Connections {
        target: compositor
        ignoreUnknownSignals: true
        onSurfaceAboutToBeDestroyed: {
            if (!rootChrome.isPopup) {
                Applications.setSurfaceVanished(priv.appId, surface);
            }
        }
    }

    Connections {
        target: shellSurface

        // some signals are not available on wl_shell, so let's ignore them
        ignoreUnknownSignals: true

        onClassNameChanged: {
            priv.appId = shellSurface.className;
        }

        // xdg_shell only
        onActivatedChanged: {
            if (shellSurface.activated) {
                workspace.activated(rootChrome.appId);
                receivedFocusAnimation.start();
            }
        }
        onAppIdChanged: {
            if (!priv.appId) {
                priv.appId = shellSurface.appId;
                if (!rootChrome.isPopup) {
                    Applications.setSurfaceAppeared(priv.appId, shellSurface.surface);
                }
            }
        }
        onSetMaximized: {
            rootChrome.bufferLocked = true;
            rootChrome.shellSurface.sendMaximized(Qt.size(workspace.width, workspace.height));
            maximizeAnimation.start();
        }
        onUnsetMaximized: {
            rootChrome.bufferLocked = true;
            rootChrome.shellSurface.sendUnmaximized();
            unmaximizeAnimation.start();
        }
        onSetMinimized: {
            rootChrome.minimized = true;
            workspace.minimized(rootChrome.appId);
        }
        onSetFullscreen: {
            workspace.fullscreen(rootChrome.appId);
            rootChrome.bufferLocked = true;
            rootChrome.shellSurface.sendFullscreen(output ? Qt.size(output.geometry.width, output.geometry.height)
                                                          : Qt.size(rootChrome.Window.width, rootChrome.Window.height));
            fullscreenAnimation.start();
        }
        onUnsetFullscreen: {
            workspace.exitFullscreen(rootChrome.appId);
            rootChrome.bufferLocked = true;
            rootChrome.shellSurface.sendUnmaximized(); // FIXME sendExitFullscreen() missing in QtWayland
            exitFullscreenAnimation.start();
        }
    }

    SequentialAnimation {
        id: destroyAnimation
        readonly property int duration: 150
        ParallelAnimation {
            NumberAnimation { target: scaleTransform; property: "yScale"; to: 2/height; duration: destroyAnimation.duration }
            NumberAnimation { target: scaleTransform; property: "xScale"; to: 0.4; duration: destroyAnimation.duration }
            NumberAnimation { target: rootChrome; property: "opacity"; to: rootChrome.isChild ? 0 : 1; duration: destroyAnimation.duration }
        }
        NumberAnimation { target: scaleTransform; property: "xScale"; to: 0; duration: destroyAnimation.duration }
        ScriptAction { script: { rootChrome.destroy(); } }
    }

    SequentialAnimation {
        id: receivedFocusAnimation
        readonly property int duration: 80
        NumberAnimation { target: scaleTransform; properties: "xScale,yScale"; to: 1.01; duration: receivedFocusAnimation.duration;
            easing.type: Easing.OutQuad }
        NumberAnimation { target: scaleTransform; properties: "xScale,yScale"; to: 1; duration: receivedFocusAnimation.duration;
            easing.type: Easing.InOutQuad }
    }

    SequentialAnimation {
        id: maximizeAnimation
        ParallelAnimation {
            PropertyAnimation { target: rootChrome; properties: "x,y"; duration: 80; to: 0 }
            PropertyAnimation { target: rootChrome; property: "width"; duration: 80; to: rootChrome.workspace.width }
            PropertyAnimation { target: rootChrome; property: "height"; duration: 80; to: rootChrome.workspace.height }
        }
        ScriptAction { script: { rootChrome.bufferLocked = false; } }
    }

    SequentialAnimation {
        id: unmaximizeAnimation
        ParallelAnimation {
            PropertyAnimation { target: rootChrome; properties: "x,y"; duration: 80; from: 0 }
            PropertyAnimation { target: rootChrome; property: "width"; duration: 80; from: rootChrome.workspace.width }
            PropertyAnimation { target: rootChrome; property: "height"; duration: 80; from: rootChrome.workspace.height }
        }
        ScriptAction { script: { rootChrome.bufferLocked = false; } }
    }

    SequentialAnimation {
        id: fullscreenAnimation
        ParallelAnimation {
            PropertyAnimation { target: rootChrome; properties: "x,y"; duration: 80; to: 0 }
            PropertyAnimation { target: rootChrome; property: "width"; duration: 80; to: rootChrome.Window.width }
            PropertyAnimation { target: rootChrome; property: "height"; duration: 80; to: rootChrome.Window.height }
        }
        ScriptAction { script: { rootChrome.bufferLocked = false; } }
    }

    SequentialAnimation {
        id: exitFullscreenAnimation
        ParallelAnimation {
            PropertyAnimation { target: rootChrome; properties: "x,y"; duration: 80; from: 0 }
            PropertyAnimation { target: rootChrome; property: "width"; duration: 80; from: rootChrome.Window.width }
            PropertyAnimation { target: rootChrome; property: "height"; duration: 80; from: rootChrome.Window.height }
        }
        ScriptAction { script: { rootChrome.bufferLocked = false; } }
    }

    transform: [
        Scale {
            id: scaleTransform
            origin.x: rootChrome.width / 2
            origin.y: rootChrome.height / 2
        }
    ]
}
