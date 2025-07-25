import QtQuick
import QtQuick.Window
import QtWayland.Compositor
import QtWayland.Compositor.XdgShell

import org.fluke.TaskManager

ShellSurfaceItem {
    id: rootChrome

    autoCreatePopupItems: true

    readonly property bool isChild: !!parentSurfaceItem
    readonly property alias appId: priv.appId
    readonly property bool activated: xdgSurface && xdgSurface.activated
    readonly property bool fullscreen: xdgSurface && xdgSurface.fullscreen

    readonly property bool isPopup: !!xdgSurface && (xdgSurface.windowType === Qt.Popup || xdgSurface.windowType === Qt.Dialog)
    property bool minimized
    property Workspace workspace

    property var xdgSurface: shellSurface
    property var parentSurfaceItem

    opacity: !minimized && !workspace.appLauncherVisible ? 1 : 0
    visible: opacity > 0

    x: moveItem.x - output.availableGeometry.x
    y: moveItem.y - output.availableGeometry.y

    onXChanged: updatePrimary()
    onYChanged: updatePrimary()
    function updatePrimary() {
        var w = rootChrome.width
        var h = rootChrome.height
        var area = w * h;
        var screenW = rootChrome.output.availableGeometry.width;
        var screenH = rootChrome.output.availableGeometry.height;
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
            //console.warn("!!! SHELL SURFACE CHANGED; APPID:", priv.appId)
        }
    }

    Connections {
        target: compositor
        ignoreUnknownSignals: true
        function onSurfaceAboutToBeDestroyed(surface) {
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
        function onAppIdChanged() {
            //console.warn("!!! APPID CHANGED:", rootChrome.xdgSurface.appId)
            if (!priv.appId) { // fallback, something appeared but not started by us
                priv.appId = Applications.setSurfaceAppeared(priv.pid, shellSurface.surface, rootChrome.xdgSurface.appId);
            }
            //console.warn("!!! APPID INTERNAL:", priv.appId)
        }

        function onActivatedChanged() {
            if (rootChrome.activated && !rootChrome.isPopup) {
                workspace.activated(rootChrome.appId);
                receivedFocusAnimation.start();
            }
        }
        function onSetMinimized() {
            rootChrome.minimized = true;
            workspace.minimized(rootChrome.appId);
        }
        function onSetFullscreen() {
            workspace.fullscreen(rootChrome.appId);
        }
        function onUnsetFullscreen() {
            workspace.exitFullscreen(rootChrome.appId);
        }

        function onParentSurfaceChanged() {
            var parentSurfaceItem = output.viewsBySurface[xdgSurface.parentSurface.surface];
            if (parentSurfaceItem && rootChrome.parent !== parentSurfaceItem) {
                rootChrome.parentSurfaceItem = parentSurfaceItem;
                rootChrome.parent = parentSurfaceItem;
                rootChrome.anchors.centerIn = parentSurfaceItem;
                rootChrome.moveItem = parentSurfaceItem.moveItem;
                parentSurfaceItem.inputEventsEnabled = false;
            }
        }
        function onParentToplevelChanged() {
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

    transform: [
        Scale {
            id: scaleTransform
            origin.x: rootChrome.width / 2
            origin.y: rootChrome.height / 2
        }
    ]
}
