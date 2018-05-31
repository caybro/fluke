import QtQuick 2.10
import QtQuick.Window 2.2
import QtWayland.Compositor 1.1

import org.fluke.TaskManager 1.0

ShellSurfaceItem {
    id: rootChrome

    readonly property bool isChild: !!parentSurfaceItem
    readonly property alias appId: priv.appId
    readonly property bool activated: xdgSurface && xdgSurface.activated
    readonly property bool fullscreen: xdgSurface && xdgSurface.fullscreen

    property bool isToplevel
    property bool isPopup
    property bool minimized
    property Workspace workspace

    property var xdgSurface: shellSurface
    property var parentSurfaceItem

    opacity: !minimized && !workspace.appLauncherVisible ? 1 : 0
    visible: opacity > 0

    x: moveItem.x - output.geometry.x
    y: moveItem.y - output.geometry.y

    onXChanged: updatePrimary()
    onYChanged: updatePrimary()
    function updatePrimary() {
        var w = rootChrome.width
        var h = rootChrome.height
        var area = w * h;
        var screenW = rootChrome.output.geometry.width;
        var screenH = rootChrome.output.geometry.height;
        var x1 = Math.max(0, x);
        var y1 = Math.max(0, y);
        var x2 = Math.min(x + w, screenW);
        var y2 = Math.min(y + h, screenH);
        var w1 = Math.max(0, x2 - x1);
        var h1 = Math.max(0, y2 - y1);
        if (w1 * h1 * 2 > area) {
            rootChrome.setPrimary();
        }
    }

    Behavior on opacity { DefaultAnimation {} }

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
        if (isChild) {
            parentSurfaceItem.inputEventsEnabled = true;
            workspace.activateView(rootChrome.parentSurfaceItem);
        }

        if (isPopup || workspace.appLauncherVisible || minimized) {
            rootChrome.destroy();
        } else {
            bufferLocked = true;
            destroyAnimation.start();
        }
    }

    onShellSurfaceChanged: {
        if (shellSurface && !rootChrome.isPopup) {
            priv.appId = Applications.setSurfaceAppeared(priv.pid, shellSurface.surface, priv.appId);
        }
    }

    Connections {
        target: compositor
        ignoreUnknownSignals: true
        onSurfaceAboutToBeDestroyed: {
            if (!rootChrome.isPopup) {
                Applications.setSurfaceVanished(priv.pid, surface);
            }
        }
    }

    Connections {
        target: rootChrome.xdgSurface

        // some signals are not available on wl_shell, so let's ignore them
        ignoreUnknownSignals: true

        // xdg_shell only
        onAppIdChanged: {
            if (!priv.appId) { // fallback, something appeared but not started by us
                priv.appId = Applications.setSurfaceAppeared(priv.pid, shellSurface.surface, xdgSurface.appId);
            }
        }

        onActivatedChanged: {
            if (rootChrome.activated && !rootChrome.isPopup) {
                workspace.activated(rootChrome.appId);
                receivedFocusAnimation.start();
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
            rootChrome.minimized = true;
            workspace.minimized(rootChrome.appId);
        }
        onSetFullscreen: {
            workspace.fullscreen(rootChrome.appId);
            rootChrome.xdgSurface.sendFullscreen(output ? Qt.size(output.geometry.width, output.geometry.height)
                                                        : Qt.size(rootChrome.Window.width, rootChrome.Window.height));
            rootChrome.bufferLocked = true;
            fullscreenAnimation.start();
        }
        onUnsetFullscreen: {
            workspace.exitFullscreen(rootChrome.appId);
            rootChrome.xdgSurface.sendUnmaximized(); // FIXME sendExitFullscreen() missing in QtWayland
            rootChrome.bufferLocked = true;
            exitFullscreenAnimation.start();
        }
        onParentSurfaceChanged: {
            var parentSurfaceItem = output.viewsBySurface[xdgSurface.parentSurface.surface];
            if (parentSurfaceItem && rootChrome.parent !== parentSurfaceItem) {
                rootChrome.parentSurfaceItem = parentSurfaceItem;
                rootChrome.parent = parentSurfaceItem;
                rootChrome.anchors.centerIn = parentSurfaceItem;
                rootChrome.moveItem = parentSurfaceItem.moveItem;
                parentSurfaceItem.inputEventsEnabled = false;
            }
        }
        onParentToplevelChanged: {
            var parentSurfaceItem = output.toplevelsBySurface[xdgSurface.parentToplevel];
            if (parentSurfaceItem && rootChrome.parent !== parentSurfaceItem) {
                rootChrome.parentSurfaceItem = parentSurfaceItem;
                rootChrome.parent = parentSurfaceItem;
                rootChrome.anchors.centerIn = parentSurfaceItem;
                rootChrome.moveItem = parentSurfaceItem.moveItem;
                parentSurfaceItem.inputEventsEnabled = false;
            }
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
        readonly property int duration: 50
        NumberAnimation { target: scaleTransform; properties: "xScale,yScale"; to: 1.01; duration: receivedFocusAnimation.duration;
            easing.type: Easing.OutQuad }
        NumberAnimation { target: scaleTransform; properties: "xScale,yScale"; to: 1; duration: receivedFocusAnimation.duration;
            easing.type: Easing.InOutQuad }
    }

    SequentialAnimation {
        id: maximizeAnimation
        readonly property int duration: 150
        ParallelAnimation {
            PropertyAnimation { target: rootChrome; properties: "x,y"; duration: maximizeAnimation.duration; to: 0 }
            PropertyAnimation { target: rootChrome; property: "width"; duration: maximizeAnimation.duration; to: rootChrome.output.availableGeometry.width }
            PropertyAnimation { target: rootChrome; property: "height"; duration: maximizeAnimation.duration; to: rootChrome.output.availableGeometry.height }
        }
        ScriptAction { script: { rootChrome.bufferLocked = false; } }
    }

    SequentialAnimation {
        id: unmaximizeAnimation
        readonly property int duration: 150
        ParallelAnimation {
            PropertyAnimation { target: rootChrome; properties: "x,y"; duration: unmaximizeAnimation.duration; from: 0 }
            PropertyAnimation { target: rootChrome; property: "width"; duration: unmaximizeAnimation.duration; from: rootChrome.output.availableGeometry.width }
            PropertyAnimation { target: rootChrome; property: "height"; duration: unmaximizeAnimation.duration; from: rootChrome.output.availableGeometry.height }
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
