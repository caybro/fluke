import QtQuick 2.12
import QtQuick.Controls 2.12 as QQC

import Qt.labs.platform 1.1 as Platform

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

    QQC.Menu {
        id: shellContextMenu

        QQC.MenuItem {
            icon.source: "qrc:/icons/material/wallpaper-24px.svg"
            text: qsTr("Select Wallpaper...")
            onTriggered: wallpaperDialog.open()
        }

        QQC.MenuItem {
            icon.source: "qrc:/icons/material/apps-24px.svg"
            text: qsTr("Open Launcher")
            onTriggered: workspace.showLauncher()
        }
        QQC.MenuItem {
            icon.source: "qrc:/icons/material/login-24px.svg"
            text: qsTr("Logout...")
            onTriggered: workspace.logout()
        }
    }

    Platform.FileDialog {
        id: wallpaperDialog
        fileMode: Platform.FileDialog.OpenFile
        folder: "file:///usr/share/wallpapers" //Platform.StandardPaths.standardLocations(Platform.StandardPaths.PicturesLocation)[0]
        title: qsTr("Change Wallpaper")
        nameFilters: [qsTr("Image files (*.jpg *.png *.jpeg)")]
        onAccepted: workspace.changeWallpaper(file)
    }
}
