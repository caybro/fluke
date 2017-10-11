import QtQuick 2.9
import QtWayland.Compositor 1.0

WaylandCompositor {
    id: comp
    useHardwareIntegrationExtension: true

    property var viewsBySurface: ({})

    onSurfaceAboutToBeDestroyed: {
        console.info("Surface", surface, "about to be destroyed")
        console.info("Before:", Object.keys(viewsBySurface));
        delete viewsBySurface[surface];
        //defaultSeat.setKeyboardFocus(Object.keys(viewsBySurface)[0])
        console.info("AFTER:")
        Object.keys(viewsBySurface).forEach(function(key) {
            // `prop` is the property name
            // `data[prop]` is the property value
            console.info("surface:", key, ", view:", viewsBySurface[key]);
        });
    }

    Output {
        compositor: comp
    }

    Component {
        id: chromeComponent
        Chrome {}
    }

    Component {
        id: surfaceComponent
        WaylandSurface {}
    }

    QtWindowManager {
        id: qtWindowManager
        onShowIsFullScreenChanged: console.log("Show is fullscreen hint for Qt applications:", showIsFullScreen)
        onOpenUrl: Qt.openUrlExternally(url)
    }

    WlShell {
        onWlShellSurfaceCreated: {
            console.info("Wl shell surface created:", shellSurface)
            var item = chromeComponent.createObject(defaultOutput.surfaceArea, { "shellSurface": shellSurface,
                                                        "workspace": defaultOutput.surfaceArea } );
            viewsBySurface[shellSurface.surface] = item;
        }
    }

    XdgShellV5 {
        onXdgSurfaceCreated: {
            console.info("Xdg5 shell surface created:", xdgSurface)
            console.info("Window type:", xdgSurface.windowType)
            var item = chromeComponent.createObject(defaultOutput.surfaceArea, { "shellSurface": xdgSurface,
                                                        "workspace": defaultOutput.surfaceArea, "focus": true } );
            viewsBySurface[xdgSurface.surface] = item;
        }
        onXdgPopupCreated: {
            console.info("Xdg5 popup surface created:", xdgPopup)
            console.info("Popup type:", xdgPopup.windowType)
            var parentView = viewsBySurface[xdgPopup.parentSurface];
            var item = chromeComponent.createObject(parentView, { "shellSurface": xdgPopup,
                                                        "workspace": defaultOutput.surfaceArea } );
            viewsBySurface[xdgPopup.surface] = item;
        }
    }

    TextInputManager {}

    onSurfaceRequested: {
        var surface = surfaceComponent.createObject(comp, {} );
        surface.initialize(comp, client, id, version);
    }

    Component.onCompleted: {
        // TODO make the keymap configurable
        defaultSeat.keymap.layout = "cz";
        defaultSeat.keymap.variant = "qwerty";
    }
}
