import QtQuick 2.9
import QtWayland.Compositor 1.0

import org.fluke.TaskManager 1.0

ShellSurfaceItem {
    id: rootChrome

    readonly property bool isChild: parent.shellSurface !== undefined

    property bool isPopup: false
    property Item workspace

    visible: !priv.minimized && !workspace.appLauncherVisible

    Component.onCompleted: {
        takeFocus();
        raise();
    }

    QtObject {
        id: priv
        readonly property int pid: shellSurface.surface.client.processId
        property string className
        property bool minimized: false
    }

    onSurfaceDestroyed: {
        Applications.setSurfaceVanished(priv.className);
        if (isPopup) {
            rootChrome.destroy();
        } else {
            bufferLocked = true;
            destroyAnimation.start();
        }
    }

    Connections {
        target: shellSurface

        // some signals are not available on wl_shell, so let's ignore them
        ignoreUnknownSignals: true

        onClassNameChanged: {
            priv.className = shellSurface.className;
        }

        // xdg_shell only
        onActivatedChanged: {
            if (shellSurface.activated) {
                receivedFocusAnimation.start();
            }
        }
        onAppIdChanged: {
            if (!priv.className) {
                priv.className = shellSurface.appId;
                Applications.setSurfaceAppeared(priv.className);
            }
        }
        onSetMaximized: {
            rootChrome.bufferLocked = true;
            maximizeAnimation.start();
        }
        onUnsetMaximized: {
            rootChrome.bufferLocked = true;
            unmaximizeAnimation.start();
        }
        onSetMinimized: {
            priv.minimized = true;
        }
        onShowWindowMenu: {
            console.info("Window menu:", seat, localSurfacePosition)
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

    transform: [
        Scale {
            id: scaleTransform
            origin.x: rootChrome.width / 2
            origin.y: rootChrome.height / 2
        }
    ]
}
