import QtQuick

import QtWayland.Compositor
import QtWayland.Compositor.XdgShell

WaylandCompositor {
    id: comp
    useHardwareIntegrationExtension: true
    socketName: "wayland-fluke"

    Instantiator {
        id: screens
        model: debugMode ? Qt.application.screens[0] : Qt.application.screens
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

    Item {
        id: rootItem
    }

    QtWindowManager {
        id: qtWindowManager
        onShowIsFullScreenChanged: console.log("Show is fullscreen hint for Qt applications:", showIsFullScreen)
        onOpenUrl: Qt.openUrlExternally(url)
    }

    XdgShell {
        onToplevelCreated: handleToplevelCreated(toplevel, xdgSurface)
    }

    TextInputManager {}

    function createToplevelItem(toplevel, shellSurface, output) {
        var parentSurfaceItem = output.toplevelsBySurface[toplevel.parentToplevel];
        var parent = parentSurfaceItem || output.surfaceArea;
        var item = chromeComponent.createObject(parent, {
            "shellSurface": shellSurface,
            "output": output,
            "workspace": output.surfaceArea,
            "xdgSurface": toplevel
        });
        if (parentSurfaceItem) {
            item.x += output.position.x;
            item.y += output.position.y;
        }
        output.viewsBySurface[shellSurface.surface] = item;
        output.toplevelsBySurface[toplevel] = item;
    }

    function handleToplevelCreated(toplevel, shellSurface) {
        for (var i = 0; i < screens.count; ++i) {
            createToplevelItem(toplevel, shellSurface, screens.objectAt(i));
        }
    }
}
