import QtQuick 2.10
import QtQml 2.2
import QtWayland.Compositor 1.1

WaylandCompositor {
    id: comp
    useHardwareIntegrationExtension: true

    Instantiator {
        id: screens
        model: Qt.application.screens
        delegate: Output {
            compositor: comp
            screen: modelData
            Component.onCompleted: if (!comp.defaultOutput) comp.defaultOutput = this
            position: Qt.point(virtualX, virtualY)
        }
    }

    Component {
        id: chromeComponent
        Chrome {}
    }

    Component {
        id: moveItemComponent
        Item {}
    }

    Item {
        id: rootItem
    }

    QtWindowManager {
        id: qtWindowManager
        onShowIsFullScreenChanged: console.log("Show is fullscreen hint for Qt applications:", showIsFullScreen)
        onOpenUrl: Qt.openUrlExternally(url)
    }

    WlShell {
        onWlShellSurfaceCreated: handleShellSurfaceCreated(shellSurface)
    }

    XdgShellV5 {
        onXdgSurfaceCreated: handleShellSurfaceCreated(xdgSurface)
        onXdgPopupCreated: handleShellSurfaceCreated(xdgPopup, true)
    }

    XdgShellV6 {
        onToplevelCreated: handleToplevelCreated(toplevel, xdgSurface)
        onPopupCreated: handlePopupCreated(popup)
    }

    TextInputManager {}

    function createShellSurfaceItem(shellSurface, moveItem, output, isPopup) {
        var parentSurfaceItem = output.viewsBySurface[shellSurface.parentSurface];
        var parent = parentSurfaceItem || output.surfaceArea;
        var item = chromeComponent.createObject(parent, {
            "shellSurface": shellSurface,
            "moveItem": moveItem,
            "output": output,
            "workspace": output.surfaceArea,
            "isPopup": isPopup
        });
        if (parentSurfaceItem) {
            item.x += output.position.x;
            item.y += output.position.y;
        }
        output.viewsBySurface[shellSurface.surface] = item;
    }

    function createToplevelItem(toplevel, shellSurface, moveItem, output) {
        var parentSurfaceItem = output.toplevelsBySurface[toplevel.parentToplevel];
        var parent = parentSurfaceItem || output.surfaceArea;
        var item = chromeComponent.createObject(parent, {
            "shellSurface": shellSurface,
            "moveItem": moveItem,
            "output": output,
            "workspace": output.surfaceArea,
            "isToplevel": true,
            "xdgSurface": toplevel
        });
        if (parentSurfaceItem) {
            item.x += output.position.x;
            item.y += output.position.y;
        }
        output.viewsBySurface[shellSurface.surface] = item;
        output.toplevelsBySurface[toplevel] = item;
    }

    function createPopupItem(popup, output) {
        var parentSurfaceItem = output.viewsBySurface[popup.parentXdgSurface];
        var parent = parentSurfaceItem || output.surfaceArea;
        var item = chromeComponent.createObject(parent, {
            "shellSurface": popup.xdgSurface,
            "output": output,
            "workspace": output.surfaceArea,
            "isPopup": true,
            "xdgSurface": popup
        });
        if (parentSurfaceItem) {
            item.x += output.position.x;
            item.y += output.position.y;
        }
        output.viewsBySurface[popup.xdgSurface.surface] = item;
    }

    function handleShellSurfaceCreated(shellSurface, isPopup) {
        var moveItem = moveItemComponent.createObject(rootItem, {
                "x": screens.objectAt(0).position.x,
                "y": screens.objectAt(0).position.y,
                "width": Qt.binding(function() { return shellSurface.surface.width; }),
                "height": Qt.binding(function() { return shellSurface.surface.height; })
            });
        for (var i = 0; i < screens.count; ++i) {
            createShellSurfaceItem(shellSurface, moveItem, screens.objectAt(i), isPopup);
        }
    }

    function handleToplevelCreated(toplevel, shellSurface) {
        var moveItem = moveItemComponent.createObject(rootItem, {
                "x": screens.objectAt(0).position.x,
                "y": screens.objectAt(0).position.y,
                "width": Qt.binding(function() { return shellSurface.surface.width; }),
                "height": Qt.binding(function() { return shellSurface.surface.height; })
            });
        for (var i = 0; i < screens.count; ++i) {
            createToplevelItem(toplevel, shellSurface, moveItem, screens.objectAt(i));
        }
    }

    function handlePopupCreated(popup) {
        for (var i = 0; i < screens.count; ++i) {
            createPopupItem(popup, screens.objectAt(i));
        }
    }
}
