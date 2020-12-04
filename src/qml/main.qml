import QtQuick 2.12
import QtQml 2.12
import QtWayland.Compositor 1.12

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

    XdgShell {
        onToplevelCreated: handleToplevelCreated(toplevel, xdgSurface)
    }

    TextInputManager {}

    function createToplevelItem(toplevel, shellSurface, moveItem, output) {
        var parentSurfaceItem = output.toplevelsBySurface[toplevel.parentToplevel];
        var parent = parentSurfaceItem || output.surfaceArea;
        var item = chromeComponent.createObject(parent, {
            "shellSurface": shellSurface,
            "moveItem": moveItem,
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
}
