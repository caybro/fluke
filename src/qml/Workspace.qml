import QtQuick 2.9
import QtQuick.Controls 2.2

import Qt.labs.platform 1.0 as Platform

Item {
    id: workspace

    property bool appLauncherVisible
    property string fullscreenAppId
    
    signal activated(string appId)
    signal minimized(string appId)
    signal fullscreen(string appId)
    signal exitFullscreen(string appId)

    signal changeWallpaper(url fileUrl)
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
            text: qsTr("Select Wallpaper...")
            onTriggered: wallpaperDialog.open()
        }

        MenuItem {
            text: qsTr("Open Launcher")
            onTriggered: workspace.showLauncher()
        }
        MenuItem {
            text: qsTr("Logout...")
            onTriggered: workspace.logout()
        }
    }

    Platform.FileDialog {
        id: wallpaperDialog
        fileMode: Platform.FileDialog.OpenFile
        folder: "file:///usr/share/wallpapers" //Platform.StandardPaths.standardLocations(Platform.StandardPaths.PicturesLocation)[0]
        title: qsTr("Change Wallpaper")
        nameFilters: qsTr("Image files (*.jpg *.png)")
        onAccepted: workspace.changeWallpaper(file)
    }
}
