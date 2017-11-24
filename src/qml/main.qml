import QtQuick 2.9
import QtQml 2.2
import QtWayland.Compositor 1.0

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

    TextInputManager {}

    function createShellSurfaceItem(shellSurface, output, isPopup) {
        var parentSurfaceItem = output.viewsBySurface[shellSurface.parentSurface];
        var parent = parentSurfaceItem || output.surfaceArea;
        var item = chromeComponent.createObject(parent, {
            "shellSurface": shellSurface,
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

    function handleShellSurfaceCreated(shellSurface, isPopup) {
        for (var i = 0; i < screens.count; ++i) {
            createShellSurfaceItem(shellSurface, screens.objectAt(i), isPopup);
        }
    }
}
