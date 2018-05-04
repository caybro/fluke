import QtQuick 2.10
import QtQuick.Controls 2.3

import Qt.labs.platform 1.0 as Platform

Item {
    id: workspace

    property bool appLauncherVisible
    property string fullscreenAppId

    signal activated(string appId)
    signal minimized(string appId)
    signal fullscreen(string appId)
    signal exitFullscreen(string appId)
    signal activateView(var view)

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
            icon.name: "preferences-desktop-wallpaper-symbolic"
            icon.height: 16
            icon.width: 16
            text: qsTr("Select Wallpaper...")
            onTriggered: wallpaperDialog.open()
        }

        MenuItem {
            icon.name: "view-app-grid-symbolic"
            icon.height: 16
            icon.width: 16
            text: qsTr("Open Launcher")
            onTriggered: workspace.showLauncher()
        }
        MenuItem {
            icon.name: "application-exit-symbolic"
            icon.height: 16
            icon.width: 16
            text: qsTr("Logout...")
            onTriggered: workspace.logout()
        }
    }

    Platform.FileDialog {
        id: wallpaperDialog
        fileMode: Platform.FileDialog.OpenFile
        folder: "file:///usr/share/wallpapers" //Platform.StandardPaths.standardLocations(Platform.StandardPaths.PicturesLocation)[0]
        title: qsTr("Change Wallpaper")
        nameFilters: [qsTr("Image files (*.jpg *.png)")]
        onAccepted: workspace.changeWallpaper(file)
    }
}
