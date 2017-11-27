import QtQuick 2.9
import QtQuick.Controls 2.2

Item {
    id: workspace

    property bool appLauncherVisible
    property string fullscreenAppId
    
    signal activated(string appId)
    signal minimized(string appId)
    signal fullscreen(string appId)
    signal exitFullscreen(string appId)

    signal showLauncher()
    signal logout()
    
    onFullscreen: {
        if (appId) {
            fullscreenAppId = appId;
        }
    }
    onExitFullscreen: {
        if (fullscreenAppId == appId) {
            fullscreenAppId = "";
        }
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.RightButton
        onClicked: {
            shellContextMenu.x = mouse.x;
            shellContextMenu.y = mouse.y;
            shellContextMenu.open();
        }
    }

    Menu {
        id: shellContextMenu

        MenuItem {
            text: qsTr("Open Launcher")
            onClicked: workspace.showLauncher()
        }
        MenuItem {
            text: qsTr("Logout...")
            onClicked: workspace.logout()
        }
    }
}
